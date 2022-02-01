#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
VNC_PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_vnc_password`

echo "========== Install VNC"
yum groupinstall "Server with GUI" -y
yum install -y xorg-x11-xauth xorg-x11-fonts-* xorg-x11-utils tigervnc-server

echo "========== Create a VNC server on desktop :1 (port 5901) for user opc"
cd /lib/systemd/system
cp -p vncserver@.service vncserver@:1.service
sed -i -e 's#<USER>#opc#g' vncserver@:1.service

echo "========== Create the VNC password for user opc"
mkdir -p /home/opc/.vnc
echo $VNC_PASSWORD | vncpasswd -f > /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
echo "geometry=1900x900" > /home/opc/.vnc/config    # default resolution in NoVNC
chown -R opc:opc /home/opc/.vnc

echo "========== Set a password for user opc (needed for unlocking graphical session in noVNC)"
echo $VNC_PASSWORD | passwd --stdin opc

echo "========== Configure Linux Firewall for VNC"
firewall-offline-cmd --zone=public --add-service vnc-server
systemctl restart firewalld

echo "========== Start VNC server"
systemctl daemon-reload
systemctl enable vncserver@:1.service
systemctl start vncserver@:1.service

echo "========== Install noVNC (HTML5 Web interface for VNC)"
yum-config-manager --enable ol7_developer_EPEL
yum install -y novnc python-websockify numpy

echo "========== Create Self-Signed certificates for HTTPS" 
cd /etc/pki/tls/certs
openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/pki/tls/certs/novnc.pem -out /etc/pki/tls/certs/novnc.pem -days 365 -subj "/C=DE/ST=DE/L=Frankfurt/O=DBANK/OU=OCI/CN=rdesktop"

echo "========== Configure Linux Firewall for noVNC"
firewall-offline-cmd --zone=public --add-port=443/tcp
systemctl restart firewalld

echo "========== Start websockify NOW and AT BOOT on port 443 and forward traffic to VNC port"
cat > /lib/systemd/system/novnc.service << EOF
[Unit]
Description=noVNC
After=syslog.target network.target

[Service]
Type=simple
ExecStart=/bin/websockify --web=/usr/share/novnc/ --cert=/etc/pki/tls/certs/novnc.pem 443 localhost:5901

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable novnc.service
systemctl start novnc.service

echo "========== Install latest updates"
yum update -y

echo "========== Final reboot following installation of latest updates"
reboot
