# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "region" { default = "eu-frankfurt-1" }
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "AD" {}
variable "BootStrapFile_ol7" {}
variable "ssh_public_key_file_ol7" {}
variable "ssh_private_key_file_ol7" {}
variable "authorized_ips" {}
variable "cidr_vcn" {}
variable "cidr_subnet1" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

