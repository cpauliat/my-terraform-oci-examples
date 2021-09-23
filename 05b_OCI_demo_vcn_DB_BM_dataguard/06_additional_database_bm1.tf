resource oci_database_db_home db_home2 {
    database {
        admin_password      = var.BM1-DBAdminPassword
        character_set       = var.BM1-CharacterSet
        ncharacter_set      = var.BM1-NCharacterSet
        db_name             = "DB2"
        db_workload         = "OLTP"
        pdb_name            = "PDB1"
        tde_wallet_password = var.BM1-DBAdminPassword
    }
    db_system_id = oci_database_db_system.tf-demo05b-db-bm1.id
    db_version   = var.BM1-DBVersion
    display_name = "DBHOME2"
}