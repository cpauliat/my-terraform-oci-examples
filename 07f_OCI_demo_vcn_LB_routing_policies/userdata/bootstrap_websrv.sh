#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install and configure Apache Web server with PHP support"
yum -y install httpd php

cd /var/www/html

# get the matching backend set
case `hostname` in
"websrv1"|"websrv3")  backend_set="#1" ; mkdir route1 ; file="route1/index.php";;
"websrv2"|"websrv4")  backend_set="#2" ; mkdir route2 ; file="route2/index.php";;
"websrv5")            backend_set="DEFAULT"           ; file="index.php";;
esac

cat > $file << EOF
<!DOCTYPE html>
<html>
<head>
<title>demo 07f: LB routing policies</title>
<style>
body {
  background-color: linen;
}
.text1 {
  font-size:25px;
  color:black;
}
.text2 {
  font-size:40px;
  color:red;
}
.text3 {
  font-size:20px;
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
<tbody>
<tr>
<td>
<span class="text1"> This web page is served by </span>
<span class="text2"> backend set ${backend_set} </span>
<p>
<span class="text1"> ( server </span>
<span class="text2"> <?php echo gethostname(); ?> </span>
<span class="text1"> ) </span>
</td>
</tr>
</tbody>
</table>

<div class="text3"> 
Terraform OCI demo 07f: Load Balancer with routing policies
<br>
<a href="https://github.com/cpauliat/my-terraform-oci-examples/tree/master/07f_OCI_demo_vcn_LB_routing_policies">
https://github.com/cpauliat/my-terraform-oci-examples/tree/master/07f_OCI_demo_vcn_LB_routing_policies</a>
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
