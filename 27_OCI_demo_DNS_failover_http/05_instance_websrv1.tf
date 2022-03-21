# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo27-ws1 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo27-websrv1"
  shape                = var.shape
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
   }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo27-public-subnet1.id
    hostname_label = "websrv1"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
    myarg_dns_hostname  = var.dns_hostname
  }
}

resource null_resource tf-demo27-ws1 {

  provisioner "file" {
    connection {
        agent       = false
        timeout     = "10m"
        host        = oci_core_instance.tf-demo27-ws1.public_ip
        user        = "opc"
        private_key = file(var.ssh_private_key_file)
    }
    source      = var.web_page_zip
    destination = "/home/opc/${var.web_page_zip}"
  }

  provisioner "remote-exec" {
    connection {
        agent       = false
        timeout     = "10m"
        host        = oci_core_instance.tf-demo27-ws1.public_ip
        user        = "opc"
        private_key = file(var.ssh_private_key_file)
    }
    inline = [
      "sudo cloud-init status --wait",
      "sudo rm -f /usr/share/nginx/html/*",
      "sudo unzip -d /usr/share/nginx/html /home/opc/${var.web_page_zip}",
      "sudo sed -i.bak -e \"s#XXXXXXXX# `hostname` (`curl ifconfig.co`)#g\" /usr/share/nginx/html/index.html",
      "sudo sed -i     -e \"s#YYYYYYYY# ${var.dns_hostname}#g\"             /usr/share/nginx/html/index.html"
    ]
  }
}
