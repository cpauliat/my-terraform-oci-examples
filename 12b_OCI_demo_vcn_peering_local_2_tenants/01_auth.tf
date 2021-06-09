# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid1" {}
variable "user_ocid1" {}
variable "fingerprint1" {}
variable "private_key_path1" {}
variable "compartment_ocid1" {}
variable "iam_group_ocid1" {}
variable "tenancy_ocid2" {}
variable "user_ocid2" {}
variable "fingerprint2" {}
variable "private_key_path2" {}
variable "compartment_ocid2" {}
variable "iam_group_ocid2" {}
variable "region" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "authorized_ips" {}
variable "tenant1_cidr_vcn" {}
variable "tenant1_cidr_pubnet" {}
variable "tenant1_cidr_privnet" {}
variable "tenant2_cidr_vcn" {}
variable "tenant2_cidr_pubnet" {}
variable "tenant2_cidr_privnet" {}
variable "dns_label_tenant1" {}
variable "dns_label_tenant2" {}
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
variable "tenant1_instance_AD" {}
variable "tenant2_instance_AD" {}
variable "BootStrapFile" {}

# ---- provider
provider "oci" {
  alias            = "tenant1"
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid1
  user_ocid        = var.user_ocid1
  fingerprint      = var.fingerprint1
  private_key_path = var.private_key_path1
}

provider "oci" {
  alias            = "tenant2"
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid2
  user_ocid        = var.user_ocid2
  fingerprint      = var.fingerprint2
  private_key_path = var.private_key_path2
}
