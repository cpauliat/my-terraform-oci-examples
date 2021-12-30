#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Install additional packages"
yum install zsh -y

echo "========== Install Libreswan for IPSEC vpn"
yum install libreswan -y

echo "========== Configure IP forwarding"
cat >> /etc/sysctl.conf << EOF
#
# for IPsec
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
EOF

echo "========== Add rules to Linux Firewall"
# firewall-cmd --permanent --zone=public --add-masquerade
# firewall-cmd --permanent --add-rich-rule='rule protocol value="esp" accept'
# firewall-cmd --permanent --add-rich-rule='rule protocol value="ah" accept'
# firewall-cmd --permanent --add-port=500/udp 
# firewall-cmd --permanent --add-port=4500/udp 
# firewall-cmd --permanent --add-service="ipsec"
# firewall-cmd --reload
firewall-offline-cmd --zone=public --add-masquerade
firewall-offline-cmd --add-rich-rule='rule protocol value="esp" accept'
firewall-offline-cmd --add-rich-rule='rule protocol value="ah" accept'
firewall-offline-cmd --add-port=500/udp 
firewall-offline-cmd --add-port=4500/udp 
firewall-offline-cmd --add-service="ipsec"
systemctl restart firewalld

echo "========== Disable SElinux"
sed -i -e 's#SELINUX=enforcing#SELINUX=disabled#' /etc/selinux/config
setenforce 0

echo "========== Apply latest updates to Linux OS"
#yum update -y

echo "========== Final reboot"
#reboot
