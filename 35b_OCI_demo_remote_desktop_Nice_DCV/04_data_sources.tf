# --------- Get the OCID for the most recent for Oracle Linux 7.x with NVIDIA GPU drivers disk image
data oci_core_images ImageOCID-ol7-gpu {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to get Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-Gen2-GPU-202.*$"]
    regex  = true
  }
}

# --------- Get the OCID for the most recent for Ubuntu 18.x
data oci_core_images ImageOCID-ubuntu18 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "18.04"

  # filter to exclude minimal and ARM
  filter {
    name   = "display_name"
    values = ["^.*Canonical-Ubuntu-18.04-20.*$"]
    regex  = true
  }
}

output ubuntu {
  value = data.oci_core_images.ImageOCID-ubuntu18.images[0]["id"]
}

locals {
  image_ocid      = var.is_os_ubuntu ? data.oci_core_images.ImageOCID-ubuntu18.images[0]["id"] : data.oci_core_images.ImageOCID-ol7-gpu.images[0]["id"]
  bootstrape_file = var.is_os_ubuntu ? var.BootStrapFile_rdesktop_ubuntu18 : var.BootStrapFile_rdesktop_ol7
  user            = var.is_os_ubuntu ? "ubuntu" : "opc"
}