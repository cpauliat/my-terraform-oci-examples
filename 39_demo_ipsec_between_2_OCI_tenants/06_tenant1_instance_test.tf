# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance demo39t1-test {
  # ignore change in cloud-init file after provisioning
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  
  provider             = oci.tenant1
  availability_domain  = data.oci_identity_availability_domains.demo39t1-ADs.availability_domains[var.tenant1_AD - 1]["name"]
  compartment_id       = var.tenant1_compartment_ocid
  display_name         = "demo39t1"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7-t1.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.demo39t1-public-subnet-test.id
    hostname_label = "d39t1-test"
  }

  metadata = {
    ssh_authorized_keys = file(var.tenant1_ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.tenant1_BootStrapFile_test))
  }
}