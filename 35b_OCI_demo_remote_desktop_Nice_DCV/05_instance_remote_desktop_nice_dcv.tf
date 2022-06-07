# ------ Generate a random password for user opc
resource random_string password {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
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

# ------ Create a REMOTE DESKTOP compute instance (OL7.x) 
resource oci_core_instance demo35b {
  lifecycle {
    ignore_changes = [ defined_tags, metadata ]
  }
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "demo35b: remote desktop Nice DCV"
  shape                = var.shape
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = local.image_ocid
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.demo35b-subnet1.id
    hostname_label   = "demo35b"
    assign_public_ip = "true"
    nsg_ids          = [ oci_core_network_security_group.demo35b.id ]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_rdesktop)
    user_data           = base64encode(file(local.bootstrape_file))
    myarg_password      = random_string.password.result
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output demo35b {
  value = <<EOF

  ---- Before you can connect to Nice DCV, you must create a DCV session for a user (for example ${local.user})
  ---- To do this, first SSH to the demo35b compute instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_rdesktop} ${local.user}@${oci_core_instance.demo35b.public_ip}

  ---- Then create DCV session number 1 
  dcv create-session 1

  ---- Now, you can connect to Nice DCV WebUI
  Open https://${oci_core_instance.demo35b.public_ip}:8443/#1 in your web browser  (Self signed certificate)
    then use following credentials
    user     = ${local.user}
    password = ${random_string.password.result}

  ---- Alternatively, you can connect to Nice DCV server using Nice DCV client if it is installed on your local machine

  ---- NOTE: there is no Nice DCV license server configured, so here we use the 15 day demo license.

  EOF
}

