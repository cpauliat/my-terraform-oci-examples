# ---- use variables defined in terraform.tfvars file
variable "g_tenancy_ocid" {}

variable "g_user_ocid" {}
variable "g_fingerprint" {}
variable "g_private_key_path" {}
variable "g_region" {}
variable "g_compartment_ocid" {}

# ---- provider
provider "oci" {
  region           = var.g_region
  tenancy_ocid     = var.g_tenancy_ocid
  user_ocid        = var.g_user_ocid
  fingerprint      = var.g_fingerprint
  private_key_path = var.g_private_key_path
}