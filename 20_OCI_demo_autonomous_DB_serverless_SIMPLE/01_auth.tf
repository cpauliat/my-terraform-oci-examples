# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "AD" {}
variable "BootStrapFile_ol7" {}
variable "ssh_public_key_file_ol7" {}
variable "ssh_private_key_file_ol7" {}
variable "authorized_ips" {}
variable "cidr_vcn" {}
variable "cidr_subnet1" {}
variable "adb_type" {}
variable "adb_is_free_tier" {}
variable "adb_cpu_core_count" {}
variable "adb_data_storage_tbs" {}
variable "adb_db_name" {}
variable "adb_password" {}
variable "adb_display_name" {}
variable "adb_license_model" {}
variable "adb_autoscaling_enabled" {}
variable "adb_whitelisted_ips" {}  
variable "adb_data_safe_status" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
