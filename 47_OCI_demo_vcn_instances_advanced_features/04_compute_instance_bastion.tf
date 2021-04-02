
# ------ Create an Oracle Linux 7 compute instance for BASTION
resource oci_core_instance demo47-bastion {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "bastion"
  preserve_boot_volume = "false"
  shape                = "VM.Standard.E2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.demo47-public-subnet.id
    hostname_label   = "bastion"
    private_ip       = var.bastion_private_ip
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
    #source_id   = var.ol7_image_ocid
  }

  metadata = {
    ssh_authorized_keys = file(var.bastion_ssh_public_key_file)
    user_data           = base64encode(file(var.bastion_cloud_init_file))
  }
}
