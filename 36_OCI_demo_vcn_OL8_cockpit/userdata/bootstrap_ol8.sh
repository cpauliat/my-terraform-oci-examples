#!/bin/bash
set -vx

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
user_password=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_user_password`
user_name=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_user_name`

echo "========== Create a new user to replace opc"
useradd -m $user_name
mkdir /home/$user_name/.ssh
cp /home/opc/.ssh/authorized_keys /home/$user_name/.ssh/authorized_keys
chown -R $user_name:$user_name /home/$user_name/.ssh/
chmod 700 /home/$user_name/.ssh/
chmod 600 /home/$user_name/.ssh/authorized_keys

echo "========== Configure sudo for this user"
usermod -aG wheel $user_name
echo "$user_name ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/90-cloud-init-users

echo "========== only access SSH for this user (disable access for opc user)"
echo "AllowUsers $user_name" >> /etc/ssh/sshd_config   
systemctl restart sshd

echo "========== Assign a password to the new user (needed for connection to Cockpit console)"
echo $user_password | passwd --stdin -f $user_name

echo "========== Activate the Cockpit web console on port 443"
dnf install -y setroubleshoot-server            # to install semanage command
sed -i 's#9090#443#g' /usr/lib/systemd/system/cockpit.socket
semanage port -m -t websm_port_t -p tcp 443
firewall-offline-cmd --add-port=443/tcp
systemctl restart firewalld
systemctl enable firewalld
systemctl enable --now cockpit.socket

echo "========== Install additional packages"
dnf install zsh -y

echo "========== Apply latest updates to Linux OS"
#dnf update -y

echo "========== Final reboot"
reboot
