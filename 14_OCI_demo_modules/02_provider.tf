# ---- provider
provider "oci" {
  region           = var.g_region
  tenancy_ocid     = var.g_tenancy_ocid
  user_ocid        = var.g_user_ocid
  fingerprint      = var.g_fingerprint
  private_key_path = var.g_private_key_path
}
