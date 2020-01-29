# --------- Get the OCID for the most recent Oracle Linux 7.x image
data "oci_core_images" "OLImageOCID-ol7" {
  compartment_id           = "${var.g_compartment_ocid}"
  operating_system         = "Oracle Linux"
  operating_system_version = "7.7"

  # filter to avoid Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.7-[^G].*$"]
    regex  = true
  }
}

# -------- get the list of available ADs
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.g_tenancy_ocid
}
