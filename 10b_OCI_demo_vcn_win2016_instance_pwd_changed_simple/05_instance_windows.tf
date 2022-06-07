# ------ generate a random password to replace the temporary password in the cloud-init post-provisioning task
resource random_string windows_password {
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
  override_special = "#-_"   # use only special characters in this list
}

# ------ Create a compute instance from the most recent Windows 2019 image
resource oci_core_instance tf-demo10b-win2019 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo10b-win2019"
  preserve_boot_volume = "false"
  shape                = var.shape

  dynamic "shape_config" {
    for_each = var.shape_config
      content {
        ocpus         = shape_config.value.ocpus
        memory_in_gbs = shape_config.value.memory_in_gbs
      }
  }

  source_details {
    source_type = "image"
    source_id   = local.image_id    # get the compatible disk image from shape name
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo10b-public-subnet1.id
    hostname_label = "d10b"
  }

  metadata = {
    user_data      = base64encode(file(var.BootStrapFile_windows))
    myarg_password = random_string.windows_password.result
  }
}

# ------ Display connection details
data oci_core_instance_credentials tf-demo10b-win2019 {
  instance_id = oci_core_instance.tf-demo10b-win2019.id
}

output Instance_Win2019 {
  value = <<EOF


  ---- You can RDP directly to the Win2019 instance using following parameters
  public IP = ${oci_core_instance.tf-demo10b-win2019.public_ip}
  user      = ${data.oci_core_instance_credentials.tf-demo10b-win2019.username} or opc2
  password  = ${random_string.windows_password.result}

  ---- Once connected, you can execute script C:\temp\final_run_as_administrator.ps1 in a Powershell terminal (Run as Administrator)
  This will:
  - install OCI CLI
  - Display file extensions in Windows explorer

  ====== SECURITY ALERT ======
  The password for users opc and opc2 were set using cloud-init which is NOT A SECURE WAY of passing sensitive arguments.
  Any user of the compute instance can get the cloud-init metadata and see this password.
  MAKE SURE to change the password for users opc and opc2 if you plan to keep this compute instance.

EOF
}
