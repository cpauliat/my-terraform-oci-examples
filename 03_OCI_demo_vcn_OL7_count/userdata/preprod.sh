#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init.log
exec 1> /var/log/cloud-init.log 2>&1

echo "========== Install specific packages for PREPROD server"
yum install -y nmap

echo "========== Install latest updates"
#yum update -y

echo "========== Final reboot following installation of latest updates"
#reboot

