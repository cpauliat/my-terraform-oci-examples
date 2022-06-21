# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# --------- Get the OCID for the most recent for Oracle Linux 8.x disk image
data oci_core_images ImageOCID-ol8 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"

  # filter to keep only Oracle Linux 8.x non-GPU images
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-8..-202.*$"]
    regex  = true
  }
}
