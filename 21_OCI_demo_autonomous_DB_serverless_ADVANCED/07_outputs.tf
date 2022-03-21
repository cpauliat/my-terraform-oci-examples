# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d21bastion
          Hostname ${oci_core_instance.tf-demo21-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}
          StrictHostKeyChecking no
Host d21dbclient-opc
          Hostname ${oci_core_instance.tf-demo21-dbclient.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_dbclient}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d21bastion
Host d21dbclient-oracle
          Hostname ${oci_core_instance.tf-demo21-dbclient.private_ip}
          User oracle
          IdentityFile ${var.ssh_private_key_file_dbclient}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d21bastion
EOF

  filename = "sshcfg"
}

# ------ Display the complete ssh commands needed to connect to the compute instances
output DB_client {
  value = <<EOF

  1) ---- Connection to Database client host (Oracle Linux 7 instance with Oracle Instant Client) thru bastion host
     Run one of following commands on your Linux/MacOS desktop/laptop

     ssh -F sshcfg d21dbclient-opc          (to connect as user opc)
     ssh -F sshcfg d21dbclient-oracle       (to connect as user oracle, after a few minutes wait)

     note: you can connect to bastion host with:    ssh -F sshcfg d21bastion

  2) ---- Connection to ADB instance (medium service) with sqlplus
     ssh -F sshcfg d21dbclient-oracle
     ./sqlplus.sh

  3) ---- Connection to ADB instance (medium service) with SQLcl (SQL Developer command line)
     ssh -F sshcfg d21dbclient-oracle
     ./sqlcl.sh

     DB password = ${random_string.tf-demo21-adb-password.result}
EOF

}
