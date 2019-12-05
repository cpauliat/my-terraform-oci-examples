# --------- Call module network to create a first VCN with related network objects
module "vcn1" {
  # -- location of module
  source = "./module_network"

  # -- Input variables for module
  # mandatory variables
  tenancy_ocid     = var.g_tenancy_ocid
  user_ocid        = var.g_user_ocid
  fingerprint      = var.g_fingerprint
  private_key_path = var.g_private_key_path
  compartment_ocid = var.g_compartment_ocid
  region           = var.g_region
  name_vcn         = "tf_demo14_vcn1"
  authorized_ips   = var.g_authorized_ips

  # optional variables
}

# --------- Call module network to create a second VCN with related network objects
module "vcn2" {
  # -- location of module
  source = "./module_network"

  # -- Input variables for module
  # mandatory variables
  tenancy_ocid     = var.g_tenancy_ocid
  user_ocid        = var.g_user_ocid
  fingerprint      = var.g_fingerprint
  private_key_path = var.g_private_key_path
  compartment_ocid = var.g_compartment_ocid
  region           = var.g_region
  name_vcn         = "tf_demo14_vcn2"
  authorized_ips   = var.g_authorized_ips

  # optional variables
  cidr_vcn         = "192.168.0.0/16"
  cidr_subnet1     = "192.168.0.0/24"
  dns_label_vcn    = "vcn2"
  dns_label_subnet1= "net1"
  name_subnet1     = "net1"
}
