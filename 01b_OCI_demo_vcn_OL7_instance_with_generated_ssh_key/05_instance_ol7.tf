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
resource oci_core_instance tf-demo01b-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo01b-ol7"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo01b-public-subnet1.id
    hostname_label = "tf-demo01b-ol7"
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.ssh-demo01b.public_key_openssh
    user_data           = base64encode(file(var.BootStrapFile_ol7))
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_OL7 {
  value = <<EOF


  ---- You can SSH directly to the OL7 instance by typing the following ssh command
  ssh -i ${var.ssh_key_file_private} opc@${oci_core_instance.tf-demo01b-ol7.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh ol7"

  Host ol7
          Hostname ${oci_core_instance.tf-demo01b-ol7.public_ip}
          User opc
          IdentityFile ${var.ssh_key_file_private}

  
EOF

}

