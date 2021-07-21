resource oci_database_pluggable_database demo05d_pdb {
    container_database_id = var.cdb_id
    tde_wallet_password   = var.cdb_tde_wallet_password         # TDE password for existing CDB
    pdb_admin_password    = var.pdb_admin_password              # password for new user PDBUSER in the new PDB
    pdb_name              = "PDB10"     
}