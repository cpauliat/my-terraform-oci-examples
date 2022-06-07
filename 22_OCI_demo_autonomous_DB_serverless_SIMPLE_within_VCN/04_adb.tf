# ---- Generate a random string to be used as password for ADB admin user
resource random_string tf-demo22-adb-password {
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

resource oci_database_autonomous_database tf-demo22-adb {
  db_workload              = var.adb_type
  admin_password           = random_string.tf-demo22-adb-password.result
  #admin_password           = var.adb_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = var.adb_cpu_core_count
  data_storage_size_in_tbs = var.adb_data_storage_tbs
  db_name                  = var.adb_db_name

  display_name             = var.adb_display_name
  license_model            = var.adb_license_model
  is_auto_scaling_enabled  = var.adb_autoscaling_enabled
  
  # in VCN subnet
  # https://docs.cloud.oracle.com/en-us/iaas/Content/Database/Concepts/adbsprivateaccess.htm
  nsg_ids                  = [ oci_core_network_security_group.tf-demo22-nsg-adb.id ]
  subnet_id                = oci_core_subnet.tf-demo22-public-subnet1.id
}

resource oci_database_autonomous_database_wallet tf-demo22-adb-wallet {
  autonomous_database_id = oci_database_autonomous_database.tf-demo22-adb.id
  password               = var.adb_wallet_password
  generate_type          = var.adb_wallet_type
  base64_encode_content  = "true"
}

resource local_file tf-demo22-adb-wallet {
  content_base64 = oci_database_autonomous_database_wallet.tf-demo22-adb-wallet.content
  filename       = var.adb_wallet_filename
}

output ADB {
  value = <<EOF

  service console URL = ${oci_database_autonomous_database.tf-demo22-adb.service_console_url}
            user      = admin
            password  = ${random_string.tf-demo22-adb-password.result}
EOF
#            password  = ${var.adb_password}
}
