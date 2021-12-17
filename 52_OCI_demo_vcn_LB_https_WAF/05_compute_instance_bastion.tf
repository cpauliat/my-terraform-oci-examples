# ------ Create a compute instance for bastion host
resource oci_core_instance demo52-bastion {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_bastion - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "demo52-bastion"
  shape               = "VM.Standard.E2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.demo52-public-subnet.id
    hostname_label = "bastion"
    private_ip     = var.bastion_private_ip
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_bastion)
    user_data           = base64encode(file(var.BootStrapFile_bastion))
  }
}
