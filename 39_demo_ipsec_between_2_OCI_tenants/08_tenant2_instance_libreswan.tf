

# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance demo39t2-libreswan {
  # ignore change in cloud-init file after provisioning
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
  
  provider             = oci.tenant2
  availability_domain  = data.oci_identity_availability_domains.demo39t2-ADs.availability_domains[var.tenant2_AD - 1]["name"]
  compartment_id       = var.tenant2_compartment_ocid
  display_name         = "demo39t2-libreswan"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7-t2.images[0]["id"]
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.demo39t2-public-subnet-libreswan.id
    hostname_label         = "d39t2-libreswan"
    private_ip             = var.tenant2_libreswan_private_ip
    skip_source_dest_check = "true"
  }

  metadata = {
    ssh_authorized_keys = file(var.tenant2_ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.tenant2_BootStrapFile_libreswan))
  }
}