# -------- Input variables for the module

# -- mandatory
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "authorized_ips" {}
variable "name_vcn" {}

# -- optional
variable "cidr_vcn"          { default = "10.0.0.0/16" }
variable "cidr_subnet1"      { default = "10.0.1.0/24" }
variable "name_subnet1"      { default = "subnet1" }
variable "dns_label_vcn"     { default = "vcn" }
variable "dns_label_subnet1" { default = "subnet1" }

# -------- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
