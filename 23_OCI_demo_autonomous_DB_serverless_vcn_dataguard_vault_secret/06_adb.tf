# ---- Autonomous DB
resource oci_database_autonomous_database tf-demo23-adb {
  db_workload              = var.adb_type
  admin_password           = local.adb_passwd
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.adb_cpu_core_count
  data_storage_size_in_tbs = var.adb_data_storage_tbs
  db_name                  = var.adb_db_name
  display_name             = var.adb_display_name
  license_model            = var.adb_license_model
  is_auto_scaling_enabled  = var.adb_autoscaling_enabled
  is_free_tier             = var.adb_is_free_tier
  data_safe_status         = var.adb_data_safe_status 

  # in VCN subnet: https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/adbsprivateaccess.htm
  nsg_ids                  = [ oci_core_network_security_group.tf-demo23-nsg-adb.id ]
  subnet_id                = oci_core_subnet.tf-demo23-public-subnet1.id
}

# Cannot enable Autonomous Data Guard during database creation
# so, we enable it after provisioning using OCI cli.
resource null_resource tf-demo23-adb {
  depends_on = [ oci_database_autonomous_database.tf-demo23-adb ]
  count      = var.adb_dataguard_enabled ? 1 : 0
  provisioner local-exec {
    command = "oci --profile ${var.oci_cli_profile} db autonomous-database update --autonomous-database-id ${oci_database_autonomous_database.tf-demo23-adb.id} --is-data-guard-enabled true"
  }
}

# ---- Create and Download DB wallet
resource oci_database_autonomous_database_wallet tf-demo23-adb-wallet {
  autonomous_database_id = oci_database_autonomous_database.tf-demo23-adb.id
  password               = var.adb_wallet_password
  generate_type          = var.adb_wallet_type
  base64_encode_content  = "true"
}

resource local_file tf-demo23-adb-wallet {
  content_base64 = oci_database_autonomous_database_wallet.tf-demo23-adb-wallet.content
  filename       = var.adb_wallet_filename
}

# ---- Outputs
output ADB {
  value = <<EOF

  service console URL = ${oci_database_autonomous_database.tf-demo23-adb.service_console_url}
            user      = admin
            password  = ${local.adb_passwd}
EOF
}