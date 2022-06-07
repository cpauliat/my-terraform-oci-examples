# --------- Get the OCID for the more recent for Windows 2016 disk image
data oci_core_images ImageOCID-win2016 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Windows"
  operating_system_version = "Server 2016 Standard"

  # filter to remove E2 images
  filter {
      name   = "display_name"
      values = ["Windows-Server-2016-Standard-Edition-VM-Gen2-20*"]
      regex  = true
  }
}

# ------ generate a random password to replace the temporary password in the cloud-init post-provisioning task
resource random_string windows_password {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 16
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

# ------ Create a block volume
resource oci_core_volume tf-demo11b-vol1 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo11b-vol1"
  size_in_gbs         = "50"
}

# ------ Attach the new block volume to the compute instance after it is created
resource oci_core_volume_attachment tf-demo11b-vol1-attach {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.tf-demo11b-win2016.id
  volume_id       = oci_core_volume.tf-demo11b-vol1.id
}

# ------ Create a compute instance from the most recent Windows 2016 image
resource oci_core_instance tf-demo11b-win2016 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo11b-win2016"
  preserve_boot_volume = "false"
  shape                = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-win2016.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo11b-public-subnet1.id
    hostname_label = "tf-demo11b-win2016"
  }

  metadata = {
    user_data      = base64encode(file(var.BootStrapFile_win2016))
    myarg_password = random_string.windows_password.result
  }
}

# -- WinRm remote-exec
data template_file winrm_ps1 {
  vars = {
    volume_ipv4 = oci_core_volume_attachment.tf-demo11b-vol1-attach.ipv4
    volume_iqn  = oci_core_volume_attachment.tf-demo11b-vol1-attach.iqn
  }
  template = file(var.WinRMFile_win2016)
}

resource null_resource remote-exec-windows {
  # Although we wait on the wait_for_cloudinit resource, the configuration may not be complete, if this step fails please retry
  depends_on = [oci_core_instance.tf-demo11b-win2016]

  provisioner "file" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "1m"
      host     = oci_core_instance.tf-demo11b-win2016.public_ip
      user     = "opc"
      password = random_string.windows_password.result
      port     = var.winrm_https_port
      https    = "true"
      insecure = "true"    #self-signed certificate accepted
    }

    content     = data.template_file.winrm_ps1.rendered
    destination = "C:/Users/opc/winrm.ps1"
  }

  provisioner "remote-exec" {
    connection {
      type     = "winrm"
      agent    = false
      timeout  = "1m"
      host     = oci_core_instance.tf-demo11b-win2016.public_ip
      user     = "opc"
      password = random_string.windows_password.result
      port     = var.winrm_https_port
      https    = "true"
      insecure = "true"    #self-signed certificate accepted
    }

    inline = [
      "powershell.exe -file C:/Users/opc/winrm.ps1",
    ]
  }
}

# ------ Display the connections details for the compute instance
data oci_core_instance_credentials tf-demo11b-win2016 {
  instance_id = oci_core_instance.tf-demo11b-win2016.id
}

output Instance_Win2016 {
  value = <<EOF


  ---- You can RDP directly to the Win2016 instance using following parameters
  public IP = ${oci_core_instance.tf-demo11b-win2016.public_ip}
  user      = ${data.oci_core_instance_credentials.tf-demo11b-win2016.username} or opc2
  password  = ${random_string.windows_password.result}

  ====== SECURITY ALERT ======
  The password for users opc and opc2 were set using cloud-init which is NOT A SECURE WAY of passing sensitive arguments.
  Any user of the compute instance can get the cloud-init metadata and see this password.
  MAKE SURE to change the password for users opc and opc2 if you plan to keep this compute instance.

EOF
}
