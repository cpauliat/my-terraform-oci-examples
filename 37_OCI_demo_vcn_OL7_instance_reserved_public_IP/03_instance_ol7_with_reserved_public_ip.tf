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

# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo37-ol7 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo37-ol7"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo37-public-subnet1.id
    hostname_label   = "tf-demo37-ol7"
    private_ip       = var.reserved_private_ip
    assign_public_ip = false      # No ephemeral public IP assigned
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_ol7)
    user_data           = base64encode(file(var.BootStrapFile_ol7))
  }
}

# ------ Create a reserved public IP and assigned it to the compute instance
data oci_core_private_ips demo37_ol7 {
  subnet_id  = oci_core_subnet.tf-demo37-public-subnet1.id
  ip_address = oci_core_instance.tf-demo37-ol7.private_ip
}

resource oci_core_public_ip demo37_reserved_public_ip {
  # prevent destruction of the public IP by Terraform
  # true must be changed to false to be able to destroy this with Terraform
  lifecycle {
    prevent_destroy = true
  }

  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "tf-demo37-reserved_public_ip"

  # To destroy the compute instance, you must comment the line below and run terraform apply to unassign public IP
  # before destroying it with terraform destroy -target=oci_core_instance.tf-demo37-ol7
  private_ip_id  = lookup(data.oci_core_private_ips.demo37_ol7.private_ips[0],"id")
}

# ------ Display the complete ssh command needed to connect to the instance
output Instance_OL7 {
  value = <<EOF


  ---- You can SSH directly to the OL7 instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_ol7} opc@${oci_core_public_ip.demo37_reserved_public_ip.ip_address}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d37ol7"

  Host d37ol7
          Hostname ${oci_core_public_ip.demo37_reserved_public_ip.ip_address}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7}

  
EOF

}

