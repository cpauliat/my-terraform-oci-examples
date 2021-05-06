# ---- Create a IAM policy to allow local peering between 2 tenants
resource oci_identity_policy tenant1-policy {
  provider       = oci.tenant1
  compartment_id = var.tenancy_ocid1
  name           = "demo12b-policy"
  description    = "IAM policy to allow local peering between 2 tenants"
  statements     = ["Define tenancy Acceptor as ${var.tenancy_ocid2}",
                    "Allow group Administrators to manage local-peering-from in compartment id ${var.compartment_ocid1}",
                    "Endorse group Administrators to manage local-peering-to in tenancy Acceptor",
                    "Endorse group Administrators to associate local-peering-gateways in compartment id ${var.compartment_ocid1} with local-peering-gateways in tenancy Acceptor" ]
}