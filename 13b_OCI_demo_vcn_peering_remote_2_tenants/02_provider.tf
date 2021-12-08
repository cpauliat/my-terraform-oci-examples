# ---- provider
provider "oci" {
  alias            = "tenant1"
  region           = var.region1
  tenancy_ocid     = var.tenancy_ocid1
  user_ocid        = var.user_ocid1
  fingerprint      = var.fingerprint1
  private_key_path = var.private_key_path1
}

provider "oci" {
  alias            = "tenant2"
  region           = var.region2
  tenancy_ocid     = var.tenancy_ocid2
  user_ocid        = var.user_ocid2
  fingerprint      = var.fingerprint2
  private_key_path = var.private_key_path2
}

provider "oci" {
  alias            = "tenant1_home"
  region           = var.region1_home
  tenancy_ocid     = var.tenancy_ocid1
  user_ocid        = var.user_ocid1
  fingerprint      = var.fingerprint1
  private_key_path = var.private_key_path1
}

provider "oci" {
  alias            = "tenant2_home"
  region           = var.region2_home
  tenancy_ocid     = var.tenancy_ocid2
  user_ocid        = var.user_ocid2
  fingerprint      = var.fingerprint2
  private_key_path = var.private_key_path2
}
