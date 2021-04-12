# ------ Generate a random password for DB system
resource random_string tf-demo05c-dbs-passwd {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  number      = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#-_"   # use only special characters in this list
}

# ------ Create a DB System on shape VM.Standard.*
resource oci_database_db_system tf-demo05c-db-vm {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  cpu_core_count      = var.VM-CPUCoreCount
  database_edition    = var.VM-DBEdition

  db_home {
    database {
      admin_password = random_string.tf-demo05c-dbs-passwd.result
      db_name        = var.VM-DBName
      character_set  = var.VM-CharacterSet
      ncharacter_set = var.VM-NCharacterSet
      db_workload    = var.VM-DBWorkload
      pdb_name       = var.VM-PDBName
    }

    db_version   = var.VM-DBVersion
    display_name = var.VM-DBDisplayName
  }

  shape     = var.VM-DBNodeShape
  subnet_id = oci_core_subnet.tf-demo05c-public-subnet1.id

  # Storage Management: ASM or LVM (filesystem)
  db_system_options {
    storage_management = var.VM-StorageMgt
  }

  # trimspace needed as a workaround to issue https://github.com/hashicorp/terraform/issues/7889
  ssh_public_keys         = [trimspace(file(var.ssh_public_key_file))]
  display_name            = var.VM-DBNodeDisplayName
  domain                  = "${var.dns_subnet1}.${var.dns_vcn}.oraclevcn.com"
  hostname                = var.VM-DBNodeHostName
  data_storage_size_in_gb = var.VM-DataStorageSizeInGB
  license_model           = var.VM-LicenseModel
  node_count              = var.VM-NodeCount
}

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

# ------ Get the public IP of the PRIMARY DB system and display it on screen
# Get DB node list
data oci_database_db_nodes tf-demo05c-vm {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.tf-demo05c-db-vm.id
}

# Get DB node details
data oci_database_db_node tf-demo05c-vm {
  db_node_id = data.oci_database_db_nodes.tf-demo05c-vm.db_nodes[0]["id"]
}

# Get the OCID of the first (default) vNIC
data oci_core_vnic tf-demo05c-vm {
  vnic_id = data.oci_database_db_node.tf-demo05c-vm.vnic_id
}

output PRIMARY_DB_SYSTEM {
  value = <<EOF


  ---- You can SSH directly to the PRIMARY database system by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${data.oci_core_vnic.tf-demo05c-vm.public_ip_address}
  
  ---- SQLPLUS connection to Oracle Database once SSH-connected with user opc
  sudo su - oracle
  . oraenv            (database name is ${var.VM-DBName})
  sqlplus / as sysdba

  Note: password for PDBUSER (in PDB only), SYS and SYSTEM accounts is ${random_string.tf-demo05c-dbs-passwd.result}

  ---- Check Data Guard database role in SQLPLUS (should be PRIMARY)
  select database_role from v$database;

  ---- Create a test table in the database in SQLPLUS
  alter session set container=${var.VM-PDBName};
  create table toto (name varchar2(20));
  insert into toto values ('Christophe');
  select * from toto;

EOF

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
