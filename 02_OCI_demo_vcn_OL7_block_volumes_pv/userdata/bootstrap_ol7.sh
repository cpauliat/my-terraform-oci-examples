#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init.log
exec 1> /var/log/cloud-init.log 2>&1

### Storage setup
mkfs.xfs /dev/sdb
mkdir /mnt/vol1
mount -t xfs /dev/sdb /mnt/vol1
sdb_uuid=`blkid /dev/sdb -s UUID -o value`
echo "UUID=$sdb_uuid    /mnt/vol1    xfs    defaults,noatime,_netdev,nofail" >> /etc/fstab
chown opc:opc /mnt/vol1

### install zsh
yum install -y zsh

### YUM update
yum update -y

### final reboot
reboot
