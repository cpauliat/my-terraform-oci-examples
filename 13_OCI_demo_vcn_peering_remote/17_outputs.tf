output Instance_VCN1_REGION1 {
  value = <<EOF


  ---- You can SSH to the instance in VCN1/REGION1 by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo13-r1.public_ip}

  ---- You can then ping instance in VCN2/REGION2 using private IP address
  ping ${oci_core_instance.tf-demo13-r2.private_ip}

  ---- You can then ping instance in VCN2/REGION2 using private DNS hostname
  ping ${var.dns_hostname2}.${var.dns_label_public2}.${oci_core_vcn.r2-vcn.vcn_domain_name}  

EOF
}

output Instance_VCN2_REGION2 {
  value = <<EOF


  ---- You can SSH to the instance in VCN2/REGION2 by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo13-r2.public_ip}

  ---- You can then ping instance in VCN1/REGION1 using private IP address
  ping ${oci_core_instance.tf-demo13-r1.private_ip}

  ---- You can then ping instance in VCN1/REGION1 using private DNS hostname
  ping ${var.dns_hostname1}.${var.dns_label_public1}.${oci_core_vcn.r1-vcn.vcn_domain_name}  

EOF
}