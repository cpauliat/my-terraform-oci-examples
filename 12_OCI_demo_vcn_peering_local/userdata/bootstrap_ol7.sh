#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init.log
exec 1> /var/log/cloud-init.log 2>&1

### Install additional packages
yum install zsh -y

### Apply updates to Linux OS
#yum update -y

### reboot
#reboot


