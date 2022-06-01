resource oci_database_vm_cluster cluster3 {
  lifecycle {
    ignore_changes = [ ssh_public_keys ]
  }
  compartment_id            = var.vmcluster_compartment_id
  cpu_core_count            = var.exacc_vmcluster_ocpus
  display_name              = var.exacc_vmcluster_name
  exadata_infrastructure_id = var.exacc_infra_id
  ssh_public_keys           = [ file(var.exacc_vmcluster_ssh_public_key_file) ]
  vm_cluster_network_id     = var.exacc_vmcluster_network_id    # oci_database_vm_cluster_network.ecch-cl3.id
  gi_version                = var.exacc_vmcluster_gi_version    # changes on this after provisoning are ignored

  #Optional
  data_storage_size_in_tbs    = var.exacc_vmcluster_exa_storage_tbs
  db_node_storage_size_in_gbs = var.exacc_vmcluster_local_storage_gbs
  db_servers                  = [ var.exacc_vmcluster_db_server4, var.exacc_vmcluster_db_server3 ]  
          # changes here will destroy/recreate VM cluster
          # use resources oci_database_vm_cluster_add_virtual_machine or oci_database_vm_cluster_remove_virtual_machine instead
  is_local_backup_enabled     = "false"
  is_sparse_diskgroup_enabled = "false"
  license_model               = var.exacc_vmcluster_lic_model
  memory_size_in_gbs          = var.exacc_vmcluster_memory_gbs
  time_zone                   = "Europe/Paris"
  freeform_tags               = { "Department" = "cpauliat"}

  timeouts {
      create = "8h"
      delete = "1h"
  }
}

# oci_database_vm_cluster.cluster3: Creation complete after 4h43m47s
# oci_database_vm_cluster.cluster3: Creation complete after 4h45m9s 
# oci_database_vm_cluster.cluster3: Destruction complete after 1h06m51s

data oci_database_vm_cluster_patches cluster3 {
    vm_cluster_id = oci_database_vm_cluster.cluster3.id
}

output vmcluster_patches {
  value = data.oci_database_vm_cluster_patches.cluster3
}

# # Adding a DB server: about 2 hours
# resource oci_database_vm_cluster_add_virtual_machine cluster3-node2 {
#     db_servers {
#         db_server_id = var.exacc_vmcluster_db_server2
#     }
#     vm_cluster_id = oci_database_vm_cluster.cluster3.id
# }

# # Removing a DB server: about 30 minutes
# resource oci_database_vm_cluster_remove_virtual_machine cluster3-node2 {
#     db_servers {
#         db_server_id = var.exacc_vmcluster_db_server2
#     }
#     vm_cluster_id = oci_database_vm_cluster.cluster3.id
# }

# oci_database_vm_cluster_add_virtual_machine.cluster3-node2: 
# Creation complete after 5s [id=ocid1.vmcluster.oc1.eu-frankfurt-1.antheljtnmvrbeaafyngetvtl6i2gbyfzns2p66hrjjlzjngy7osjaf2veuq]
# --> job done in background

# output vmcluster {
#   value = data.oci_database_db_nodes.cluster3
# }

# data oci_database_db_nodes cluster3 {
#   compartment_id = var.vmcluster_compartment_id
#   vm_cluster_id  = oci_database_vm_cluster.cluster3.id
# }

