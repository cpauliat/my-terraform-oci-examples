# ---- OCI bucket for manual backups
# -- see https://docs.cloud.oracle.com/iaas/Content/Database/Tasks/adbbackingup.htm

data oci_objectstorage_namespace tf-demo23-ns {
  compartment_id = var.compartment_ocid
}

resource oci_objectstorage_bucket tf-demo23-adb {
  compartment_id = var.compartment_ocid
  name           = "backup_${var.adb_db_name}"         # this name must not be changed (expected name)
  namespace      = data.oci_objectstorage_namespace.tf-demo23-ns.namespace
}