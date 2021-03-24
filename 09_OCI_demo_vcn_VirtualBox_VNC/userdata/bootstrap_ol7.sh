#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
DSK_NAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_dsk_name`
MOUNT_PT=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_mount_point`
VNC_PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_vnc_password`

echo "========== Install VNC"
yum groupinstall "Server with GUI" -y
yum install -y xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils tigervnc-server

echo "========== Create a VNC server on desktop :1 (port 5901) for user opc"
cd /lib/systemd/system
cp -p vncserver@.service vncserver@:1.service
sed -i -e 's#<USER>#opc#g' -e 's#ExecStart=/usr/bin/vncserver#ExecStart=/usr/bin/vncserver -geometry 1600x900#' vncserver@:1.service

echo "========== Create the VNC password for user opc"
mkdir -p /home/opc/.vnc
echo $VNC_PASSWORD | vncpasswd -f > /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
chown -R opc:opc /home/opc/.vnc

echo "========== Configure Linux Firewall for VNC"
firewall-offline-cmd --zone=public --add-service vnc-server
systemctl restart firewalld

echo "========== Start VNC server"
systemctl daemon-reload
systemctl enable vncserver@:1.service
systemctl start vncserver@:1.service

echo "========== Install VirtualBox"
yum install -y gcc kernel-uek-devel
yum install -y VirtualBox-6.1

echo "========== Wait for block device to be attached by remote-exec provisioner"
while true
do
  if [ -h /dev/oracleoci/oraclevdb ]; then break; fi
  echo "Device /dev/oracleoci/oraclevdb not yet attached, waiting 5 seconds"
  sleep 5
done

echo "========== Storage setup: create and mount filesystem"
echo "Creating XFS filesystem and updating /etc/fstab"
mkfs.xfs $DSK_NAME
mkdir $MOUNT_PT
mount -t xfs $DSK_NAME $MOUNT_PT
echo "$DSK_NAME    $MOUNT_PT    xfs    defaults,noatime,_netdev,nofail" >> /etc/fstab
chown opc:opc $MOUNT_PT

echo "========== Configure VirtualBox storage"
mkdir -p $MOUNT_PT/vbox
chown opc:opc $MOUNT_PT/vbox
su - opc -c "VBoxManage setproperty machinefolder $MOUNT_PT/vbox"

echo "========== Install latest updates"
yum update -y

echo "========== Final reboot following installation of latest updates"
reboot


