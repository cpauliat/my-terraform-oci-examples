resource oci_bastion_bastion demo49 {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = oci_core_subnet.demo49-private-subnet.id
  name                         = "demo49"
  client_cidr_block_allow_list = var.authorized_ips
  max_session_ttl_in_seconds   = var.bastion_max_session_ttl_in_seconds
}

# -- specific session to connect to the private instance
# -- Wait 4 minutes so that Bastion plugin is enabled on compute instance
resource null_resource wait {
  provisioner "local-exec" {
    command = "sleep 240"
  }
}

resource oci_bastion_session demo49-private {
  depends_on = [ null_resource.wait ]    

  bastion_id = oci_bastion_bastion.demo49.id
  key_details {
    public_key_content = file(var.ssh_public_key_file_bastion)
  }

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.demo49-private.id
    target_resource_port                       = 22
    target_resource_operating_system_user_name = "opc"
  }
 
  display_name = "private"
  session_ttl_in_seconds = var.session_max_session_ttl_in_seconds
}

# -- Display instructions on how to SSH connect to private instance from Internet using Bastion
output private_instance {
  value = <<EOF

  ---- You can SSH to the Linux PRIVATE instance using the OCI BASTION SESSION by typing the following ssh command
  ssh -i ${var.ssh_private_key_file_private} -o ProxyCommand="ssh -i ${var.ssh_private_key_file_bastion} -W %h:%p -p 22 ${oci_bastion_session.demo49-private.bastion_user_name}@host.bastion.${var.region}.oci.oraclecloud.com" -p 22 opc@${oci_core_instance.demo49-private.private_ip}

  ---- Alternatively, you can add the following lines to your file $HOME/.ssh/config and then just run "ssh d49private"
  Host d49bastion
          Hostname host.bastion.${var.region}.oci.oraclecloud.com
          User ${oci_bastion_session.demo49-private.bastion_user_name}
          IdentityFile ${var.ssh_private_key_file_bastion}
  Host d49private
          Hostname ${oci_core_instance.demo49-private.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_private}
          ProxyJump d49bastion

EOF
}