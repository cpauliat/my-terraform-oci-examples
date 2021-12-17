# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d52-bastion
          Hostname ${oci_core_instance.demo52-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}
          StrictHostKeyChecking no
Host d52-ws1
          Hostname ${oci_core_instance.demo52-ws[0].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d52-bastion
Host d52-ws2
          Hostname ${oci_core_instance.demo52-ws[1].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d52-bastion
EOF

  filename = "sshcfg"
}

# ------ Display the complete ssh commands needed to connect to the compute instances
output CONNECTIONS {
  value = <<EOF

  Wait a few minutes so that post-provisioning scripts can run on the compute instances
  Then you can use instructions below to connect

  1) ---- SSH connection to compute instances
     Run one of following commands on your Linux/MacOS desktop/laptop

     ssh -F sshcfg d52-bastion             to connect to bastion host
     ssh -F sshcfg d52-ws1                 to connect to Web server #1
     ssh -F sshcfg d52-ws2                 to connect to Web server #2

  2) ---- HTTPS connection to public load balancer
     Open the following URL in your Web browser:
     https://${var.dns_hostname}

EOF

}
