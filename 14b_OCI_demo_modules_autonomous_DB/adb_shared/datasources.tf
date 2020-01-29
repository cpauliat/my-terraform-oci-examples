# ---- data sources for module
data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.adb_compartment_ocid
}