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

# ------ Create a compute instance from the most recent Windows 2016 image
resource oci_core_instance tf-demo10c-win2016 {
  depends_on = [ oci_objectstorage_object.tf-demo10c-pwd, oci_objectstorage_preauthrequest.tf-demo10c-pwd ]

  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo10c-win2016"
  preserve_boot_volume = "false"
  shape                = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-win2016.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo10c-public-subnet1.id
    hostname_label = "tf-demo10c-win2016"
  }

  metadata = {
    user_data    = base64encode(file(var.BootStrapFile_win2016))
    myarg_os_par = "https://objectstorage.${var.region}.oraclecloud.com${oci_objectstorage_preauthrequest.tf-demo10c-pwd.access_uri}"
  }
}

# ------ Display connection details
data oci_core_instance_credentials tf-demo10c-win2016 {
  instance_id = oci_core_instance.tf-demo10c-win2016.id
}

output Instance_Win2016 {
  value = <<EOF


  ---- You can RDP directly to the Win2016 instance using following parameters
  public IP = ${oci_core_instance.tf-demo10c-win2016.public_ip}
  user      = ${data.oci_core_instance_credentials.tf-demo10c-win2016.username} or opc2
  password  = ${random_string.windows_password.result}

EOF
}
