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
resource oci_core_instance tf-demo04-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo04-ol7"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo04-public-subnet1.id
    hostname_label = "tf-demo04-ol7"
    # private_ip    = "10.0.0.3"
    nsg_ids        = [oci_core_network_security_group.tf-demo04-nsg1.id]
  }

  metadata = {
    ssh_authorized_keys     = file(var.ssh_public_key_file_ol7)
    user_data               = base64encode(file(var.BootStrapFile_ol7))
    myarg_db_client_version = var.db_client_version
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_OL7 {
  value = <<EOF


  ---- You can SSH directly to the OL7 instance by typing one of the following ssh commands
  ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo04-ol7.public_ip}       # Connect with user opc
  ssh -i ${var.ssh_private_key_file_ol7} oracle@${oci_core_instance.tf-demo04-ol7.public_ip}    # Connect with user oracle


  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d04-opc" or "ssh d04-oracle"

  Host d04-opc
          Hostname ${oci_core_instance.tf-demo04-ol7.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}
  Host d04-oracle
          Hostname ${oci_core_instance.tf-demo04-ol7.public_ip}
          User oracle
          IdentityFile ${var.ssh_private_key_file_ol7}

EOF

}
