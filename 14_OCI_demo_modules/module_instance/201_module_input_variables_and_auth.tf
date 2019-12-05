# -------- Input variables for the module

# -- mandatory
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "AD" {}
variable "vcn_ocid" {}
variable "subnet_ocid" {}
variable "shape" {}
variable "image_ocid" {}
variable "vm_name" {}
variable "ssh_public_key_file" {}
variable "hostname" {}

# -------- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
