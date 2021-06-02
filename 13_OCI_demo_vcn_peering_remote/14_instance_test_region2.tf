# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images OLImageOCID-ol7-r2 {
  provider                 = oci.r2
  compartment_id           = var.r2_compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to avoid Oracle Linux 7.x images for GPU and ARM
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}

# ------ Create a test compute instance (Oracle Linux 7) in region 1
resource oci_core_instance tf-demo13-r2 {
  provider            = oci.r2
  availability_domain = data.oci_identity_availability_domains.r2ADs.availability_domains[var.r2_AD - 1]["name"]
  compartment_id      = var.r2_compartment_ocid
  display_name        = "tf-demo13-r2"
  shape               = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.OLImageOCID-ol7-r2.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.r2-pubnet.id
    hostname_label = var.dns_hostname2
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
  }
}
