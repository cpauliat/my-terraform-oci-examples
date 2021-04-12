
# ------ Create a 500GB block volume
resource oci_core_volume tf-demo06-ol7-vol1 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo06-ol7-vol1"
  size_in_gbs         = "500"
}

# ------ Attach the new block volume to the ol7 compute instance after it is created
resource oci_core_volume_attachment tf-demo06-ol7-vol1-attach {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf-demo06-ol7.id
  volume_id       = oci_core_volume.tf-demo06-ol7-vol1.id
  device          = var.bkvol_attachment_name
}

# ------ Create a compute instance from the more recent Oracle Linux 7.x image
resource oci_core_instance tf-demo06-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo06-ol7"
  shape                = "VM.Standard.E2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = var.ol7dev_ocid
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo06-public-subnet1.id
    hostname_label = "tf-demo06-ol7"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.BootStrapFile_ol7))
    myarg_dsk_name      = var.bkvol_attachment_name
    myarg_mount_point   = var.bkvol_mount_point
  }
}

# ------ Get the public IP of instance and display it on screen
output Instance_Demo06 {
  value = <<EOF


  ---- You can SSH directly to the OL7 Cloud Developer instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo06-ol7.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d06"

  Host d06
          Hostname ${oci_core_instance.tf-demo06-ol7.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}


EOF

}

