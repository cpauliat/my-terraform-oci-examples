# ------ Configure Dataguard
resource oci_database_data_guard_association tf-demo05c-db1 {
    creation_type           = "NewDbSystem"             # For VM DB system, destination DB system is provisioned automatically
    database_admin_password = random_string.tf-demo05c-dbs-passwd.result
    database_id             = oci_database_db_system.tf-demo05c-db-vm.db_home[0].database[0].id
    protection_mode         = "MAXIMUM_PERFORMANCE"      # only supported mode in August 2020
    transport_type          = "ASYNC"                    # only supported type in August 2020
    delete_standby_db_home_on_delete = "true"

    # new DB system
    display_name            = "tf-demo05c-standby"
    hostname                = "standby"
    shape                   = var.VM-DBNodeShape-standby
    availability_domain     = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_standby - 1]["name"]
    subnet_id               = oci_core_subnet.tf-demo05c-public-subnet1.id
}

# ------ Get the public IP of the STANDBY DB system and display it on screen
# Get DB node list
data oci_database_db_nodes tf-demo05c-stdby {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_data_guard_association.tf-demo05c-db1.peer_db_system_id
}

# Get DB node details
data oci_database_db_node tf-demo05c-stdby {
  db_node_id = data.oci_database_db_nodes.tf-demo05c-stdby.db_nodes[0]["id"]
}

# Get the OCID of the first (default) vNIC
data oci_core_vnic tf-demo05c-stdby {
  vnic_id = data.oci_database_db_node.tf-demo05c-stdby.vnic_id
}

output STANDBY_DB_SYSTEM {
  value = <<EOF


  ---- You can SSH directly to the STANDBY database system by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${data.oci_core_vnic.tf-demo05c-stdby.public_ip_address}
  
  ---- SQLPLUS connection to Oracle Database once SSH-connected with user opc
  sudo su - oracle
  . oraenv            (database name is ${var.VM-DBName})
  sqlplus / as sysdba

  Note: password for PDBUSER (in PDB only), SYS and SYSTEM accounts is ${random_string.tf-demo05c-dbs-passwd.result}

  ---- Check Data Guard database role in SQLPLUS (should be PHYSICAL STANDBY)
  select database_role from v$database;

  ---- Try to read table created on PRIMARY database in SQLPLUS 
  ---- (works only with Active Dataguard, ie when edition is Enterprise Edition Extreme Performance)
  alter session set container=${var.VM-PDBName};
  select * from toto;
EOF

}