# ------ Display the complete ssh command needed to connect to the instance
output DEMO27 {
  value = <<EOF

If not yet done, you need to delegate name resolution of your public DNS domain to the OCI DNS servers listed below:
- ${oci_dns_zone.tf-demo27.nameservers[0].hostname}
- ${oci_dns_zone.tf-demo27.nameservers[1].hostname}
- ${oci_dns_zone.tf-demo27.nameservers[2].hostname}
- ${oci_dns_zone.tf-demo27.nameservers[3].hostname}

---- In a few minutes, open the following URL in your web browser: http://${var.dns_hostname}
1) In the initial situation (both web servers OK), hostname ${var.dns_hostname} will be resolved to the public IP of web server 1 (${oci_core_instance.tf-demo27-ws1.public_ip}) so you should see that web page was served by websrv1
2) Stop websrv1, after some time(30 seconds), the health check will detect unavailability of server 1 and will change DNS entry to websrv2 (${oci_core_instance.tf-demo27-ws2.public_ip})
3) Reload the web page, and you should see that the page was served by websrv2
4) Start websrv1, after some time, the health check will detect availability of server 1 and will change DNS entry back to websrv1 (${oci_core_instance.tf-demo27-ws2.public_ip})
5) Reload the web page, and you should see that the page was served by websrv1

---- You can SSH directly to the Web Server instances by typing the following ssh command
  websrv1: ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo27-ws1.public_ip}
  websrv2: ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo27-ws2.public_ip}

---- You can follow progress of post-provisioning tasks by running following command. Last task is the FINAL REBOOT:
  websrv1: ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo27-ws1.public_ip} sudo tail -f /var/log/cloud-init2.log
  websrv2: ssh -i ${var.ssh_private_key_file} opc@${oci_core_instance.tf-demo27-ws2.public_ip} sudo tail -f /var/log/cloud-init2.log


EOF

}

