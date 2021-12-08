# ------ Create a compute instance for web server #2
resource oci_core_instance tf-demo08-ws2 {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_websrv2 - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo08-websrv2"
  shape               = "VM.Standard.E2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo08-private-subnet.id
    hostname_label   = "websrv2"
    assign_public_ip = false
    private_ip       = var.private_ip_websrv2
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_websrv)
    user_data           = base64encode(file(var.BootStrapFile_websrv))
  }
}
