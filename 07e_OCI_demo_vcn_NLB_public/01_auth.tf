# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "authorized_ips" {}
variable "ssh_public_key_file_websrv" {}
variable "ssh_private_key_file_websrv" {}
variable "ssh_public_key_file_bastion" {}
variable "ssh_private_key_file_bastion" {}
variable "cidr_vcn" {}
variable "cidr_public_subnet" {}
variable "cidr_private_subnet" {}
variable "bastion_private_ip" {}
variable "websrv_private_ips" {}
variable "AD_bastion" {}
variable "AD_websrvs" {}
variable "BootStrapFile_websrv" {}
variable "BootStrapFile_bastion" {}
variable "nlb_is_private" {}
variable "nlb_preserve_src_dst" {}
variable "nlb_bes_preserve_src" {}
variable "nlb_bes_policy" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
