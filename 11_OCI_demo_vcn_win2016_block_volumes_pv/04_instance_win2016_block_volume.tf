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

# ------ Create a block volume
resource oci_core_volume tf-demo11-win2016-vol1 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo11-win2016-vol1"
  size_in_gbs         = "100"
}

# ------ Attach the new block volume to the Windows compute instance after it is created
resource oci_core_volume_attachment tf-demo11-win2016-vol1-attach {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.tf-demo11-win2016.id
  volume_id       = oci_core_volume.tf-demo11-win2016-vol1.id
}

# ------ Create a compute instance from the most recent Windows 2016 image
resource oci_core_instance tf-demo11-win2016 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo11-win2016"
  preserve_boot_volume = "false"
  shape                = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-win2016.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo11-public-subnet1.id
    hostname_label = "tf-demo11-win2016"
  }

  metadata = {
    user_data      = base64encode(file(var.BootStrapFile_win2016))
    myarg_fs_label = var.fs_label
  }
}

# ------ Display the complete ssh command needed to connect to the instance
data oci_core_instance_credentials tf-demo11-win2016 {
  instance_id = oci_core_instance.tf-demo11-win2016.id
}

output Instance_Win2016 {
  value = <<EOF


  ---- You can RDP directly to the Win2016 instance using following parameters
  public IP = ${oci_core_instance.tf-demo11-win2016.public_ip}
  user      = ${data.oci_core_instance_credentials.tf-demo11-win2016.username}  (user with Administrator privileges)
  password  = ${data.oci_core_instance_credentials.tf-demo11-win2016.password}  (temporary password, needs to be changed on the first connection)

EOF

}
