#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

DEFAULT_RESOLUTION="1900x900"

echo "========== `date`: Get argument(s) passed thru metadata"
VNC_PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_vnc_password`

echo "========== `date`: Install Linux Graphical Environment"
yum groupinstall -y "X Window System"
yum install -y gdm
yum groupinstall -y "MATE Desktop"

echo "========== `date`: Install TurboVNC"
yum install -y https://downloads.sourceforge.net/project/turbovnc/2.2.6/turbovnc-2.2.6.x86_64.rpm
echo "export PATH=\$PATH:/opt/TurboVNC/bin/" >> /home/opc/.bashrc

echo "========== `date`: Create the VNC password for user opc"
mkdir -p /home/opc/.vnc
echo $VNC_PASSWORD | vncpasswd -f > /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
chown -R opc:opc /home/opc/.vnc

echo "========== `date`: Set a password for user opc (needed for unlocking graphical session in noVNC)"
echo $VNC_PASSWORD | passwd --stdin opc

echo "========== `date`: Configure Linux Firewall for VNC"
firewall-offline-cmd --zone=public --add-service vnc-server
systemctl restart firewalld

echo "========== `date`: Install and configure Virtual GL"
VGL=""
#see https://blogs.oracle.com/cloud-infrastructure/post/using-opengl-to-enhance-gpu-use-cases-on-oracle-cloud
#see https://theterminallife.com/virtualgl-on-centos-7-using-nvidia-tesla-gpus/
yum install -y https://downloads.sourceforge.net/project/virtualgl/2.6.5/VirtualGL-2.6.5.x86_64.rpm
#nvidia-xconfig --query-gpu-info # check PCI info   --> PCI BusID : PCI:0:4:0
nvidia-xconfig -a --allow-empty-initial-configuration --virtual=$DEFAULT_RESOLUTION --busid="PCI:0:4:0"
echo "export PATH=\$PATH:/opt/VirtualGL/bin/" >> /home/opc/.bashrc
echo "export LC_ALL=C; unset LANG; unset LC_CTYPE" >> /home/opc/.bashrc

systemctl stop gdm
rmmod nvidia_uvm
rmmod nvidia_drm
rmmod nvidia_modeset
rmmod nvidia    
vglserver_config -config +s +f -t       # not persistent accross reboot
systemctl start gdm

echo "========== `date`: Create a TurboVNC service on display :1 (port 5901) for user opc"
cat > /home/opc/start_vnc.sh << EOF
#!/bin/bash

sudo systemctl stop gdm
sudo rmmod nvidia_uvm
sudo rmmod nvidia_drm
sudo rmmod nvidia_modeset
sudo rmmod nvidia
sudo vglserver_config -config +s +f -t       
sudo systemctl start gdm

sleep 10
sudo rm -f /tmp/.X*-lock /tmp/.X11-unix/X*
export VGL_DISPLAY=:0
/opt/TurboVNC/bin/vncserver -wm mate-session -geometry $DEFAULT_RESOLUTION -vgl
EOF

cat > /home/opc/stop_vnc.sh << EOF
#!/bin/bash

/opt/TurboVNC/bin/vncserver -kill :1
sudo rm -f /tmp/.X*-lock /tmp/.X11-unix/X*
EOF
chmod +x /home/opc/stop_vnc.sh /home/opc/start_vnc.sh
chown opc:opc /home/opc/stop_vnc.sh /home/opc/start_vnc.sh

# [root@demo35 ~]# vglserver_config -config +s +f -t       # problem: not persistent accross reboot
# ... Modifying /etc/security/console.perms to disable automatic permissions
#     for DRI devices ...
# ... Creating /etc/modprobe.d/virtualgl.conf to set requested permissions for
#     /dev/nvidia* ...
# ... Granting write permission to /dev/nvidia0 /dev/nvidiactl /dev/nvidia-modeset /dev/nvidia-nvswitchctl /dev/nvidia-uvm /dev/nvidia-uvm-tools for all users ...
# ... Granting write permission to /dev/dri/card0 for all users ...
# ... Modifying      to enable DRI permissions
#     for all users ...
# ... Modifying /etc/X11/xorg.conf to enable DRI permissions
#     for all users ...
# ... Adding xhost +LOCAL: to /etc/gdm/Init/Default script ...
# ... Adding greeter-setup-script=xhost +LOCAL: to /etc/lightdm/lightdm.conf ...
# ... Creating /usr/share/gdm/greeter/autostart/virtualgl.desktop ...
# ... Disabling XTEST extension in /etc/gdm/custom.conf ...
# ... Setting default run level to 5 (enabling graphical login prompt) ...
# ... Commenting out DisallowTCP line (if it exists) in /etc/gdm/custom.conf ...

# Done. You must restart the display manager for the changes to take effect.

cat > /lib/systemd/system/turbovnc.service << EOF
[Unit]
Description=TurboVNC
After=syslog.target network.target

[Service]
Type=forking
User=opc
ExecStart=/home/opc/start_vnc.sh
ExecStop=/home/opc/stop_vnc.sh

[Install]
WantedBy=multi-user.target
EOF

echo "========== `date`: Start TurboVNC server"
systemctl daemon-reload
systemctl enable turbovnc.service --now
systemctl enable gdm

echo "========== `date`: Install noVNC (HTML5 Web interface for VNC)"
yum-config-manager --enable ol7_developer_EPEL
yum install -y novnc python-websockify numpy

echo "========== `date`: Create Self-Signed certificates for HTTPS" 
cd /etc/pki/tls/certs
openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/pki/tls/certs/novnc.pem -out /etc/pki/tls/certs/novnc.pem -days 365 -subj "/C=DE/ST=DE/L=Frankfurt/O=DBANK/OU=OCI/CN=rdesktop"

echo "========== `date`: Configure Linux Firewall for noVNC"
firewall-offline-cmd --zone=public --add-port=443/tcp
systemctl restart firewalld

echo "========== `date`: Start NoVNC/websockify NOW and AT BOOT on port 443 and forward traffic to VNC port"
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
systemctl enable novnc.service --now

echo "========== `date`: Disable Mate screensaver to avoid locking in Graphical environment"
chmod 644 /usr/bin/mate-screensaver

echo "========== `date`: Install misc packages"
yum install -y htop

echo "========== `date`: End of cloud-init script"