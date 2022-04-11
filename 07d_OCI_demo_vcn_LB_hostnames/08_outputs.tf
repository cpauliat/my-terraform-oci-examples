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
Host d07d-ws3
          Hostname ${oci_core_instance.tf-demo07d-ws[2].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07d-bastion
Host d07d-ws4
          Hostname ${oci_core_instance.tf-demo07d-ws[3].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07d-bastion
Host d07d-ws5
          Hostname ${oci_core_instance.tf-demo07d-ws[4].private_ip}
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
     ssh -F sshcfg d07d-ws1                 to connect to Web server #1 (backend set #1)
     ssh -F sshcfg d07d-ws2                 to connect to Web server #2 (backend set #2)
     ssh -F sshcfg d07d-ws3                 to connect to Web server #3 (backend set #1)
     ssh -F sshcfg d07d-ws4                 to connect to Web server #4 (backend set #2)
     ssh -F sshcfg d07d-ws5                 to connect to Web server #5 (backend set #3 / default)

  2) ---- HTTP connection to public load balancer
     Add the following line to your local hosts file
     ${oci_load_balancer.tf-demo07d-lb.ip_addresses[0]} ${var.hostnames[0]} ${var.hostnames[1]}

     Then open following URLs in your Web browser:
     ${format("http://%-22s", var.hostnames[0])                               }             (should be served by backend set #1)
     ${format("http://%-22s", var.hostnames[1])                               }             (should be served by backend set #2)
     ${format("http://%-22s", oci_load_balancer.tf-demo07d-lb.ip_addresses[0])}             (should be served by backend set #3 / default)

EOF

}
