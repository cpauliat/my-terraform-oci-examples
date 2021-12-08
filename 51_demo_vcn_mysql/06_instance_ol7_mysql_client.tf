# ------ Create a compute instance from the most recent Oracle Linux 7.x image
resource oci_core_instance demo51-dbclient {
    availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
    compartment_id       = var.compartment_ocid
    display_name         = "demo51-dbclient"
    preserve_boot_volume = "false"
    shape                = "VM.Standard.E3.Flex"
    shape_config {
      ocpus         = "1"
      memory_in_gbs = "8"  # total amount of memory for the instance
    }

    source_details {
        source_type = "image"
        source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
    }

    create_vnic_details {
        subnet_id      = oci_core_subnet.demo51-public-subnet.id
        hostname_label = "dbclient"
    }

    metadata = {
        ssh_authorized_keys = file(var.ssh_public_key_file)
        user_data           = base64encode(file(var.cloudinit_script_dbclient))
    }
}

resource local_file sshconfig {
    filename = "sshcfg"
    content = <<EOF
Host d51client
          Hostname ${oci_core_instance.demo51-dbclient.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}
EOF
}

# ------ Display the complete ssh command needed to connect to the instance
output DB_client {
  value = <<EOF

  WAIT FOR A FEW MINUTES FOR POST_PROVISIONING ACTIONS TO TAKE PLACE

  THEN connect (SSH) to Database client (Oracle Linux 7 instance with MySQL client) with following command

      ssh -F sshcfg d51client

  and connect to MySQL DB system using MySQL Shell or MySQL client

      MySQL Shell:  mysqlsh ${var.mysql_username}@${oci_mysql_mysql_db_system.demo51-mysql1.endpoints[0].hostname}

      MySQL Client: mysql --host ${oci_mysql_mysql_db_system.demo51-mysql1.endpoints[0].hostname} -u ${var.mysql_username} -p 

      Note: user password is ${random_string.demo51-mysql-password.result}

EOF

}
