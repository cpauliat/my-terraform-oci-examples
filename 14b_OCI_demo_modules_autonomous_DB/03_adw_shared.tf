
module "adw1" {
  # -- location of module
  source = "./adb_shared"

  # -- Input variables for module
  # mandatory variables
  adb_compartment_ocid = var.g_compartment_ocid
  adb_type             = "DW"                   # OLTP or DW
  adb_db_name          = "DEMO14B"
  adb_display_name     = "tf-demo14b-adw"

  # optional variables
}

module "adw2" {
  # -- location of module
  source = "./adb_shared"

  # -- Input variables for module
  # mandatory variables
  adb_compartment_ocid = var.g_compartment_ocid
  adb_type             = "DW"                   # OLTP or DW
  adb_db_name          = "DEMO14BFREE"
  adb_display_name     = "tf-demo14b-adw-free"

  # optional variables
  adb_is_free_tier     = "true"
}

output adw1 {
  value = <<EOF

  service console URL = ${module.adw1.service_console_url}
            user      = admin
            password  = ${module.adw1.password}

EOF
}

output adw2 {
  value = <<EOF

  service console URL = ${module.adw2.service_console_url}
            user      = admin
            password  = ${module.adw2.password}

EOF
}
