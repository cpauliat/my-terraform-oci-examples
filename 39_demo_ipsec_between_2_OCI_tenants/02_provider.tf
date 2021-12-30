# ---- TENANT1 provider
provider "oci" {
  alias            = "tenant1"
  region           = var.tenant1_region
  tenancy_ocid     = var.tenant1_tenancy_ocid
  user_ocid        = var.tenant1_user_ocid
  fingerprint      = var.tenant1_fingerprint
  private_key_path = var.tenant1_private_key_path
}

# ---- TENANT2 provider
provider "oci" {
  alias            = "tenant2"
  region           = var.tenant2_region
  tenancy_ocid     = var.tenant2_tenancy_ocid
  user_ocid        = var.tenant2_user_ocid
  fingerprint      = var.tenant2_fingerprint
  private_key_path = var.tenant2_private_key_path
}
