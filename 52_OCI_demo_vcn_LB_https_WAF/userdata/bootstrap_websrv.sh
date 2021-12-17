#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install and configure Apache Web server with PHP support"
yum -y install httpd php
chown -R opc:opc /var/www/html
systemctl start httpd
systemctl enable httpd

echo "========== Disable SElinux"
sed -i -e 's#SELINUX=enforcing#SELINUX=disabled#' /etc/selinux/config
setenforce 0

echo "========== Open port 80/tcp in Linux Firewall"
systemctl stop firewalld
sleep 5
firewall-offline-cmd --add-port=80/tcp
systemctl start firewalld
systemctl enable firewalld

echo "========== Install additional packages"
yum install zsh -y