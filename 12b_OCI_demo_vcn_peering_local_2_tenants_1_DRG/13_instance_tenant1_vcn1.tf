# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7-tenant1 {
  provider                 = oci.tenant1
  compartment_id           = var.compartment_ocid1
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to avoid Oracle Linux 7.x images for GPU and ARM
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}

# ------ Create a test compute instance (Oracle Linux 7) in tenant 1
resource oci_core_instance demo12b-tenant1 {
  provider            = oci.tenant1
  availability_domain = data.oci_identity_availability_domains.tenant1ADs.availability_domains[var.tenant1_instance_AD - 1]["name"]
  compartment_id      = var.compartment_ocid1
  display_name        = "demo12b-tenant1"
  shape               = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7-tenant1.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tenant1-pubnet.id
    hostname_label = var.dns_hostname1
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
  }
}
