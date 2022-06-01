resource oci_database_db_home cluster3_dbhome3 {
    vm_cluster_id = oci_database_vm_cluster.cluster3.id
    display_name  = var.dbhome3_display_name
    source        = "VM_CLUSTER_NEW"
    freeform_tags = { "Department" = "cpauliat" }    
    db_version    = var.dbhome3_version
    # ~ db_version  = "19.7.0.0.0" -> "19.13.0.0.0" # forces replacement

    database {
        admin_password = var.db_admin_password
        db_name        = "CPA31"
        character_set  = var.db_character_set
        ncharacter_set = var.db_ncharacter_set
        db_workload    = var.db_workload
        pdb_name       = var.db_pdb_name
        freeform_tags  = { "Department" = "cpauliat" } 
    }
    
    timeouts {
        create = "120m"
    }
}

