resource random_string opc_password {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 64
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#_-"   # use only special characters in this list
}

resource oci_core_instance tf-demo36-ol8 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo36-ol8"
  shape                = "VM.Standard.E2.2"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol8.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo36-public-subnet1.id
    hostname_label = "tf-demo36-ol8"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
    myarg_user_password = random_string.opc_password.result
    myarg_user_name     = var.new_user
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_ol8 {
  value = <<EOF


  ---- You can SSH directly to the ol8 instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} ${var.new_user}@${oci_core_instance.tf-demo36-ol8.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh ol8"
  Host ol8
          Hostname ${oci_core_instance.tf-demo36-ol8.public_ip}
          User ${var.new_user}
          IdentityFile ${var.ssh_private_key_file}

  ---- In a few minutes, you will be able to connect to Cockit Web console using following parameters:
  https://${oci_core_instance.tf-demo36-ol8.public_ip}    (Self signed certificate)
  user     = ${var.new_user}
  password = ${random_string.opc_password.result}

  
EOF

}

