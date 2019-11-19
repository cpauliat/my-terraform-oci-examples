resource "random_string" "autonomous_database_admin_password" {
  length  = 16
  special = true
}

resource "oci_database_autonomous_database" "autonomous_database" {
  db_workload              = var.adb_type
  admin_password           = "${random_string.autonomous_database_admin_password.result}"
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

output "ADB" {
  value = <<EOF

  service console URL = "${oci_database_autonomous_database.autonomous_database.service_console_url}
            user      = "admin"
            password  = "${random_string.autonomous_database_admin_password.result}"
EOF
#            password  = "${var.adb_password}"
}