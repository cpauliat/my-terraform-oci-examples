# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "vcn1_AD" {}
variable "vcn2_AD" {}
variable "vcn1_cidr_vcn" {}
variable "vcn1_cidr_pubnet" {}
variable "vcn1_cidr_privnet" {}
variable "vcn2_cidr_vcn" {}
variable "vcn2_cidr_pubnet" {}
variable "vcn2_cidr_privnet" {}
variable "BootStrapFile" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "authorized_ips" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
