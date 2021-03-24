#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install specific packages for DEV server"
yum install -y zsh

echo "========== Install latest updates"
#yum update -y

echo "========== Final reboot following installation of latest updates"
#reboot

