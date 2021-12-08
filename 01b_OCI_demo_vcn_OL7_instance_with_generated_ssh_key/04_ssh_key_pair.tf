# ------ SSH key pair for opc user
resource tls_private_key ssh-demo01b {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource local_file ssh-demo01b-public {
  content  = tls_private_key.ssh-demo01b.public_key_openssh
  filename = var.ssh_key_file_public
}

resource local_file ssh-demo01b-private {
  content  = tls_private_key.ssh-demo01b.private_key_pem
  filename = var.ssh_key_file_private
  file_permission = "0600"
}
