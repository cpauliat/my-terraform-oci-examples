#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
DNS_HOSTNAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_dns_hostname`

echo "========== Open port 80 in Linux Firewall"
systemctl stop firewalld
sleep 5
firewall-offline-cmd --add-port=80/tcp
systemctl start firewalld
systemctl enable firewalld

echo "========== Disable SElinux"
sed -i -e 's#SELINUX=enforcing#SELINUX=disabled#' /etc/selinux/config
setenforce 0

echo "========== Install and configure NGINX Web Server"
yum install nginx -y
systemctl enable nginx
systemctl start nginx

echo "========== Install additional packages"
yum install zsh nmap -y

echo "========== Apply updates to Linux OS"
#yum update -y

echo "========== FINAL REBOOT"
#reboot


