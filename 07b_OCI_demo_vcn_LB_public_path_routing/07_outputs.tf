# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d07b-bastion
          Hostname ${oci_core_instance.tf-demo07b-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}
          StrictHostKeyChecking no
Host d07b-ws1
          Hostname ${oci_core_instance.tf-demo07b-ws[0].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07b-bastion
Host d07b-ws2
          Hostname ${oci_core_instance.tf-demo07b-ws[1].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07b-bastion
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

     ssh -F sshcfg d07b-bastion             to connect to bastion host
     ssh -F sshcfg d07b-ws1                 to connect to Web server #1
     ssh -F sshcfg d07b-ws2                 to connect to Web server #2

  2) ---- HTTP connection to public load balancer
     Open following URLs in your Web browser:
     http://${oci_load_balancer.tf-demo07b-lb.ip_addresses[0]}/${var.path_route_websrvs[0]}/
     http://${oci_load_balancer.tf-demo07b-lb.ip_addresses[0]}/${var.path_route_websrvs[1]}/
     http://${oci_load_balancer.tf-demo07b-lb.ip_addresses[0]}

EOF

}
