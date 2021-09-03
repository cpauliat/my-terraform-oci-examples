# ------ Get the public IP of the DBsystem and display it on screen
# Get DB node list
data oci_database_db_nodes tf-demo05-vm {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.tf-demo05-db-vm.id
}

# Get DB node details
data oci_database_db_node tf-demo05-vm {
  db_node_id = data.oci_database_db_nodes.tf-demo05-vm.db_nodes[0]["id"]
}

# Get the OCID of the first (default) vNIC
data oci_core_vnic tf-demo05-vm {
  vnic_id = data.oci_database_db_node.tf-demo05-vm.vnic_id
}

output DB_SYSTEM {
  value = <<EOF


  ---- You can SSH directly to the Database system by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${data.oci_core_vnic.tf-demo05-vm.public_ip_address}
  
  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh dbs"

  Host dbs
          Hostname ${data.oci_core_vnic.tf-demo05-vm.public_ip_address}
          User opc
          IdentityFile ${var.ssh_private_key_file}

  ---- Connection to Oracle Database CDB and 1st PDB
  Use following password for SYS and SYSTEM accounts: ${random_string.tf-demo05-dbs-passwd.result}

  ---- Connection to Oracle Database 2nd PDB
  Use following password for SYS and SYSTEM accounts: ${random_string.tf-demo05-pdb2-passwd.result}

EOF

}
