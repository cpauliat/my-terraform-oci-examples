output Instance_TENANT1 {
  value = <<EOF


  ---- You can SSH to the instance in TENANT1 by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.demo12b-tenant1.public_ip}

  ---- You can then ping instance in TENANT2 using private IP address
  ping -c 2 ${oci_core_instance.demo12b-tenant2.private_ip}

  ---- You can then ping instance in TENANT2 using private DNS hostname
  ping -c 2 ${var.dns_hostname2}.${var.dns_label_public2}.${var.dns_label_tenant2}.oraclevcn.com 

EOF
}

output Instance_TENANT2 {
  value = <<EOF


  ---- You can SSH to the instance in TENANT2 by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.demo12b-tenant2.public_ip}

  ---- You can then ping instance in TENANT1 using private IP address
  ping -c 2 ${oci_core_instance.demo12b-tenant1.private_ip}

  ---- You can then ping instance in TENANT1 using private DNS hostname
  ping -c 2 ${var.dns_hostname1}.${var.dns_label_public1}.${var.dns_label_tenant1}.oraclevcn.com 

EOF
}