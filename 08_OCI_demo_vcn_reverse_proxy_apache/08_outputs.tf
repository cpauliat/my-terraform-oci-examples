# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d08-revproxy
          Hostname ${oci_core_instance.tf-demo08-revproxy.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_revproxy}
          StrictHostKeyChecking no
Host d08-ws1
          Hostname ${oci_core_instance.tf-demo08-ws1.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d08-revproxy
Host d08-ws2
          Hostname ${oci_core_instance.tf-demo08-ws2.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d08-revproxy
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

     ssh -F sshcfg d08-revproxy            to connect to revproxy host
     ssh -F sshcfg d08-ws1                 to connect to Web server #1
     ssh -F sshcfg d08-ws2                 to connect to Web server #2

  2) ---- HTTP connection to public load balancer
     Open following URLs in your Web browser:
     http://${oci_core_instance.tf-demo08-revproxy.public_ip}/s1
     http://${oci_core_instance.tf-demo08-revproxy.public_ip}/s2

EOF

}
