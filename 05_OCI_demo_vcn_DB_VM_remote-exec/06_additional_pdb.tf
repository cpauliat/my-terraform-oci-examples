resource random_string tf-demo05-pdb2-passwd {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#-_"   # use only special characters in this list
}

# in this case (VM DB system), we can have a single CDB and single DBhome in the DB system
data oci_database_db_homes demo05_dbhomes {
    compartment_id = var.compartment_ocid
    db_system_id   = oci_database_db_system.tf-demo05-db-vm.id
}

data oci_database_databases demo05_cdb {
    compartment_id = var.compartment_ocid
    system_id      = oci_database_db_system.tf-demo05-db-vm.id
    db_home_id     = data.oci_database_db_homes.demo05_dbhomes.db_homes[0].id
}

resource oci_database_pluggable_database tf-demo05-pdb2 {
    container_database_id = data.oci_database_databases.demo05_cdb.databases[0].id
    pdb_admin_password    = random_string.tf-demo05-pdb2-passwd.result
    tde_wallet_password   = random_string.tf-demo05-dbs-passwd.result
    pdb_name              = var.VM-PDB2-Name
}