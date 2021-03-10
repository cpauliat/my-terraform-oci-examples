#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init.log
exec 1> /var/log/cloud-init.log 2>&1

echo "========== Install additional packages"
yum install zsh -y

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot