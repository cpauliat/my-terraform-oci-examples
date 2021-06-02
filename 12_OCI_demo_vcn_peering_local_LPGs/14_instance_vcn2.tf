# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images OLImageOCID-ol7-vcn2 {
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

# ------ Create a test compute instance (Oracle Linux 7) in VCN2
resource oci_core_instance demo12-vcn2 {
  availability_domain = data.oci_identity_availability_domains.vcn2ADs.availability_domains[var.vcn2_instance_AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "demo12-vcn2"
  shape               = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.OLImageOCID-ol7-vcn2.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.vcn2-pubnet.id
    hostname_label = var.dns_hostname2
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
  }
}

# ------ Outputs
output Instance_VCN2 {
  value = <<EOF


  ---- You can SSH to the instance in VCN2 by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.demo12-vcn2.public_ip}

  ---- You can then ping instance in VCN1 using private IP address
  ping ${oci_core_instance.demo12-vcn1.private_ip}

  ---- In this Terraform example, I also added the DNS private view for VCN1 to DNS resolver for VCN2
  ---- so, you can also ping instance in VCN1 using DNS hostname
  ping ${var.dns_hostname1}.${var.dns_label_public1}.${var.dns_label_vcn1}.oraclevcn.com

EOF
}
