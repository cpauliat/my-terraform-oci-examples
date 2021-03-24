#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

touch /home/opc/CLOUD-INIT

echo "========== Install additional packages"
yum install zsh -y

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
