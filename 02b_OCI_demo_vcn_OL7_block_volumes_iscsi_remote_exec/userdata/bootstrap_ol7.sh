#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
DSK_NAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_dsk_name`
MOUNT_PT=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_mount_point`

echo "========== Install additional packages"
yum install -y zsh nmap

echo "========== Wait for block volume to be visible (after iscsiadm commands)"
while [ ! -e $DSK_NAME ]; do printf "."; sleep 1; done; echo

echo "========== Storage setup: create and mount filesystem"
mkfs.xfs $DSK_NAME
mkdir $MOUNT_PT
mount -t xfs $DSK_NAME $MOUNT_PT
echo "$DSK_NAME    $MOUNT_PT    xfs    defaults,noatime,_netdev,nofail" >> /etc/fstab
chown opc:opc $MOUNT_PT

echo "========== Install latest updates"
#yum update -y

echo "========== Final reboot following installation of latest updates"
#reboot
