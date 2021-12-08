#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Wait for /dev/oracleoci/oraclevdb link created by remote-exec provisioner"
DSK_NAME="/dev/oracleoci/oraclevdb"
MOUNT_PT="/mnt/bvol1"

while [ ! -h $DSK_NAME ]; do
  printf "."
  sleep 2
done

mkfs.xfs $DSK_NAME
mkdir $MOUNT_PT
mount -t xfs $DSK_NAME $MOUNT_PT
echo "$DSK_NAME    $MOUNT_PT    xfs    defaults,noatime,_netdev,nofail" >> /etc/fstab
chown opc:opc $MOUNT_PT