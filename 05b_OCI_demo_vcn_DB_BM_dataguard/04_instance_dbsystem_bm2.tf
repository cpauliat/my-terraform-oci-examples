# ------ Create a DB Systems on Bare Metal shape BM.DenseIO1.36
resource oci_database_db_system tf-demo05b-db-bm2 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD2 - 1]["name"]
  compartment_id      = var.compartment_ocid
  cpu_core_count      = var.BM2-CPUCoreCount
  database_edition    = var.BM2-DBEdition
  db_home {
    database {
      admin_password = var.BM2-DBAdminPassword
      db_name        = var.BM2-DBName
      character_set  = var.BM2-CharacterSet
      ncharacter_set = var.BM2-NCharacterSet
      db_workload    = var.BM2-DBWorkload
      pdb_name       = var.BM2-PDBName
    }
    db_version   = var.BM2-DBVersion
    display_name = var.BM2-DBDisplayName
  }
  disk_redundancy = var.BM2-DBDiskRedundancy
  shape           = var.BM2-DBNodeShape
  subnet_id       = oci_core_subnet.tf-demo05b-public-subnet1.id

  # trimspace needed as a workaround to issue https://github.com/hashicorp/terraform/issues/7889
  ssh_public_keys         = [trimspace(file(var.ssh_public_key_file))]
  display_name            = var.BM2-DBNodeDisplayName
  domain                  = "${var.dns_subnet1}.${var.dns_vcn}.oraclevcn.com"
  hostname                = var.BM2-DBNodeHostName
  data_storage_percentage = "40"
  license_model           = var.BM2-LicenseModel
}

# ------ Post-provisioning and outputs
# Get DB node list
data oci_database_db_nodes tf-demo05b-bm2 {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.tf-demo05b-db-bm2.id
}

# Get DB node details
data oci_database_db_node tf-demo05b-bm2 {
  db_node_id = data.oci_database_db_nodes.tf-demo05b-bm2.db_nodes[0]["id"]
}

# Gets the OCID of the first (default) vNIC
data oci_core_vnic tf-demo05b-bm2 {
  vnic_id = data.oci_database_db_node.tf-demo05b-bm2.vnic_id
}

resource null_resource tf-demo05b-bm2 {
  provisioner "file" {
    connection {
      agent       = false
      timeout     = "10m"
      host        = data.oci_core_vnic.tf-demo05b-bm2.public_ip_address
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }
    source      = var.ScriptFile_db
    destination = "~/script_db.sh"
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "10m"
      host        = data.oci_core_vnic.tf-demo05b-bm2.public_ip_address
      user        = "opc"
      private_key = file(var.ssh_private_key_file)
    }
    inline = [
      "chmod +x ~/script_db.sh",
      "sudo ~/script_db.sh",
    ]
  }
}

# ------ Output
output DBS2_DB1_standby {
  value = <<EOF
  
  SSH connection to DB node from outside the VCN:
    ssh -i ${var.ssh_private_key_file} opc@${data.oci_core_vnic.tf-demo05b-bm2.public_ip_address}

  Oracle DB Connection from outside the VCN:
    sqlplus system/${var.BM1-DBAdminPassword}@${data.oci_core_vnic.tf-demo05b-bm2.public_ip_address}:1521/${lower(var.BM1-PDBName)}.${lower(var.dns_subnet1)}.${lower(var.dns_vcn)}.oraclevcn.com
    
    You can then run following SQL command to check this instance is the standby
    select database_role from v$database;
    
EOF
}
