# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo01-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo01-ol7"
  preserve_boot_volume = "false"
  shape                = "VM.Standard.E4.Flex"
  # Comment the shape_config following lines for non-flexible shape
  shape_config {
    ocpus         = "4"
    memory_in_gbs = "17"  # total amount of memory for the instance
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs    # default 50 GB if no size provided
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo01-public-subnet1.id
    hostname_label = "tf-demo01-ol7"
    # private_ip    = "10.0.0.3"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.BootStrapFile_ol7))
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_OL7 {
  value = <<EOF


  ---- You can SSH directly to the OL7 instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_instance.tf-demo01-ol7.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh ol7"

  Host d01ol7
          Hostname ${oci_core_instance.tf-demo01-ol7.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}

  
EOF
}

