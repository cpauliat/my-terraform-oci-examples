# ------ Create a 500GB block volume
resource oci_core_volume tf-demo09-vbox-vol1 {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo09-vbox-vol1"
  size_in_gbs         = "500"
}

# ------ Attach the new block volume to the ol7 compute instance
resource oci_core_volume_attachment tf-demo09-vbox-vol1 {
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.tf-demo09-vbox.id
  volume_id       = oci_core_volume.tf-demo09-vbox-vol1.id
  device          = "/dev/oracleoci/oraclevdb"

  connection {
    type        = "ssh"
    host        = oci_core_instance.tf-demo09-vbox.public_ip
    user        = "opc"
    private_key = file(var.ssh_private_key_file)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
    ]
  }
}

# ------ Generate a random password for VNC user opc
resource random_string vnc_password_opc {
  # must contains at least 2 upper case letters, 2 lower case letters, 2 numbers and 2 special characters
  length      = 12
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#_-"   # use only special characters in this list
}

# ------ Create a compute instance from the more recent Oracle Linux 7.x image
resource oci_core_instance tf-demo09-vbox {
  availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id      = var.compartment_ocid
  display_name        = "tf-demo09-vbox"
  shape               = "BM.Standard2.52"

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ImageOCID-ol7.images[0]["id"]
  }

  create_vnic_details {
    subnet_id      = oci_core_subnet.tf-demo09-vbox-public-subnet1.id
    hostname_label = "vbox"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_file)
    user_data           = base64encode(file(var.BootStrapFile))
    myarg_dsk_name      = var.bkvol_attachment_name
    myarg_mount_point   = var.bkvol_mount_point
    myarg_vnc_password  = random_string.vnc_password_opc.result
  }

  timeouts {
    create = "30m"
  }
}

# ------ Create a secondary VNIC (to be used by a VBox Guest)
resource oci_core_vnic_attachment tf-demo09-guestvnic1 {
  instance_id = oci_core_instance.tf-demo09-vbox.id

  create_vnic_details {
    subnet_id              = oci_core_subnet.tf-demo09-vbox-public-subnet1.id
    display_name           = "Vbox Guest VNIC #1"
    assign_public_ip       = true
    skip_source_dest_check = true
  }
}

# ------ Create a Linux/MacOS script for VNC SSH tunnel
resource local_file sshtunnel {
  content = <<EOF
ssh -i ${var.ssh_private_key_file} -4 -NL 5901:localhost:5901 opc@${oci_core_instance.tf-demo09-vbox.public_ip}
EOF

  filename = var.ssh_tunnel_file
}

# ------ Outputs
output VBOX {
  value = <<EOF


  ---- You can SSH directly to the instance by typing the following ssh command
  ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo09-vbox.public_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh vboxoci"
  Host vboxoci
          Hostname ${oci_core_instance.tf-demo09-vbox.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file}

  ---- To connect to remote desktop with VNC, first create a SSH tunnel with following command
  ---- then open localhost:5901 in your VNC client 
  ---- VNC password is ${random_string.vnc_password_opc.result}
  chmod +x ${var.ssh_tunnel_file}; ./${var.ssh_tunnel_file}

EOF

}
