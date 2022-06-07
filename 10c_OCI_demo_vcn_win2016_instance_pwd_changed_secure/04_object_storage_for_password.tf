# ------ generate a random password to replace the temporary password in the cloud-init post-provisioning task
resource random_string windows_password {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#-_"   # use only special characters in this list
}

# ------ OCI object storage bucket and related resources for password
data oci_objectstorage_namespace tf-demo10c {
  compartment_id = var.compartment_ocid
}

resource oci_objectstorage_bucket tf-demo10c {
  compartment_id = var.compartment_ocid
  name           = var.bucket_name
  namespace      = data.oci_objectstorage_namespace.tf-demo10c.namespace
  access_type    = "NoPublicAccess"     # private bucket
}

resource oci_objectstorage_object tf-demo10c-pwd {
  depends_on = [ oci_objectstorage_bucket.tf-demo10c ]
  namespace = data.oci_objectstorage_namespace.tf-demo10c.namespace
  bucket    = var.bucket_name
  content   = random_string.windows_password.result
  object    = "pwd"
}

# Automatically delete OCI object after 1 day
resource oci_objectstorage_object_lifecycle_policy tf-demo10c-pwd {
  namespace = data.oci_objectstorage_namespace.tf-demo10c.namespace
  bucket    = var.bucket_name

  rules {
    action      = "DELETE"
    is_enabled  = true
    name        = "delete_pwd_file"
    time_amount = "1"
    time_unit   = "DAYS"

    object_name_filter {
      inclusion_patterns = [ "pwd" ]
    }
  }
}

# Pre-auth requests valid for 30 minutes
resource oci_objectstorage_preauthrequest tf-demo10c-pwd {
  depends_on   = [ oci_objectstorage_object.tf-demo10c-pwd ]
  access_type  = "ObjectRead"
  namespace    = data.oci_objectstorage_namespace.tf-demo10c.namespace
  bucket       = var.bucket_name
  name         = "pwd_preauth"
  time_expires = timeadd(timestamp(), "30m")
  object       = "pwd"
}


