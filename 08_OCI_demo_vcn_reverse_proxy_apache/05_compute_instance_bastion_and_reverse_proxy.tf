# ------ Create a compute instance for revproxy/reverse proxy host
resource oci_core_instance tf-demo08-revproxy {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_revproxy - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo08-revproxy"
  shape               = "VM.Standard.E2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo08-public-subnet.id
    hostname_label = "revproxy"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_revproxy)
    user_data           = base64encode(file(var.BootStrapFile_revproxy))
    myarg_ip_s1         = var.private_ip_websrv1
    myarg_ip_s2         = var.private_ip_websrv2
  }
}
