# ---- provider
provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

terraform {
  cloud {
    organization = "cpauliat-org"

    workspaces {
      name = "demo16c_state_only"
    }
  }
}
