#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init.log
exec 1> /var/log/cloud-init.log 2>&1

echo "==========  Install OCI utilities and start OCI daemon"
yum -y install oci-utils
systemctl enable ocid.service
systemctl start ocid.service

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
