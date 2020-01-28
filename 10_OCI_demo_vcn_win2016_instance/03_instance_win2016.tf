# --------- Get the OCID for the more recent for Windows 2016 disk image
data "oci_core_images" "ImageOCID-win2016" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Windows"
  operating_system_version = "Server 2016 Standard"

  # filter to remove E2 images
  filter {
      name   = "display_name"
      values = ["Windows-Server-2016-Standard-Edition-VM-Gen2-2019"]
      regex  = true
  }
}

# ------ generate a random password to replace the temporary password in the cloud-init post-provisioning task
resource "random_string" "windows_password" {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  number      = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#-_"   # use only special characters in this list
}

# ------ Create a block volume
resource "oci_core_volume" "tf-demo10-win2016-vol1" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo10-win2016-vol1"
  size_in_gbs         = "100"
}

# ------ Attach the new block volume to the Windows compute instance after it is created
resource "oci_core_volume_attachment" "tf-demo10-win2016-vol1-attach" {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.tf-demo10-win2016.id
  volume_id       = oci_core_volume.tf-demo10-win2016-vol1.id
}

# ------ Create a compute instance from the most recent Windows 2016 image
resource "oci_core_instance" "tf-demo10-win2016" {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo10-win2016"
  preserve_boot_volume = "false"
  shape                = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-win2016.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo10-public-subnet1.id
    hostname_label = "tf-demo10-win2016"
  }

  metadata = {
    user_data      = base64encode(file(var.BootStrapFile_win2016))
    myarg_password = random_string.windows_password.result
  }
}

# ------ Display connection details
data "oci_core_instance_credentials" "tf-demo10-win2016" {
  instance_id = oci_core_instance.tf-demo10-win2016.id
}

output "Instance_Win2016" {
  value = <<EOF


  ---- You can RDP directly to the Win2016 instance using following parameters
  public IP = ${oci_core_instance.tf-demo10-win2016.public_ip}
  user      = ${data.oci_core_instance_credentials.tf-demo10-win2016.username}
  password  = ${random_string.windows_password.result}


EOF

  # Password is changed from temporary password (see below) by cloud-init
  # password  = ${data.oci_core_instance_credentials.tf-demo10-win2016.password}
}