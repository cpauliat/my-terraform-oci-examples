# ---- Create a IAM policy to allow local peering between 2 tenants
resource oci_identity_policy tenant2-policy {
  provider       = oci.tenant2
  compartment_id = var.tenancy_ocid2
  name           = "demo12b-policy"
  description    = "IAM policy to allow local peering between 2 tenants using DRG in other tenant"
  statements     = ["Define tenancy tenant1 as ${var.tenancy_ocid1}",
                    "Define group tenant1Administrators as ${var.iam_group_ocid1}",
                    "Admit group tenant1Administrators of tenancy tenant1 to manage drg-attachment in compartment id ${var.compartment_ocid2}",
                    "Endorse group Administrators to manage drg in tenancy tenant1" ]
  # OLD: STATEMENTS when using LPG instead of DRG (soon deprecated)
  # statements     = ["Define tenancy Requestor as ${var.tenancy_ocid1}",
  #                   "Define group tenant1Administrators as ${var.iam_group_ocid1}",
  #                   "Admit group tenant1Administrators of tenancy Requestor to manage local-peering-to in compartment id ${var.compartment_ocid2}",
  #                   "Admit group tenant1Administrators of tenancy Requestor to associate local-peering-gateways in tenancy Requestor with local-peering-gateways in compartment id ${var.compartment_ocid2}" ]
}