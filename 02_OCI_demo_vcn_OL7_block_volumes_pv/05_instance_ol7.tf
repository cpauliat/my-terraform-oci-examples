# ------ Create a block volume
resource oci_core_volume tf-demo02-ol7-vol1 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo02-ol7-vol1"
  size_in_gbs         = var.bkvol_size_gb
  vpus_per_gb         = var.bkvol_vpus_per_gb
}

# ------ Attach the new block volume to the ol7 compute instance after it is created
resource oci_core_volume_attachment tf-demo02-ol7-vol1-attach {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf-demo02-ol7.id
  volume_id       = oci_core_volume.tf-demo02-ol7-vol1.id
  device          = var.bkvol_attachment_name
}

# ------ Create a compute instance from the more recent Oracle Linux 7.x image
resource oci_core_instance tf-demo02-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo02-ol7"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo02-public-subnet1.id
    hostname_label = "tf-demo02-ol7"
    #  private_ip    = "10.0.0.3"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.BootStrapFile_ol7))
    myarg_dsk_name      = var.bkvol_attachment_name
    myarg_mount_point   = var.bkvol_mount_point
  }
}

# ------ Get the public IP of instance and display it on screen
output Instance_OL7 {
  value = <<EOF


  ---- You can SSH directly to the OL7 instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo02-ol7.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d02ol7"

  Host d02ol7
          Hostname ${oci_core_instance.tf-demo02-ol7.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}


EOF

}

