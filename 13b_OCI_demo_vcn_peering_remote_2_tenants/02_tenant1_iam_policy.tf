# ---- Create a IAM policy to allow local peering between 2 tenants
resource oci_identity_policy tenant1-policy {
  provider       = oci.tenant1_home
  compartment_id = var.tenancy_ocid1
  name           = "demo13b-policy"
  description    = "IAM policy to allow remote VCN peering between 2 tenants using different regions"
  statements     = ["Define tenancy Acceptor as ${var.tenancy_ocid2}",
                    "Allow group Administrators to manage remote-peering-from in compartment id ${var.compartment_ocid1}",
                    "Endorse group Administrators to manage remote-peering-to in tenancy Acceptor" ]
}