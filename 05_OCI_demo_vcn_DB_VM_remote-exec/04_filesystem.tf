resource oci_file_storage_file_system tf-demo05-fs1 {
  #Required
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid

  #Optional
  display_name = "tf-demo05-fs1"
}

resource oci_file_storage_mount_target tf-demo05-mt1 {
  #Required
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.tf-demo05-public-subnet1.id

  #Optional
  display_name = "tf-demo05-mount-target1"
}

resource oci_file_storage_export_set tf-demo05-es1 {
  # Required
  mount_target_id = oci_file_storage_mount_target.tf-demo05-mt1.id

  # Optional
  display_name = "tf-demo05-export-set1"
  #max_fs_stat_bytes = "${var.max_byte}"
  #max_fs_stat_files = "${var.max_files}"
}

resource oci_file_storage_export tf-demo05-fs1-mt1 {
  #Required
  export_set_id  = oci_file_storage_mount_target.tf-demo05-mt1.export_set_id
  file_system_id = oci_file_storage_file_system.tf-demo05-fs1.id
  path           = var.export_path_fs1_mt1

  export_options {
    source                         = "0.0.0.0/0"
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}

data oci_core_private_ips tf-demo05-mt1 {
  subnet_id = oci_file_storage_mount_target.tf-demo05-mt1.subnet_id

  filter {
    name   = "id"
    values = [oci_file_storage_mount_target.tf-demo05-mt1.private_ip_ids[0]]
  }
}

locals {
  mount_target_1_ip_address = data.oci_core_private_ips.tf-demo05-mt1.private_ips[0]["ip_address"]
}

# ------ Mount the filesystem in the db system
resource null_resource mount_fss_on_dbsystem {
  depends_on = [ oci_database_db_system.tf-demo05-db-vm, oci_file_storage_export.tf-demo05-fs1-mt1 ]
  provisioner "remote-exec" {
    connection {
      agent = false
      timeout = "10m"
      host = data.oci_core_vnic.tf-demo05-vm.public_ip_address
      user = "opc"
      private_key = file(var.ssh_private_key_file)
    }
    inline = [
      "sudo service rpcbind start",
      "sudo chkconfig rpcbind on",
      "sudo mkdir -p /mnt${var.export_path_fs1_mt1}",
      "echo > /tmp/fstabline",
      "echo '${local.mount_target_1_ip_address}:${var.export_path_fs1_mt1} /mnt${var.export_path_fs1_mt1} nfs defaults,noatime,_netdev,nofail 0 0' >> /tmp/fstabline",
      "sudo su -c 'cat /tmp/fstabline >> /etc/fstab'",
      "sudo mount /mnt${var.export_path_fs1_mt1}",
      "sudo chmod 777 /mnt${var.export_path_fs1_mt1}"
    ]
  }
}
