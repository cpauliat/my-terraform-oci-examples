# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "vcn_cidr" {}
variable "vcn_dnslabel" {}
variable "cidr_public_subnet" {}
variable "private_subnets" {}
variable "AD" {}
variable "bastion_private_ip" {}
variable "bastion_ssh_private_key_file" {}
variable "bastion_ssh_public_key_file" {}
variable "bastion_cloud_init_file" {}
variable "ssh_private_key_file" {}
variable "ssh_public_key_file" {}
variable "linux_cloud_init_file" {}
variable "linux_instances" {}
variable "authorized_ips" {}
variable "cidr_onprem" {}
variable "ol7_image_ocid" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}
