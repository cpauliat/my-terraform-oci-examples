# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "r1_compartment_ocid" {}
variable "r2_compartment_ocid" {}
variable "region1" {}
variable "region2" {}
variable "r1_AD" {}
variable "r2_AD" {}
variable "r1_cidr_vcn" {}
variable "r1_cidr_pubnet" {}
variable "r1_cidr_privnet" {}
variable "r2_cidr_vcn" {}
variable "r2_cidr_pubnet" {}
variable "r2_cidr_privnet" {}
variable "BootStrapFile" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "authorized_ips" {}

# ---- provider
provider "oci" {
  alias            = "r1"
  region           = var.region1
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

provider "oci" {
  alias            = "r2"
  region           = var.region2
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

