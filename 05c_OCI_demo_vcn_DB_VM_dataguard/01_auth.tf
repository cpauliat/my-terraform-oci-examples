# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "AD" {}
variable "AD_standby" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "authorized_ips" {}
variable "dns_vcn" {}
variable "dns_subnet1" {}
variable "cidr_vcn" {}
variable "cidr_subnet1" {}
variable "VM-StorageMgt" {}
variable "VM-DBNodeShape" {}
variable "VM-DBNodeShape-standby" {}
variable "VM-CPUCoreCount" {}
variable "VM-DBEdition" {}
variable "VM-DBName" {}
variable "VM-DBVersion" {}
variable "VM-DBDisplayName" {}
variable "VM-DBNodeDisplayName" {}
variable "VM-DBNodeHostName" {}
variable "VM-NCharacterSet" {}
variable "VM-CharacterSet" {}
variable "VM-DBWorkload" {}
variable "VM-PDBName" {}
variable "VM-DataStorageSizeInGB" {}
variable "VM-LicenseModel" {}
variable "VM-NodeCount" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

