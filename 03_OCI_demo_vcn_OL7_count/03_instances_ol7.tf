# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to avoid Oracle Linux 7.x images for GPU and ARM
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}

# ------ Create several compute instances from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo03-ol7 {
  count                = var.number_of_instances

  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  #display_name         = "tf-demo03-ol7-${count.index}"
  display_name         = var.instances_name[count.index]
  shape                = var.instances_shape[count.index]
  preserve_boot_volume = "false"

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo03-public-subnet1.id
    hostname_label = var.instances_hostname[count.index]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.instances_post_prov[count.index]))
  }
}

# ------ Display the complete ssh command needed to connect to the instances

output SSH_connections {
  value = [
    for instance in oci_core_instance.tf-demo03-ol7.*:
      "${var.instances_name[index(oci_core_instance.tf-demo03-ol7.*, instance)]}: ssh -i ${var.ssh_private_key_file_ol7} opc@${instance.public_ip}"
  ]

}
