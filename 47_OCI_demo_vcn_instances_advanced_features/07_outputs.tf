
# ------ Create a SSH config file
resource local_file sshconfig {
  content = templatefile("templates/sshcfg.tpl", {
    bastion_public_ip               = oci_core_instance.demo47-bastion.public_ip,
    linux_instances                 = var.linux_instances,
    bastion_ssh_private_key_file    = var.bastion_ssh_private_key_file,
    linux_ssh_private_key_file      = var.ssh_private_key_file,
  })
  filename = "sshcfg"
  file_permission = "0644"
}

# ------ Display instructions to connect to compute instances
output CONNECTIONS {
 value = templatefile("templates/outputs.tpl", {
   linux_instances              = var.linux_instances,
 })
}
