#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install and configure Apache Web server with PHP support"
yum -y install httpd php

case `hostname` in
"websrv1")  color="linen";;
"websrv2")  color="lightgrey";;
esac

cat >/var/www/html/index.php << EOF
<!DOCTYPE html>
<html>
<head>
<title>demo 07c: Load Balancer with SSL termination</title>
<style>
body {
  background-color: ${color};
}
#text1 {
  font-size:25px;
  color:black;
}
#text2 {
  font-size:40px;
  color:red;
}
#text3 {
  font-size:25px;
}
td {
  background-color:#D0D0FF;
  text-align: center;
  border: 2px solid blue;
  padding:30px
}
table {
  margin-left:auto;
  margin-right:auto;
  border-spacing: 50px;
}

</style>
</head>
<body>
<table>
<tr>
<td>
<div id="text1"> This web page is served by server </div>
<p>
<div id="text2"> <?php echo gethostname(); ?> </div>
</td>
</tr>
</table>

<div id="text3">
Terraform OCI demo 07c: Load Balancer with SSL termination
<br>
<a href="https://github.com/cpauliat/my-terraform-oci-examples/tree/master/07c_OCI_demo_vcn_LB_public_ssl_termination">
https://github.com/cpauliat/my-terraform-oci-examples/tree/master/07c_OCI_demo_vcn_LB_public_ssl_termination</a>
</div>

</body>
</html>

EOF
systemctl start httpd
systemctl enable httpd

echo "========== Open port 80/tcp in Linux Firewall"
/bin/firewall-offline-cmd --add-port=80/tcp

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
