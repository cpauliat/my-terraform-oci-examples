# --------- Get the OCID for the more recent for Oracle Linux 7.x disk image
data "oci_core_images" "ImageOCID-ol7" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.8"

  # filter to keep only Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.8-[^G].*$"]
    regex  = true
  }
}