# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d07d-bastion
          Hostname ${oci_core_instance.tf-demo07d-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}
          StrictHostKeyChecking no
Host d07d-ws1
          Hostname ${oci_core_instance.tf-demo07d-ws[0].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07d-bastion
Host d07d-ws2
          Hostname ${oci_core_instance.tf-demo07d-ws[1].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07d-bastion
EOF

  filename = "sshcfg"
}

# ------ Display the complete ssh commands needed to connect to the compute instances
output CONNECTIONS {
  value = <<EOF

  Wait a few minutes so that post-provisioning scripts can run on the compute instances and also for the load balancer health check to be successful
  Then you can use instructions below to connect

  1) ---- SSH connection to compute instances
     Run one of following commands on your Linux/MacOS desktop/laptop

     ssh -F sshcfg d07d-bastion             to connect to bastion host
     ssh -F sshcfg d07d-ws1                 to connect to Web server #1
     ssh -F sshcfg d07d-ws2                 to connect to Web server #2

  2) ---- HTTP connection to public load balancer
     Add the following lines to your local hosts file
     ${oci_load_balancer.tf-demo07d-lb.ip_addresses[0]} ${var.hostnames[0]}
     ${oci_load_balancer.tf-demo07d-lb.ip_addresses[0]} ${var.hostnames[1]}

     Then open following URLs in your Web browser:
     http://${var.hostnames[0]}/
     http://${var.hostnames[1]}/

EOF

}
