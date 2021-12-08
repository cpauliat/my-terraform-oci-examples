#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_password`

echo "========== Install latest updates"
#yum update -y

echo "========== Configure Linux Firewall for Nice DCV"
firewall-offline-cmd --zone=public --add-port=8443/tcp
systemctl restart firewalld

echo "========== Install Linux Graphical Environment"
yum groupinstall -y "Server with GUI"
yum install -y xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils gdm

echo "========== Start X server at boot"
systemctl set-default graphical.target

echo "========== Set a password for user opc"
echo $PASSWORD | passwd --stdin opc

echo "========== Create new user hpcuser and set a password"
groupadd hpcuser
useradd -g hpcuser -d /home/hpcuser -m -s /bin/bash hpcuser
echo $PASSWORD | passwd --stdin hpcuser

echo "========== Configure X with Nvidia drivers"
nvidia-xconfig --preserve-busid --enable-all-gpus
systemctl isolate graphical.target

cat > /root/check_hw_rendering.sh << EOF
DISPLAY=:0 XAUTHORITY=$(ps aux | grep "X.*\-auth" | grep -v grep | sed -n 's/.*-auth\([^ ]\+\).*/\1/p') glxinfo | grep -i "opengl.*version"
EOF
chmod +x /root/check_hw_rendering.sh

echo "========== Install Nice DCV"
rpm --import https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
wget -O /root/nice-dcv-2020.1-9012-el7-x86_64.tgz https://d1uj6qtbmh3dt5.cloudfront.net/2020.1/Servers/nice-dcv-2020.1-9012-el7-x86_64.tgz
cd /root
tar -xzf nice-dcv-2020.1-9012-el7-x86_64.tgz
cd nice-dcv-2020.1-9012-el7-x86_64
yum install -y nice-dcv-server-2020.1.9012-1.el7.x86_64.rpm
yum install -y nice-xdcv-2020.1.338-1.el7.x86_64.rpm
yum install -y nice-dcv-gl-2020.1.840-1.el7.x86_64.rpm
yum install -y nice-dcv-simple-external-authenticator-2020.1.111-1.el7.x86_64.rpm

echo "========== Start Nice DCV"
systemctl enable dcvserver --now

echo "========== Disable screen saver to avoid locking in Graphical environment"
cat >> /etc/dconf/db/local.d/00-screensaver <<EOF
[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/desktop/screensaver]
lock-enabled=false
lock-delay=uint32 3600
EOF

dconf update

echo "========== Install misc packages"
yum install -y htop

echo "========== Final reboot following installation of latest updates"
reboot
