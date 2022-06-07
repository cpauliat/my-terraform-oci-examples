# ---- Generate a random string to be used as password for opc user on SGD
resource random_string tf-demo34-sgd-opc-password {
  # must contains at least 2 upper case letters,
  # 2 lower case letters, 2 numbers and 2 special characters
  length      = 16
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#+-="   # use only special characters in this list
}

# ---- Generate a random string to be used as password for sgdadmin user in SGD
resource random_string tf-demo34-sgdadmin-password {
  # must contains at least 2 upper case letters,
  # 2 lower case letters, 2 numbers and 2 special characters
  length      = 24
  upper       = true
  min_upper   = 2
  lower       = true
  min_lower   = 2
  numeric     = true
  min_numeric = 2
  special     = true
  min_special = 2
  override_special = "#+-="   # use only special characters in this list
}

# ------ Create a compute instance for the sgd gateway
resource oci_core_instance tf-demo34-sgd {
  availability_domain  = data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1]["name"]
  compartment_id       = var.compartment_ocid
  display_name         = "tf-demo34-sgd"
  shape                = "VM.Standard2.1"
  preserve_boot_volume = "false"

  source_details {
    source_type = "image"
    source_id   = var.sgd_image_ocid
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.tf-demo34-bastion-subnet.id
    hostname_label   = "sgd"
  }

  metadata = {
    ssh_authorized_keys   = file(var.ssh_public_key_file_sgd)
    user_data             = base64encode(file(var.BootStrapFile_sgd))
    myarg_opc_password    = random_string.tf-demo34-sgd-opc-password.result
    myarg_ol7_private_ip  = oci_core_instance.tf-demo34-ol7-desktop.private_ip
  }
}

# ------ Display temporary sgdadmin password
resource null_resource sgdadmin_pwd {
  provisioner "remote-exec" {
    connection {
      host        = oci_core_instance.tf-demo34-sgd.public_ip
      user        = "opc"
      private_key = file(var.ssh_private_key_file_sgd)
    }
    inline = [
      "echo 'Temporary password for sgdadmin = '`sudo cat /opt/tarantella/etc/.initial-sgdadmin-pwd`"
    ]
  }
}

# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d34sgd
          Hostname ${oci_core_instance.tf-demo34-sgd.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_sgd}
          StrictHostKeyChecking no
Host d34ol7
          Hostname ${oci_core_instance.tf-demo34-ol7-desktop.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_ol7_desktop}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d34sgd
EOF

  filename = "sshcfg"
}

# ------ Instructions
output sgd {
  value = <<EOF

  ---- Wait a few minutes for post-provisioning yum update and reboot
  ---- Then you can connect to Oracle Secure Global Desktop WebUI 

  https://${oci_core_instance.tf-demo34-sgd.public_ip}

  -- Admin user
  user         = sgdadmin
  tmp password = <see temporary password displayed above>
  --> Change this temporary password to new password during first login
  new password = ${random_string.tf-demo34-sgdadmin-password.result}

  -- Regular user
  user     = opc
  password = ${random_string.tf-demo34-sgd-opc-password.result}

  NOTE: When using SSH private key within SGD to connect to a Linux server, you need to use Putty formatted ssh private key
  
EOF

}

#HTML5 mode:   https://${oci_core_instance.tf-demo34-sgd.public_ip}/sgd/index.jsp?langSelected=en&clientmode=browser&visible=true
