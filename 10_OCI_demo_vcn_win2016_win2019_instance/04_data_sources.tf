# --------- Get the OCID for the more recent for Windows 2016/2019 disk image
data oci_core_images ImageOCID-win201x {
  compartment_id           = var.compartment_ocid
  operating_system         = "Windows"
  operating_system_version = "Server ${var.os_version} Standard"

  # filter to remove E2, E3 and B1 images
  filter {
      name   = "display_name"
      values = ["Windows-Server-${var.os_version}-Standard-Edition-VM-Gen2-202"]
      regex  = true
  }
}