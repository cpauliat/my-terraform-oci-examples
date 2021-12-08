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
resource oci_core_instance tf-demo15-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo15-ol7"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo15-public-subnet1.id
    hostname_label = "tf-demo15-ol7"
  }

  metadata = {
    ssh_authorized_keys  = file(var.ssh_public_key_file_ol7)
    user_data            = base64encode(file(var.BootStrapFile_ol7))
    myarg_fs_mount_point = var.fs1_mount_point
    myarg_fs_ip_address  = local.mt1_ip_address
    myarg_fs_export_path = var.fs1_export_path
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_OL7 {
  value = <<EOF


  ---- You can SSH directly to the OL7 instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo15-ol7.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh ol7"

  Host ol7
          Hostname ${oci_core_instance.tf-demo15-ol7.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}

EOF

}
