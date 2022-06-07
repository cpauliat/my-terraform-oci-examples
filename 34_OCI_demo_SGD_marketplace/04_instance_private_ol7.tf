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

# ---- Generate a random string to be used as password for opc user on OL7 desktop
resource random_string tf-demo34-ol7-opc-password {
  # must contains at least 2 upper case letters,
  # 2 lower case letters, 2 numbers and 2 special characters
  length      = 16
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#+-="   # use only special characters in this list
}

# ------ Create a compute instance for OL7 desktop
resource oci_core_instance tf-demo34-ol7-desktop {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo34-ol7-desktop"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo34-private-subnet.id
    hostname_label   = "ol7-desktop"
    assign_public_ip = "false"
  }

  metadata = {
    ssh_authorized_keys   = file(var.ssh_public_key_file_ol7_desktop)
    user_data             = base64encode(file(var.BootStrapFile_ol7_desktop))
    myarg_opc_password    = random_string.tf-demo34-ol7-opc-password.result
  }
}

#output "opc_password" {
#  value = random_string.tf-demo34-ol7-opc-password.result
#}
