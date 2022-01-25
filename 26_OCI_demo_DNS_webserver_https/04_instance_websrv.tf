# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to avoid Oracle Linux 7.x images for GPU and ARM
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}

# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo26-ws {
  # ignore change in cloud-init file after provisioning
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo26-websrv"
  shape                = var.shape
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
   }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo26-public-subnet1.id
    hostname_label = "websrv"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
    myarg_dns_hostname  = var.dns_hostname
  }
}

# ------ Post provisioning by remote-exec
resource null_resource tf-demo26 {

  provisioner "file" {
    connection {
        agent       = false
        timeout     = "10m"
        host        = oci_core_instance.tf-demo26-ws.public_ip
        user        = "opc"
        private_key = file(var.ssh_private_key_file)
    }
    source      = var.web_page_zip
    destination = "~/${var.web_page_zip}"
  }
  provisioner "remote-exec" {
    connection {
        agent       = false
        timeout     = "10m"
        host        = oci_core_instance.tf-demo26-ws.public_ip
        user        = "opc"
        private_key = file(var.ssh_private_key_file)
    }
    inline = [
      "sudo cloud-init status --wait",
      "sudo rm -f /usr/share/nginx/html/*",
      "sudo mkdir -p /usr/share/nginx/html",
      "sudo unzip -d /usr/share/nginx/html ${var.web_page_zip}"
    ]
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_WEBSRV {
  value = <<EOF

  ---- In a few minutes, open the following URL in your web browser: https://${var.dns_hostname}

  ---- You can SSH directly to the Web Server instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo26-ws.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh websrv"

  Host websrv
          Hostname ${oci_core_instance.tf-demo26-ws.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}

  ---- You can follow progress of post-provisioning tasks by running following command. Last task is the FINAL REBOOT:
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo26-ws.public_ip} sudo tail -f /var/log/cloud-init.log


EOF

}

