#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
APP_PATH=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_path`

echo "========== Install and configure Apache Web server with PHP support"
yum -y install httpd php
echo "This is DEFAULT PAGE running on Web server `hostname`" >>/var/www/html/index.html
mkdir -p /var/www/html/${APP_PATH}
echo "This is application ${APP_PATH} running on Web server `hostname`" >>/var/www/html/${APP_PATH}/index.html
systemctl start httpd
systemctl enable httpd

echo "========== Open port 80/tcp in Linux Firewall"
/bin/firewall-offline-cmd --add-port=80/tcp

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
