# About 25 minutes
resource oci_database_database cpa4 {
    database {
        admin_password = var.db_admin_password
        db_name        = "CPA4"
        character_set  = var.db_character_set
        ncharacter_set = var.db_ncharacter_set
        db_workload    = var.db_workload
        pdb_name       = var.db_pdb_name
    }
    db_home_id = oci_database_db_home.cluster3_dbhome2.id
    source     = "NONE"

    timeouts {
        create = "120m"
    }
}
# oci_database_database.cpa4: Creation complete after 30m26s
# oci_database_database.cpa4: Destruction complete after 3m34s
# oci_database_database.cpa4: Destruction complete after 4m37s