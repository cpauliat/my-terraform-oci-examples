#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
MOUNT_PT=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_fs_mount_point`
NFS_IP=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_fs_ip_address`
EXPORT_PATH=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_fs_export_path`

echo "========== NFS-mount shared filesystem"
mkdir -p $MOUNT_PT
mount -t nfs $NFS_IP:/$EXPORT_PATH $MOUNT_PT
echo "$NFS_IP:/$EXPORT_PATH    $MOUNT_PT    nfs    defaults,noatime,_netdev,nofail" >> /etc/fstab
chown opc:opc $MOUNT_PT

echo "========== Create a test file in filesystem"
echo "Created on Linux instance in cloud-init post-provisioning" > $MOUNT_PT/file_linux.txt
chown opc:opc $MOUNT_PT/file_linux.txt

echo "========== Install additional packages"
yum install zsh -y

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
