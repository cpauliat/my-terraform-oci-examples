#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install additional packages"
yum install zsh nmap htop -y

echo "========== Create RC script to assign IP address on secondary VNIC at boot"
cat > /etc/init.d/oci-network << EOF
#!/bin/bash

/usr/bin/oci-network-config -a
EOF
chmod 755 /etc/init.d/oci-network
ln -s /etc/init.d/oci-network /etc/rc3.d/S99oci-network

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
