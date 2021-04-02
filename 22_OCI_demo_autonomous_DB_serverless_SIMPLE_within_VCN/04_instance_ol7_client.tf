# --------- Get the OCID for the most recent for Oracle Linux 7.x disk image
data oci_core_images ImageOCID-ol7 {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "7.9"

  # filter to avoid Oracle Linux 7.x images for GPU
  filter {
    name   = "display_name"
    values = ["^.*Oracle-Linux-7.9-[^G].*$"]
    regex  = true
  }
}

# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance tf-demo22-dbclient {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo22-ol7-dbclient"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo22-public-subnet1.id
    hostname_label = "dbclient"
  }

  metadata = {
    ssh_authorized_keys   = file(var.ssh_public_key_file_dbclient)
    user_data             = base64encode(file(var.BootStrapFile_dbclient))
    myarg_db_name         = var.adb_db_name
    myarg_db_password     = random_string.tf-demo22-adb-password.result
    myarg_wallet_filename = var.adb_wallet_filename
  }
}

resource local_file sshconfig {
  content = <<EOF
Host d22dbclient-opc
          Hostname ${oci_core_instance.tf-demo22-dbclient.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_dbclient}
Host d22dbclient-oracle
          Hostname ${oci_core_instance.tf-demo22-dbclient.public_ip}
          User oracle
          IdentityFile ${var.ssh_private_key_file_dbclient}
EOF


  filename = "sshcfg"
}

# ------ Copy wallet file to dbclient compute instance thru bastion
resource null_resource tf-demo22-connect-dbclient {

  depends_on = [ local_file.tf-demo22-adb-wallet ]

  provisioner "file" {

    connection {
        host                 = oci_core_instance.tf-demo22-dbclient.public_ip
        user                 = "opc"
        private_key          = file(var.ssh_private_key_file_dbclient)
    }
    source      = var.adb_wallet_filename
    destination = "/tmp/${var.adb_wallet_filename}"
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output "DB_client" {
  value = <<EOF

  1) ---- Connection to Database client host (Oracle Linux 7 instance with Oracle Instant Client)
     Run one of following commands on your Linux/MacOS desktop/laptop

     ssh -F sshcfg d22dbclient-opc          (to connect as user opc)
     ssh -F sshcfg d22dbclient-oracle       (to connect as user oracle, after a few minutes wait)

  2) ---- Connection to ADB instance with sqlplus 
     ssh -F sshcfg d22dbclient-oracle
     ./sqlplus.sh

EOF

}
