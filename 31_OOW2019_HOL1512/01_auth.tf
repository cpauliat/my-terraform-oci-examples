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
variable "cidr_subnet1" {}
variable "compute_instance_shape" {}
variable "BootStrapFile_ol7" {}
variable "ssh_public_key_file_ol7" {}
variable "ssh_private_key_file_ol7" {}
variable "image_ocid_map" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
