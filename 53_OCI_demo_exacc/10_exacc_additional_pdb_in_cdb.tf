# ---- get the OCID of the first database in the DB home
data oci_database_databases demo {
    compartment_id = var.vmcluster_compartment_id
    db_home_id     = oci_database_db_home.cluster3_dbhome2.id
    db_name        = var.dbhome2_db1_name
}

locals {
    id_dbhome2_cdb1 = data.oci_database_databases.demo.databases[0].id
}

# ---- create a second PDB in this database
resource oci_database_pluggable_database pdb2 {
    container_database_id = local.id_dbhome2_cdb1
    pdb_name              = var.dbhome2_db1_pdb2_name
    pdb_admin_password    = var.db_admin_password
    tde_wallet_password   = var.db_admin_password

    # #Optional
    # should_pdb_admin_account_be_locked = var.pluggable_database_should_pdb_admin_account_be_locked
}

# oci_database_pluggable_database.pdb2: Creation complete after 4m49s
# oci_database_pluggable_database.pdb2: Creation complete after 5m28s
# oci_database_pluggable_database.pdb2: Destruction complete after 2m52s