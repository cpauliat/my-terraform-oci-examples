# ------ Create a test compute instance (Oracle Linux 7) in VCN2
resource oci_core_instance demo12d-vcn2 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.vcn2_instance_AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "demo12d-vcn2"
  shape               = "VM.Standard2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
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
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.demo12d-vcn2.public_ip}

  ---- You can then ping instances in other VCNs using private IP address
  ping -c 2 ${oci_core_instance.demo12d-vcn1.private_ip}     
  ping -c 2 ${oci_core_instance.demo12d-vcn3.private_ip}     

  ---- In this Terraform example, I also added the DNS private views for VCN3 and VCN1 to DNS resolver for VCN2
  ---- so, you can also ping instances in other VCNs using DNS hostname
  ping -c 2 ${var.dns_hostname3}.${var.dns_label_public3}.${var.dns_label_vcn3}.oraclevcn.com
  ping -c 2 ${var.dns_hostname1}.${var.dns_label_public1}.${var.dns_label_vcn1}.oraclevcn.com

EOF
}
