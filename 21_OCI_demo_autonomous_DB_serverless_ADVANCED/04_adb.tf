# ---- OCI bucket for manual backups
# -- see https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/adbbackingup.htm

data oci_objectstorage_namespace tf-demo21-ns {
  compartment_id = var.compartment_ocid
}

resource oci_objectstorage_bucket tf-demo21-adb {
  compartment_id = var.compartment_ocid
  name           = "backup_${var.adb_db_name}"         # this name must not be changed (expected name)
  namespace      = data.oci_objectstorage_namespace.tf-demo21-ns.namespace
}

# ---- Generate a random string to be used as password for ADB admin user
resource random_string tf-demo21-adb-password {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 16
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true  
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#+-="   # use only special characters in this list
}

# ---- Create the serverless ADB instance
resource oci_database_autonomous_database tf-demo21-adb {
  db_workload              = var.adb_type
  admin_password           = random_string.tf-demo21-adb-password.result
  #admin_password           = var.adb_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.adb_cpu_core_count
  data_storage_size_in_tbs = var.adb_data_storage_tbs
  db_name                  = var.adb_db_name

  display_name             = var.adb_display_name
  license_model            = var.adb_license_model
  is_auto_scaling_enabled  = var.adb_autoscaling_enabled
  whitelisted_ips          = [ oci_core_vcn.tf-demo21-vcn.id ]
  is_free_tier             = var.adb_is_free_tier
  data_safe_status         = var.adb_data_safe_status 
}

# ---- Generate and download a Wallet 
#data "oci_database_autonomous_database_wallet" "tf-demo21-adb-wallet" {
#  autonomous_database_id = oci_database_autonomous_database.tf-demo21-adb.id
#  password               = var.adb_wallet_password
#  generate_type          = var.adb_wallet_type
#  base64_encode_content  = "true"
#}

#resource "local_file" "tf-demo21-adb-wallet" {
#  content_base64 = data.oci_database_autonomous_database_wallet.tf-demo21-adb-wallet.content
#  filename       = var.adb_wallet_filename
#}

resource oci_database_autonomous_database_wallet tf-demo21-adb-wallet {
  autonomous_database_id = oci_database_autonomous_database.tf-demo21-adb.id
  password               = var.adb_wallet_password
  generate_type          = var.adb_wallet_type
  base64_encode_content  = "true"
}

resource local_file tf-demo21-adb-wallet {
  content_base64 = oci_database_autonomous_database_wallet.tf-demo21-adb-wallet.content
  filename       = var.adb_wallet_filename
}

# ---- outputs
output ADB_instance {
  value = <<EOF

  service console URL = ${oci_database_autonomous_database.tf-demo21-adb.service_console_url}
            user      = admin
            password  = ${random_string.tf-demo21-adb-password.result}
EOF
#            password  = ${var.adb_password}
}
