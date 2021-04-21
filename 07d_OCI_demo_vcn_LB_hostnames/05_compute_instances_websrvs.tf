# ------ Create 4 compute instances for web servers
resource oci_core_instance tf-demo07d-ws {

  # ignore change in cloud-init file after provisioning
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }

  count               = 5
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD_websrvs[count.index] - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo07d-websrv${count.index+1}"
  shape               = "VM.Standard.E2.1"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo07d-private-subnet.id
    hostname_label   = "websrv${count.index+1}"
    private_ip       = var.websrv_private_ips[count.index]  
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_websrv)
    user_data           = base64encode(file(var.BootStrapFile_websrv))
  }
}