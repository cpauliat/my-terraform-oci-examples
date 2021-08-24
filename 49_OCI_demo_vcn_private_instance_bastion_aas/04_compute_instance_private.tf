# ------ Create a compute instance on the private subet
resource oci_core_instance demo49-private {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_private - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "demo49-private"
  shape               = "VM.Standard.E2.1"
  preserve_boot_volume = "false"

  agent_config {
    plugins_config {
      name          = "Bastion"
      desired_state = "ENABLED"
    }
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.demo49-private-subnet.id
    hostname_label   = "private"
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_private)
    user_data           = base64encode(file(var.BootStrapFile))
  }
}
