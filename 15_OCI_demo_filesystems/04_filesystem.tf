resource oci_file_storage_file_system tf-demo15-fs1 {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo15-fs1"
}

resource oci_file_storage_mount_target tf-demo15-mt1 {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")
  compartment_id      = var.compartment_ocid
  subnet_id           = oci_core_subnet.tf-demo15-public-subnet1.id
  display_name        = "tf-demo15-mount-target1"
}

resource oci_file_storage_export_set tf-demo15-es1 {
  mount_target_id = oci_file_storage_mount_target.tf-demo15-mt1.id
  display_name = "tf-demo15-export-set1"
}

resource oci_file_storage_export tf-demo15-fs1-mt1 {
  export_set_id   = oci_file_storage_mount_target.tf-demo15-mt1.export_set_id
  file_system_id  = oci_file_storage_file_system.tf-demo15-fs1.id
  path            = "/${var.fs1_export_path}"
}

data oci_core_private_ips tf-demo15-mt1 {
  subnet_id = oci_file_storage_mount_target.tf-demo15-mt1.subnet_id

  filter {
    name = "id"
    values = [oci_file_storage_mount_target.tf-demo15-mt1.private_ip_ids.0]
  }
}

locals {
  mt1_ip_address = lookup(data.oci_core_private_ips.tf-demo15-mt1.private_ips[0], "ip_address")
}
