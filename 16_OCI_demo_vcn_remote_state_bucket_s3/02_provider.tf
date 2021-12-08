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
# ---- accessed using S3 compatible API (Customer secret key needed)
# ---- Recommended: enabled versioning on this bucket
# ---- Use of variables not allowed here
# ---- You can use a different tenant and/or different region
terraform {
  backend "s3" {
    bucket                      = "terraform-remote-state"
    key                         = "terraform.tfstate.demo16"
    region                      = "eu-frankfurt-1"
    # format for endpoint is https://<namespace>.compat.objectstorage.<region>.oraclecloud.com
    endpoint                    = "https://oscemea001.compat.objectstorage.eu-frankfurt-1.oraclecloud.com"
    shared_credentials_file     = "s3key"        # not needed if you use shell variables AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true
  }
}

