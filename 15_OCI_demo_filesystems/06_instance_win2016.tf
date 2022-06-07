# --------- Get the OCID for the more recent for Windows 2016 disk image
data oci_core_images ImageOCID-win2016 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Windows"
  operating_system_version = "Server 2016 Standard"

  # filter to remove E2 images
  filter {
      name   = "display_name"
      values = ["Windows-Server-2016-Standard-Edition-VM-Gen2"]
      regex  = true
  }
}

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

# ------ Create a compute instance from the most recent Windows 2016 image
resource oci_core_instance tf-demo15-win2016 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo15-win2016"
  preserve_boot_volume = "false"
  shape                = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-win2016.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo15-public-subnet1.id
    hostname_label = "demo15win2016"
  }

  metadata = {
    user_data            = base64encode(file(var.BootStrapFile_win2016))
    myarg_password       = random_string.windows_password.result
    myarg_fs_ip_address  = local.mt1_ip_address
    myarg_fs_export_path = var.fs1_export_path
    myarg_nfs_drive      = var.win2016_nfs_drive
  }
}

# ------ Display the complete ssh command needed to connect to the instance
data oci_core_instance_credentials tf-demo15-win2016 {
  instance_id = oci_core_instance.tf-demo15-win2016.id
}

output Instance_Win2016 {
  value = <<EOF


  ---- You can RDP directly to the Win2016 instance using following parameters
  public IP = ${oci_core_instance.tf-demo15-win2016.public_ip}
  user      = ${data.oci_core_instance_credentials.tf-demo15-win2016.username}
  password  = ${random_string.windows_password.result}

  ---- Alternatively, you can use the file ${var.rdp_file_win2016} just created to RDP to this instance

  ---- Once connected, you can map a network drive by executing the following command in a Powershell terminal
  New-PSDrive ${var.win2016_nfs_drive} -PsProvider Filesystem -Root \\${local.mt1_ip_address}\${var.fs1_export_path} -Persist

EOF

  # Password is changed from temporary password (see below) by cloud-init
  # password  = ${data.oci_core_instance_credentials.tf-demo15-win2016.password}
}

resource local_file rdpfile {
    content = <<EOF
auto connect:i:1
full address:s:${oci_core_instance.tf-demo15-win2016.public_ip}
username:s:${data.oci_core_instance_credentials.tf-demo15-win2016.username}
prompt for credentials:i:0
EOF

    filename = var.rdp_file_win2016
}
