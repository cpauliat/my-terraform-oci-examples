# ------ Enable data guard for the DB instance in DBS #1
# ------ (this will create another DB instance with same name in DBS #2)
resource oci_database_data_guard_association tf-demo05b-db1 {
    creation_type           = "ExistingDbSystem"         # For Bare Metal DB system, destination DB system must already exist
    database_admin_password = var.BM1-DBAdminPassword
    protection_mode         = "MAXIMUM_PERFORMANCE"      # only supported mode in January 2020
    transport_type          = "ASYNC"                    # only supported type in January 2020   
    delete_standby_db_home_on_delete = "true"
    
    # normal situation
    database_id             = oci_database_db_system.tf-demo05b-db-bm1.db_home[0].database[0].id
    peer_db_system_id       = oci_database_db_system.tf-demo05b-db-bm2.id
}
