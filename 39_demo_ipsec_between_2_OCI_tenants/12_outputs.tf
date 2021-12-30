# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d39t2-libreswan
          Hostname ${oci_core_instance.demo39t2-libreswan.public_ip}
          User opc
          IdentityFile ${var.tenant2_ssh_private_key_file_ol7}
Host d39t1-test
          Hostname ${oci_core_instance.demo39t1-test.public_ip}
          User opc
          IdentityFile ${var.tenant1_ssh_private_key_file_ol7}
Host d39t2-test
          Hostname ${oci_core_instance.demo39t2-test.public_ip}
          User opc
          IdentityFile ${var.tenant2_ssh_private_key_file_ol7}
EOF

  filename = "sshcfg"
}

# ------ Display the complete ssh commands needed to connect to the compute instances
output CONNECTIONS {
  value = <<EOF

  1) ---- SSH connection to compute instances
     Run one of following commands on your Linux/MacOS desktop/laptop

     ssh -F sshcfg d39t2-libreswan        to connect to libreswan instance on tenant #2
     ssh -F sshcfg d39t1-test             to connect to test instance on tenant #1
     ssh -F sshcfg d39t2-test             to connect to test instance on tenant #2

  2) ---- TEST IPsec connection from LIBRESWAN instance in tenant #2 to TEST instance in tenant #1
     ssh -F sshcfg d39t2-libreswan
     ping ${oci_core_instance.demo39t1-test.private_ip}

  3) ---- TEST IPsec connection from TEST instance in tenant #2 to TEST instance in tenant #1
     ssh -F sshcfg d39t2-test
     ping ${oci_core_instance.demo39t1-test.private_ip}

  4) ---- TEST IPsec connection from TEST instance in tenant #1 to LIBRESWAN instance in tenant #2
     ssh -F sshcfg d39t1-test
     ping ${oci_core_instance.demo39t2-libreswan.private_ip}

  5) ---- TEST IPsec connection from TEST instance in tenant #1 to TEST instance in tenant #2
     ssh -F sshcfg d39t1-test
     ping ${oci_core_instance.demo39t2-test.private_ip}

  6) ---- Check IPsec connection status
     ssh -F sshcfg d39t2-libreswan
     sudo ipsec status

EOF

}