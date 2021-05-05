# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "r1_compartment_ocid" {}
variable "r2_compartment_ocid" {}
variable "region1" {}
variable "region2" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "authorized_ips" {}
variable "r1_cidr_vcn" {}
variable "r1_cidr_pubnet" {}
variable "r1_cidr_privnet" {}
variable "r2_cidr_vcn" {}
variable "r2_cidr_pubnet" {}
variable "r2_cidr_privnet" {}
variable "dns_label_vcn1" {}
variable "dns_label_vcn2" {}
variable "dns_label_public1" {}
variable "dns_label_public2" {}
variable "dns_label_private1" {}
variable "dns_label_private2" {}
variable "dns_hostname1" {}
variable "dns_hostname2" {}
variable "dns_listener1" {}
variable "dns_forwarder1" {}
variable "dns_listener2" {}
variable "dns_forwarder2" {}
variable "r1_AD" {}
variable "r2_AD" {}
variable "BootStrapFile" {}

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

