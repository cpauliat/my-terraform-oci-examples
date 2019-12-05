
# -------- get the list of available ADs
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# ------ Create a compute instance
resource "oci_core_instance" "tf-instance" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_name
  shape               = var.shape

  source_details {
    source_type = "image"
    source_id   = var.image_ocid
  }

  create_vnic_details {
    subnet_id      = var.subnet_ocid
    hostname_label = var.hostname
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
  }
}