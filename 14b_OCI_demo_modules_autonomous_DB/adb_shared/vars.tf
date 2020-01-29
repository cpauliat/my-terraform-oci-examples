# ---- input variables for modules

# -- mandatory variables
variable "adb_compartment_ocid" {}
variable "adb_type" {}                                          # OLTP or DW
variable "adb_db_name" {}
variable "adb_display_name" {}

# -- optional variables
variable "adb_cpu_core_count" { default = "1" }
variable "adb_data_storage_tbs" { default = "1" }
variable "adb_is_free_tier" { default = "false" }               # true or false
variable "adb_autoscaling_enabled" { default = "false" }        # true or false
variable "adb_license_model" { default = "LICENSE_INCLUDED" }   # LICENSE_INCLUDED or BRING_YOUR_OWN_LICENSE
variable "adb_whitelisted_ips" { default = [ "0.0.0.0/0" ] }
