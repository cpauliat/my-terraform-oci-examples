# ------ Generate a random password for DB system
resource "random_string" "tf-demo05-dbs-passwd" {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  number      = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#-_"   # use only special characters in this list
}

# ------ Create a DB System on shape VM.Standard.*
resource "oci_database_db_system" "tf-demo05-db-vm" {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  cpu_core_count      = var.VM-CPUCoreCount
  database_edition    = var.VM-DBEdition

  db_home {
    database {
      admin_password = random_string.tf-demo05-dbs-passwd.result
      db_name        = var.VM-DBName
      character_set  = var.VM-CharacterSet
      ncharacter_set = var.VM-NCharacterSet
      db_workload    = var.VM-DBWorkload
      pdb_name       = var.VM-PDBName
    }

    db_version   = var.VM-DBVersion
    display_name = var.VM-DBDisplayName
  }

  shape     = var.VM-DBNodeShape
  subnet_id = oci_core_subnet.tf-demo05-public-subnet1.id

  # Storage Management: ASM or LVM (filesystem)
  db_system_options {
    storage_management = var.VM-StorageMgt
  }

  # trimspace needed as a workaround to issue https://github.com/hashicorp/terraform/issues/7889
  ssh_public_keys         = [trimspace(file(var.ssh_public_key_file))]
  display_name            = var.VM-DBNodeDisplayName
  domain                  = "${var.dns_subnet1}.${var.dns_vcn}.oraclevcn.com"
  hostname                = var.VM-DBNodeHostName
  data_storage_size_in_gb = var.VM-DataStorageSizeInGB
  license_model           = var.VM-LicenseModel
  node_count              = var.VM-NodeCount
}

# ------ Get the public IP of the DBsystem and display it on screen
# Get DB node list
data "oci_database_db_nodes" "tf-demo05-vm" {
  compartment_id = var.compartment_ocid
  db_system_id   = oci_database_db_system.tf-demo05-db-vm.id
}

# Get DB node details
data "oci_database_db_node" "tf-demo05-vm" {
  db_node_id = data.oci_database_db_nodes.tf-demo05-vm.db_nodes[0]["id"]
}

# Get the OCID of the first (default) vNIC
data "oci_core_vnic" "tf-demo05-vm" {
  vnic_id = data.oci_database_db_node.tf-demo05-vm.vnic_id
}

output "DB_SYSTEM" {
  value = <<EOF


  ---- You can SSH directly to the Database system by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${data.oci_core_vnic.tf-demo05-vm.public_ip_address}
  
  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh dbs"

  Host dbs
          Hostname ${data.oci_core_vnic.tf-demo05-vm.public_ip_address}
          User opc
          IdentityFile ${var.ssh_private_key_file}

  ---- Connection to Oracle Database
  Use following password for SYS and SYSTEM accounts: ${random_string.tf-demo05-dbs-passwd.result}

EOF

}
