#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install and configure Web server"
yum -y install httpd
echo "This is DEFAULT PAGE running on Web server `hostname`" >>/var/www/html/index.html
systemctl start httpd
systemctl enable httpd

echo "========== Open port 80/tcp in Linux Firewall"
/bin/firewall-offline-cmd --add-port=80/tcp
# /bin/firewall-cmd --add-port=80/tcp --permanent
# /bin/firewall-cmd --reload

echo "========== Apply latest updates to Linux OS"
#yum update -y

echo "========== Final reboot"
reboot
