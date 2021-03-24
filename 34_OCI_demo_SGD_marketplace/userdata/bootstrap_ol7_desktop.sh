#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
OPC_PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_opc_password`

echo "========== Set opc password"
echo $OPC_PASSWORD | passwd --stdin -f opc

echo "========== Install zsh"
yum install -y zsh

echo "========== Install X environment"
yum groupinstall "Server with GUI" -y
yum install -y xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils

echo "========== Enable X11 forwarding for SSH"
sed -i.bak /etc/ssh/sshd_config -e 's/#X11UseLocalhost yes/X11UseLocalhost no/' -e 's/#X11DisplayOffset 10/X11DisplayOffset 10/'
systemctl restart sshd

echo "========== Apply latest OS updates"
yum update -y

echo "========== Final reboot (needed by yum update)""
reboot


