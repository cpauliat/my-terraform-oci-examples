# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

# See https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformUsingObjectStore.htm

# ---- Terraform State file stored in an existing OCI object storage bucket 
# ---- accessed http backend.
# ---- Recommended: enabled versioning on this bucket
# ---- Use of variables not allowed here
# ---- prerequisite: create a PAR (pre-authenticated request) for bucket with read/write access (TO BE DONE BEFOFE RENAMING FILE to 02_provider.tf)
# ---- and use it in address field below with suffix terraform.tfstate.demo16b
terraform {
  backend "http" {
    address = "https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/wjNtXq1SYDXPMrMKRPgztYT_rxILio9pdVrqZ2Aavnqd0R3dd5q9DI8arM5ismH2/n/oscemea001/b/terraform-remote-state/o/tfstate.demo16b"
    update_method = "PUT"
  }
}

