
# ------ Create an Oracle Linux 7 compute instance for BASTION
resource oci_core_instance demo17-bastion {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "d17bastion"
  preserve_boot_volume = "false"
  shape                = "VM.Standard.E2.1"

  create_vnic_details {
    subnet_id        = oci_core_subnet.demo17-bastion.id
    hostname_label   = "bastion"
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_bastion)
    #user_data           = base64encode(file(var.bastion_cloud_init_file))
  }
}
