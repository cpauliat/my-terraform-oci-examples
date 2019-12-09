#!/bin/bash

### ---- Send stdout, stderr to /var/log/messages/
exec 1> >(logger -s -t $(basename $0)) 2>&1

### ---- Install web server and start it on port 80
yum install -y httpd
systemctl start httpd
systemctl enable httpd

### ---- Create Welcome web page
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<title>OOW2019 HOL1512</title>
</head>
<body>
<p>
<meta charset="utf-8">
<span style="color: rgb(1, 116, 142); font-family: &quot;Open Sans&quot;, Helvetica, Arial, sans-serif; font-size: 20px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; background-color: rgb(255, 255, 255); text-decoration-style: initial; text-decoration-color: initial; display: inline !important; float: none;">
Infrastructure as Code: Oracle Linux, Terraform, and Oracle Cloud Infrastructure [HOL1512]</span>
&nbsp</p><p>The Web server is running.</p><p><br></p>
</body>
</html>
EOF
chown apache /var/www/html/index.html
chmod 644 /var/www/html/index.html

### ---- Open port tcp/80 in Linux Firewall
systemctl stop firewalld
sleep 5
firewall-offline-cmd --add-port=80/tcp
systemctl start firewalld
systemctl enable firewalld

### ---- Enable OCI utilities service
systemctl enable ocid.service
systemctl start ocid.service

### ---- Apply updates to Linux OS and reboot (disabled to save time during lab)
#yum update -y
#reboot
