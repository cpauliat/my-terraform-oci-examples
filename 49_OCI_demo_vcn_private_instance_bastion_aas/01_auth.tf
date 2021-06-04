# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "authorized_ips" {}
variable "ssh_public_key_file_private" {}
variable "ssh_private_key_file_private" {}
variable "ssh_public_key_file_bastion" {}
variable "ssh_private_key_file_bastion" {}
variable "cidr_vcn" {}
variable "cidr_private_subnet" {}
variable "AD_private" {}
variable "BootStrapFile" {}
variable "bastion_max_session_ttl_in_seconds" {}
variable "session_max_session_ttl_in_seconds" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
