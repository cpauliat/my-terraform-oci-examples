resource oci_database_db_home cluster3_dbhome2 {
    vm_cluster_id              = oci_database_vm_cluster.cluster3.id
    database_software_image_id = oci_database_database_software_image.si.id
    display_name               = "CPA_OH_FROM_IMAGE"       # change here forces replacement 
    source                     = "VM_CLUSTER_NEW"

    database {
        admin_password = var.db_admin_password
        db_name        = var.dbhome2_db1_name
        character_set  = var.db_character_set
        ncharacter_set = var.db_ncharacter_set
        db_workload    = var.db_workload
        pdb_name       = var.db_pdb_name
    }
    
    timeouts {
        create = "120m"
    }
}

# oci_database_db_home.cluster3_dbhome2: Creation complete after 49m2s
# oci_database_db_home.cluster3_dbhome2: Destruction complete after 6m54s
# oci_database_db_home.cluster3_dbhome2: Destruction complete after 6m56s