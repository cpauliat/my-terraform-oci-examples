# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "BootStrapFile_revproxy" {}
variable "BootStrapFile_websrv" {}
variable "ssh_public_key_file_websrv" {}
variable "ssh_private_key_file_websrv" {}
variable "ssh_public_key_file_revproxy" {}
variable "ssh_private_key_file_revproxy" {} 
variable "authorized_ips" {}
variable "cidr_vcn" {}
variable "cidr_public_subnet" {}
variable "cidr_private_subnet" {}
variable "AD_revproxy" {}
variable "AD_websrv1" {}
variable "AD_websrv2" {}
variable "private_ip_websrv1" {}
variable "private_ip_websrv2" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
