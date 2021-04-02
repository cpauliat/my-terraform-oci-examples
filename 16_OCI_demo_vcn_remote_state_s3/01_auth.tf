# ---- use variables defined in terraform.tfvars file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "authorized_ips" {}
variable "cidr_vcn" {}
variable "cidr_subnet1" {}

# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# ---- Terraform State file stored in an existing OCI object storage bucket
# ---- accessed using S3 compatible API (Customer secret key needed)
# ---- Use of variables not allowed here
# ---- You can use a different tenant and/or different region
terraform {
  backend "s3" {
    bucket                      = "terraform-remote-state"
    key                         = "terraform.state.demo16"
    region                      = "eu-frankfurt-1"
    # format for endpoint is https://<namespace>.compat.objectstorage.<region>.oraclecloud.com
    endpoint                    = "https://emeaosc.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    shared_credentials_file     = "s3key"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}
