# ------ Create a SSH config file
resource local_file sshconfig {
  content = <<EOF
Host d07e-bastion
          Hostname ${oci_core_instance.tf-demo07e-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}
          StrictHostKeyChecking no
Host d07e-ws1
          Hostname ${oci_core_instance.tf-demo07e-ws[0].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07e-bastion
Host d07e-ws2
          Hostname ${oci_core_instance.tf-demo07e-ws[1].private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07e-bastion
EOF

  filename = "sshcfg"
}

# ------ Display the complete ssh commands needed to connect to the compute instances
output CONNECTIONS {
  value = <<EOF

  Wait a few minutes so that post-provisioning scripts can run on the compute instances
  Then you can use instructions below to connect.
  (Once connected to a server, you can see Cloud-init activity in /var/log/cloud-init2.log)

  1) ---- SSH connection to compute instances
     Run one of following commands on your Linux/MacOS desktop/laptop

     ssh -F sshcfg d07e-bastion             to connect to bastion host
     ssh -F sshcfg d07e-ws1                 to connect to Web server #1
     ssh -F sshcfg d07e-ws2                 to connect to Web server #2

  2) ---- HTTP connection to public network load balancer
     Open the following URL in your Web browser:
     http://${oci_network_load_balancer_network_load_balancer.tf-demo07e-nlb.ip_addresses[0].ip_address}

     You can monitor HTTP requests on the Web servers with following command:
     sudo tail -f /var/log/httpd/access_log
EOF

}
