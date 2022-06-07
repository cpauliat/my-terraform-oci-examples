# ---- Generate a random string to be used as password for ADB admin user
resource random_string tf-demo20-adb-password {
  # must contains at least 2 upper case letters, 
  # 2 lower case letters, 2 numbers and 2 special characters
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

resource oci_database_autonomous_database tf-demo20-adb {
  db_workload              = var.adb_type
  admin_password           = random_string.tf-demo20-adb-password.result
  #admin_password           = var.adb_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.adb_cpu_core_count
  data_storage_size_in_tbs = var.adb_data_storage_tbs
  db_name                  = var.adb_db_name

  #Optional
  display_name             = var.adb_display_name
  license_model            = var.adb_license_model
  is_auto_scaling_enabled  = var.adb_autoscaling_enabled
  whitelisted_ips          = var.adb_whitelisted_ips
}

output ADB {
  value = <<EOF

  service console URL = ${oci_database_autonomous_database.tf-demo20-adb.service_console_url}
            user      = admin
            password  = ${random_string.tf-demo20-adb-password.result}
EOF
#            password  = ${var.adb_password}
}
