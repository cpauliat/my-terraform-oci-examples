# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "cidr_vcn" {}
variable "cidr_subnet1" {}

variable "AD" {}

variable "ssh_public_key_file_rdesktop" {}
variable "ssh_private_key_file_rdesktop" {}
variable "BootStrapFile_rdesktop" {}

variable "authorized_ips" {}


# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}