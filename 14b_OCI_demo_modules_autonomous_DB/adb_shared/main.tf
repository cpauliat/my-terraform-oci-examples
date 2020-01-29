# ---- Generate a password
resource "random_string" "adb1_admin_password" {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 16
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  number      = true  
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#+-="   # use only special characters in this list
}

# ---- OCI bucket for manual backups
# -- see https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/adbbackingup.htm

resource "oci_objectstorage_bucket" "adb1" {
  compartment_id = var.adb_compartment_ocid
  name           = "backup_${var.adb_db_name}"         # this name must not be changed (expected name)
  namespace      = data.oci_objectstorage_namespace.ns.namespace
}

# ---- Serverless autonomous database: ATP or ADW
resource "oci_database_autonomous_database" "adb1" {
  db_workload              = var.adb_type
  admin_password           = random_string.adb1_admin_password.result
  compartment_id           = var.adb_compartment_ocid
  cpu_core_count           = var.adb_cpu_core_count          # not used for free instance
  data_storage_size_in_tbs = var.adb_data_storage_tbs        # not used for free instance
  db_name                  = var.adb_db_name

  display_name             = var.adb_display_name
  license_model            = var.adb_license_model
  is_auto_scaling_enabled  = var.adb_autoscaling_enabled
  whitelisted_ips          = var.adb_whitelisted_ips
  is_free_tier             = var.adb_is_free_tier
}
