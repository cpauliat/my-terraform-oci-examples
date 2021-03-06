# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "AD" {}

variable "authorized_ips" {}
variable "cidr_vcn" {}
variable "cidr_subnet_public" {}
variable "cidr_subnet_private" {}

variable "BootStrapFile_ol7_desktop" {}
variable "BootStrapFile_sgd" {}
variable "ssh_public_key_file_ol7_desktop" {}
variable "ssh_private_key_file_ol7_desktop" {}
variable "ssh_public_key_file_sgd" {}
variable "ssh_private_key_file_sgd" {}

variable "sgd_image_ocid" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
