# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to avoid Oracle Linux 7.x images for GPU and ARM
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-202.*$"]
    regex  = true
  }
}

# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo21-dbclient {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo21-dbclient"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo21-private-subnet.id
    hostname_label   = "dbclient"
    assign_public_ip = "false"
  }

  metadata = {
    ssh_authorized_keys   = file(var.ssh_public_key_file_dbclient)
    user_data             = base64encode(file(var.BootStrapFile_dbclient))
    myarg_auth_token      = var.auth_token
    myarg_username        = var.user_name
    myarg_region          = var.region
    myarg_namespace       = data.oci_objectstorage_namespace.tf-demo21-ns.namespace
    myarg_db_name         = var.adb_db_name
    myarg_db_password     = random_string.tf-demo21-adb-password.result
    myarg_wallet_filename = var.adb_wallet_filename
  }
}

# ------ Copy wallet file to dbclient compute instance thru bastion
resource null_resource tf-demo21-connect-dbclient {

  depends_on = [ local_file.tf-demo21-adb-wallet, oci_core_instance.tf-demo21-bastion ]

  provisioner "file" {

    connection {
        bastion_host         = oci_core_instance.tf-demo21-bastion.public_ip
        bastion_user         = "opc"
        bastion_private_key  = file(var.ssh_private_key_file_bastion)
        host                 = oci_core_instance.tf-demo21-dbclient.private_ip
        user                 = "opc"
        private_key          = file(var.ssh_private_key_file_dbclient)
    }
    source      = var.adb_wallet_filename
    destination = "/tmp/${var.adb_wallet_filename}"
  }
}

