# --------- Get the OCID of the Windows 2019 disk image compatible with the selected shape
# --        IMPORTANT: some shapes don't have Windows 2019 disk image
locals {
  shape_abbr      = replace(var.shape, "/[0-9]*$/", "")    # Remove nb of OCPUS/GPUs at the end of shape name (for non flexible shape)
  shape_to_filter = tomap({
    "VM.Standard2.":          "Windows-Server-2019-Standard-Edition-VM-Gen2-202",
    "VM.DenseIO2.":           "Windows-Server-2019-Standard-Edition-VM-Gen2-202",
    "VM.GPU2.":               "Windows-Server-2019-Standard-Edition-VM-Gen2-202",
    "VM.GPU3.":               "Windows-Server-2019-Standard-Edition-VM-Gen2-202",
    "VM.Standard.E3.Flex":    "Windows-Server-2019-Standard-Edition-VM-E3-202",
    "VM.Standard.E4.Flex":    "Windows-Server-2019-Standard-Edition-VM-E3-202",
    "VM.Optimized3.Flex":     "Windows-Server-2019-Standard-Edition-VM-202",
    "VM.Standard3.Flex":      "Windows-Server-2019-Standard-Edition-VM-202",
    "VM.Standard.E2.":        "Windows-Server-2019-Standard-Edition-VM-202",
    "VM.Standard.E2.1.Micro": "Windows-Server-2019-Standard-Edition-VM-202",
    "VM.Standard1.":          "Windows-Server-2019-Standard-Edition-VM-202",
    "VM.Standard.B1.":        "Windows-Server-2019-Standard-Edition-VM-202",
    "VM.Standard1.":          "Windows-Server-2019-Standard-Edition-VM-202",
    "BM.Standard3.":          "Windows-Server-2019-Datacenter-Edition-BM-X9-202",
    "BM.Optimized3.":         "Windows-Server-2019-Datacenter-Edition-BM-X9-202",
    "BM.Standard.E3.":         "Windows-Server-2019-Datacenter-Edition-BM-E3-202",
    "BM.Standard.E4.":         "Windows-Server-2019-Datacenter-Edition-BM-E4-202",
  })
  filter     = local.shape_to_filter[local.shape_abbr]
  image_id   = data.oci_core_images.ImageOCID-win2019.images[0]["id"]
  image_name = data.oci_core_images.ImageOCID-win2019.images[0]["display_name"]
}

data oci_core_images ImageOCID-win2019 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Windows"

  # filter to keep only compatibles images
  filter {
      name   = "display_name"
      values = [ local.filter ]
      regex  = true
  }
}

# # --------- Get the OCID for the most recent Windows 2019 Standard Edition disk image (virtual machines shapes)

# # ---- Images compatibles with VM.Standard2.x, VM.DenseIO2.x, VM.GPU2.X and VM.GPU3.x
# data oci_core_images ImageOCID-win2019-vm-x7-gpu23 {
#   compartment_id           = var.compartment_ocid
#   operating_system         = "Windows"
#   operating_system_version = "Server 2019 Standard"

#   # filter to keep only compatibles images
#   # Example: Windows-Server-2019-Standard-Edition-VM-Gen2-2022.01.11-0
#   filter {
#       name   = "display_name"
#       values = ["Windows-Server-2019-Standard-Edition-VM-Gen2-202"]
#       regex  = true
#   }
# }

# # ---- Images compatibles with shapes VM.Standard.E3.Flex and VM.Standard.E4.Flex
# data oci_core_images ImageOCID-win2019-vm-e3-e4 {
#   compartment_id           = var.compartment_ocid
#   operating_system         = "Windows"
#   operating_system_version = "Server 2019 Standard"

#   # filter to keep only compatibles images
#   # Example: Windows-Server-2019-Standard-Edition-VM-E3-2021.03.17-0
#   filter {
#       name   = "display_name"
#       values = ["Windows-Server-2019-Standard-Edition-VM-E3-202"]
#       regex  = true
#   }
# }

# # ---- Images compatibles with shapes VM.Standard3.Flex, VM.Optimized3.Flex, VM.Standard1.x, VM.DenseIO1.x, 
# # ---- VM.Standard.B1.x, VM.Standard.E2.x, VM.Standard.E3.Flex and VM.Standard.E4.Flex
# data oci_core_images ImageOCID-win2019-vm-others {
#   compartment_id           = var.compartment_ocid
#   operating_system         = "Windows"
#   operating_system_version = "Server 2019 Standard"

#   # filter to keep only compatibles images
#   # Example: Windows-Server-2019-Standard-Edition-VM-2022.01.11-0
#   filter {
#       name   = "display_name"
#       values = ["Windows-Server-2019-Standard-Edition-VM-202"]
#       regex  = true
#   }
# }

# # --------- Get the OCID for the most recent Windows 2019 Datacenter Edition disk image (bare metal shapes)
# data oci_core_images ImageOCID-win2019-bm-x9 {
#   compartment_id           = var.compartment_ocid
#   operating_system         = "Windows"
#   operating_system_version = "Server 2019 Standard"

#   # filter to only images for X9 shapes
#   filter {
#       name   = "display_name"
#       values = ["Windows-Server-2019-Datacenter-Edition-BM-X9-202"]
#       regex  = true
#   }
# }

# data oci_core_images ImageOCID-win2019-bm-e4 {
#   compartment_id           = var.compartment_ocid
#   operating_system         = "Windows"
#   operating_system_version = "Server 2019 Datacenter"

#   # filter to only images for E4 shapes
#   filter {
#       name   = "display_name"
#       values = ["Windows-Server-2019-Datacenter-Edition-BM-E4-202"]
#       regex  = true
#   }
# }

# data oci_core_images ImageOCID-win2019-bm-e3 {
#   compartment_id           = var.compartment_ocid
#   operating_system         = "Windows"
#   operating_system_version = "Server 2019 Datacenter"

#   # filter to only images for E3 shapes
#   filter {
#       name   = "display_name"
#       values = ["Windows-Server-2019-Datacenter-Edition-BM-E3-202"]
#       regex  = true
#   }
# }

# -- List of Windows 2019 disk images on Feb 7, 2020
# Windows-Server-2019-Standard-Edition-VM-Gen2-2022.01.11-0
# Windows-Server-2019-Standard-Edition-VM-Gen2-2021.11.09-0
# Windows-Server-2019-Standard-Edition-VM-Gen2-2021.10.12-0
# Windows-Server-2019-Standard-Edition-VM-E3-2021.03.17-0
# Windows-Server-2019-Standard-Edition-VM-E3-2021.03.09-0
# Windows-Server-2019-Standard-Edition-VM-2022.01.11-0
# Windows-Server-2019-Standard-Edition-VM-2021.11.09-0
# Windows-Server-2019-Standard-Edition-VM-2021.10.12-0
# Windows-Server-2019-Standard-Core-VM-2022.01.11-0
# Windows-Server-2019-Standard-Core-VM-2021.11.09-0
# Windows-Server-2019-Standard-Core-VM-2021.10.12-0
# Windows-Server-2019-Datacenter-Edition-BM-X9-2022.01.12-0
# Windows-Server-2019-Datacenter-Edition-BM-X9-2021.11.10-0
# Windows-Server-2019-Datacenter-Edition-BM-X9-2021.10.13-0
# Windows-Server-2019-Datacenter-Edition-BM-E4-2022.01.11-0
# Windows-Server-2019-Datacenter-Edition-BM-E4-2021.11.09-0
# Windows-Server-2019-Datacenter-Edition-BM-E4-2021.10.12-0
# Windows-Server-2019-Datacenter-Edition-BM-E3-2022.01.11-0
# Windows-Server-2019-Datacenter-Edition-BM-E3-2021.11.09-0
# Windows-Server-2019-Datacenter-Edition-BM-E3-2021.10.12-0