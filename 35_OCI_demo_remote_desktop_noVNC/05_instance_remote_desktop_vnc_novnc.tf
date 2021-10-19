# ------ Create a REMOTE DESKTOP compute instance (OL7.x) 
resource oci_core_instance demo35 {
  lifecycle {
    ignore_changes = [ defined_tags ]
  }
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "demo35: remote desktop TurboVNC/NoVNC"
  shape                = var.shape
  dynamic "shape_config" {
    for_each = (local.is_flex_shape) ? [ 1 ] : [ ]
    content {
        ocpus         = var.flex_shape_ocpus
        memory_in_gbs = var.flex_shape_memory_in_gbs
    }
  }  
  preserve_boot_volume = "true"

  source_details {
    source_type = "image"
    source_id   = local.is_gpu_shape ? local.ol7_gpu_image_id : local.ol7_non_gpu_image_id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.demo35-subnet1.id
    hostname_label   = "demo35"
    assign_public_ip = "true"
    nsg_ids          = [oci_core_network_security_group.demo35.id]
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file_rdesktop)
    user_data           = base64encode(file(local.BootStrapFile_rdesktop))
    myarg_vnc_password  = local.vnc_password_opc
  }
}

# ------ Display the complete ssh command needed to connect to the instance
output demo35 {
  value = <<EOF

  VNC/noVNC password = ${local.vnc_password_opc}
  opc user password  = ${local.vnc_password_opc} (to unlock screen after inactivity)

  ---- You can SSH directly to the demo35 compute instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_rdesktop} opc@${oci_core_instance.demo35.public_ip}

  ---- If you want to connect to VNC server from a VNC client, create a SSH tunnel by typing the following ssh command
  ---- Then connect to localhost:5901  if running Terraform on your VNC client machine
  ---- Or   connect to ip-address:5901 if running Terraform on a different machine
  ssh -i ${var.ssh_private_key_file_rdesktop} opc@${oci_core_instance.demo35.public_ip} -L 5901:localhost:5901

  ---- You can also connect to NoVNC using your Web Browser (Self signed certificate) 
  In your web browser, 
       open https://${oci_core_instance.demo35.public_ip} then enter the VNC password
    or open https://${oci_core_instance.demo35.public_ip}/vnc.html?password=${local.vnc_password_opc}&autoconnect=true
  EOF
}

#    or open https://${oci_core_instance.demo35.public_ip}/vnc.html?password=${local.vnc_password_opc}&resize=scale&quality=9&autoconnect=true
