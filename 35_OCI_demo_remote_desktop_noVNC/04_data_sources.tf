# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to exclude Oracle Linux 7.x images for GPU and ARM
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}

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

locals {
  ol7_non_gpu_image_id = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  ol7_gpu_image_id     = data.oci_core_images.ImageOCID-ol7-gpu.images[0]["id"]
  is_flex_shape        = (upper(substr(var.shape, -4, 4)) == "FLEX") 
  is_gpu_shape         = contains(regex("^(?:.*(GPU))?.*$",upper(var.shape)),"GPU")
}

output is_flex_shape { value = local.is_flex_shape }
output is_gpu_shape { value = local.is_gpu_shape }

# ------ Generate a random password for VNC user opc
resource random_string vnc_password_opc {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#_-"   # use only special characters in this list
}

locals {
  #vnc_password_opc = random_string.vnc_password_opc.result
  vnc_password_opc = var.vnc_password_opc

  BootStrapFile_rdesktop = local.is_gpu_shape ? var.BootStrapFile_rdesktop_gpu : var.BootStrapFile_rdesktop_non_gpu
}
