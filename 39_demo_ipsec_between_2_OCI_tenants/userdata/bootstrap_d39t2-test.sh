#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install additional packages"
yum install zsh -y

echo "========== Disable Linux Firewall"
systemctl stop firewalld
systemctl disable firewalld

echo "========== Disable SElinux"
sed -i -e 's#SELINUX=enforcing#SELINUX=disabled#' /etc/selinux/config
setenforce 0

echo "========== Apply latest updates to Linux OS"
#yum update -y

echo "========== Final reboot"
#reboot
