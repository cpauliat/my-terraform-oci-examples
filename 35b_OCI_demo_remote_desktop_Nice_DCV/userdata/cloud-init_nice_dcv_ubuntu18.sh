#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_password`

echo "========== Install latest updates"
apt update
apt upgrade -y

echo "========== Configure Linux Firewall for Nice DCV"
iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

echo "========== Install Linux Graphical Environment"
apt install ubuntu-desktop -y
apt remove gdm3 -y
apt install lightdm -y      
apt install mesa-utils -y

echo "========== Start X server at boot"
systemctl set-default graphical.target
systemctl isolate graphical.target

echo "========== Set a password for user ubuntu"
echo "ubuntu:$PASSWORD" | chpasswd

echo "========== Create new user hpcuser and set a password"
groupadd hpcuser
useradd -g hpcuser -d /home/hpcuser -m -s /bin/bash hpcuser
echo "hpcuser:$PASSWORD" | chpasswd

echo "========== Install Nvidia CUDA 11.4 update 2 (includes Nvidia drivers 470.57.02-1). Latest versions in September 2021"
# see https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=18.04&target_type=deb_local
apt install gcc -y
wget -O /tmp/cuda-ubuntu1804.pin https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin
mv /tmp/cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600

wget -O /tmp/cuda_repo.deb https://developer.download.nvidia.com/compute/cuda/11.4.2/local_installers/cuda-repo-ubuntu1804-11-4-local_11.4.2-470.57.02-1_amd64.deb
dpkg -i /tmp/cuda_repo.deb
apt-key add /var/cuda-repo-ubuntu1804-11-4-local/7fa2af80.pub
apt-get update
apt-get -y install cuda

echo "========== Configure X with Nvidia drivers"
nvidia-xconfig --preserve-busid --enable-all-gpus

echo "========== Restart X server"
systemctl isolate graphical.target

echo "========== Verify OpenGL hardware rendering is available"
cat > /home/ubuntu/check_hw_rendering.sh << EOF
DISPLAY=:0 XAUTHORITY=$(ps aux | grep "X.*\-auth" | grep -v grep | sed -n 's/.*-auth\([^ ]\+\).*/\1/p') glxinfo | grep -i "opengl.*version"
EOF
chmod +x /home/ubuntu/check_hw_rendering.sh
chown ubuntu:ubuntu /home/ubuntu/check_hw_rendering.sh

echo "========== Install Nice DCV"
wget -O /tmp/NICE-GPG-KEY https://d1uj6qtbmh3dt5.cloudfront.net/NICE-GPG-KEY
gpg --import /tmp/NICE-GPG-KEY
wget -O /root/nice-dcv-2020.1-9012-ubuntu1804-x86_64.tgz https://d1uj6qtbmh3dt5.cloudfront.net/2020.1/Servers/nice-dcv-2020.1-9012-ubuntu1804-x86_64.tgz
cd /root
tar -xzf nice-dcv-2020.1-9012-ubuntu1804-x86_64.tgz
cd nice-dcv-2020.1-9012-ubuntu1804-x86_64
apt install -y ./nice-dcv-server_2020.1.9012-1_amd64.ubuntu1804.deb
apt install -y ./nice-xdcv_2020.1.338-1_amd64.ubuntu1804.deb
apt install -y ./nice-dcv-gl_2020.1.840-1_amd64.ubuntu1804.deb
apt install -y ./nice-dcv-simple-external-authenticator_2020.1.111-1_amd64.ubuntu1804.deb

echo "========== Start Nice DCV"
systemctl enable dcvserver --now

echo "========== Install glxspheres in /opt/VirtualGL/bin (included in VirtualGL)"
wget -O /tmp/virtualgl_2.6.5_amd64.deb https://sourceforge.net/projects/virtualgl/files/2.6.5/virtualgl_2.6.5_amd64.deb/download
dpkg -i /tmp/virtualgl_2.6.5_amd64.deb

echo "========== Disable screen saver to avoid locking in Graphical environment"
su - ubuntu -c "gsettings set org.gnome.desktop.lockdown disable-lock-screen true"
su - ubuntu -c "gsettings set org.gnome.desktop.screensaver lock-enabled false"
su - ubuntu -c "gsettings set org.gnome.desktop.screensaver idle-activation-enabled false"
su - hpcuser -c "gsettings set org.gnome.desktop.lockdown disable-lock-screen true"
su - hpcuser -c "gsettings set org.gnome.desktop.screensaver lock-enabled false"
su - hpcuser -c "gsettings set org.gnome.desktop.screensaver idle-activation-enabled false"

echo "========== Final reboot following installation of latest updates"
reboot


