# ------ Create a SSH config file
resource "local_file" "sshconfig" {
  content = <<EOF
Host d07a-bastion
          Hostname ${oci_core_instance.tf-demo07a-bastion.public_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_bastion}
          StrictHostKeyChecking no
Host d07a-ws1
          Hostname ${oci_core_instance.tf-demo07a-ws1.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07a-bastion
Host d07a-ws2
          Hostname ${oci_core_instance.tf-demo07a-ws2.private_ip}
          User opc
          IdentityFile ${var.ssh_private_key_file_websrv}
          StrictHostKeyChecking no
          proxycommand /usr/bin/ssh -F sshcfg -W %h:%p d07a-bastion
EOF

  filename = "sshcfg"
}

# ------ Display the complete ssh commands needed to connect to the compute instances
output "CONNECTIONS" {
  value = <<EOF

  Wait a few minutes so that post-provisioning scripts can run on the compute instances
  Then you can use instructions below to connect

  1) ---- SSH connection to compute instances
     Run one of following commands on your Linux/MacOS desktop/laptop

     ssh -F sshcfg d07a-bastion             to connect to bastion host
     ssh -F sshcfg d07a-ws1                 to connect to Web Server #1
     ssh -F sshcfg d07a-ws2                 to connect to Web Server #2

  2) ---- HTTP connection to public load balancer
     Open the following URL in your Web browser:
     http://${oci_load_balancer.tf-demo07a-lb.ip_addresses[0]}

EOF

}
