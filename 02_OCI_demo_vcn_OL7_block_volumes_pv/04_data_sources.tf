# -------- get the list of available ADs
data oci_identity_availability_domains ADs {
  compartment_id = var.tenancy_ocid
}

# --------- Get the OCID for the more recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to keep only Oracle Linux 7.x images for x86-64 server (exclude GPU and ARM A1)
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}
