# ------ Create 2 compute instances for web servers
resource oci_core_instance demo52-ws {

  # ignore change in cloud-init file after provisioning
  lifecycle {
    ignore_changes = [ defined_tags, metadata ]
  }

  count               = 2
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_websrvs[count.index] - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "demo52-websrv${count.index+1}"
  shape               = "VM.Standard.E2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.demo52-private-subnet.id
    hostname_label   = "websrv${count.index+1}"
    private_ip       = var.websrv_private_ips[count.index]  
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_websrv)
    user_data           = base64encode(file(var.BootStrapFile_websrv))
  }
}

# ------ Post provisioning by remote-exec
resource null_resource demo52 {
  count               = 2

  provisioner "file" {
    connection {
        agent               = false
        timeout             = "10m"
        bastion_host        = oci_core_instance.demo52-bastion.public_ip
        bastion_user        = "opc"
        bastion_private_key = file(var.ssh_private_key_file_websrv)
        host                = oci_core_instance.demo52-ws[count.index].private_ip
        user                = "opc"
        private_key         = file(var.ssh_private_key_file_websrv)
    }
    source      = var.web_page_zip
    destination = "~/${var.web_page_zip}"
  }
  provisioner "remote-exec" {
    connection {
        agent               = false
        timeout             = "10m"
        bastion_host        = oci_core_instance.demo52-bastion.public_ip
        bastion_user        = "opc"
        bastion_private_key = file(var.ssh_private_key_file_websrv)
        host                = oci_core_instance.demo52-ws[count.index].private_ip
        user                = "opc"
        private_key         = file(var.ssh_private_key_file_websrv)
    }
    inline = [
      "sudo cloud-init status --wait",
      "sudo rm -rf /var/www/html/*",
      "sudo unzip -d /var/www/html ${var.web_page_zip}",
      #"sudo yum update -y; sudo reboot"
    ]
  }
}