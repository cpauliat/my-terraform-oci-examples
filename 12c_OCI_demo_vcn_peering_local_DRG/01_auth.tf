# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "authorized_ips" {}
variable "vcn1_cidr_vcn" {}
variable "vcn1_cidr_pubnet" {}
variable "vcn1_cidr_privnet" {}
variable "vcn2_cidr_vcn" {}
variable "vcn2_cidr_pubnet" {}
variable "vcn2_cidr_privnet" {}
variable "dns_label_vcn1" {}
variable "dns_label_vcn2" {}
variable "dns_label_public1" {}
variable "dns_label_public2" {}
variable "dns_label_private1" {}
variable "dns_label_private2" {}
variable "dns_hostname1" {}
variable "dns_hostname2" {}
variable "vcn1_instance_AD" {}
variable "vcn2_instance_AD" {}
variable "BootStrapFile" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
