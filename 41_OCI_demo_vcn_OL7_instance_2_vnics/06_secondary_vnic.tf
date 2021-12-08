# ------ Create a secondary VNIC
resource oci_core_vnic_attachment tf-demo41-ol7 {
  instance_id = oci_core_instance.tf-demo41-ol7.id
  nic_index   = length(regexall("^BM", var.instance_shape)) > 0 ? "1" : "0"
  # nic_index: 1 for BM shapes, 0 for VM shapes

  create_vnic_details {
    subnet_id              = oci_core_subnet.tf-demo41-public-subnet1.id
    display_name           = "VNIC #2"
    hostname_label         = "d41-ol7-vnic2"
    assign_public_ip       = false
    skip_source_dest_check = true
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "10m"
      host        = oci_core_instance.tf-demo41-ol7.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file_ol7)
    }
    # command below is not persistent accross reboot, so a RC script is needed (see cloud-init script)
    inline = [
      "sudo /usr/bin/oci-network-config -a",
    ]
  }
}
