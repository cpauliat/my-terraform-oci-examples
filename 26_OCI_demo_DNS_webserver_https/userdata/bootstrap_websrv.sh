#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
DNS_HOSTNAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_dns_hostname`

echo "========== Open ports 80 and 443 in Linux Firewall"
systemctl stop firewalld
sleep 5
firewall-offline-cmd --add-port=80/tcp
firewall-offline-cmd --add-port=443/tcp
systemctl start firewalld
systemctl enable firewalld

echo "========== Disable SElinux"
sed -i -e 's#SELINUX=enforcing#SELINUX=disabled#' /etc/selinux/config
setenforce 0

echo "========== Install and configure NGINX Web Server (from repo ol7_developer_epel-x86_64)"
yum install nginx -y
systemctl enable nginx
systemctl start nginx

echo "========== Configure HTTPS SSL on nginx"
yum install certbot python2-certbot-nginx -y python2-pyOpenSSL.noarch python2-pip
sed -i.bak -e "s#server_name.*$#server_name ${DNS_HOSTNAME};#g" /etc/nginx/nginx.conf
mv /usr/lib64/python2.7/site-packages/OpenSSL /usr/lib64/python2.7/site-packages/pyOpenSSL
certbot --authenticator webroot -w /usr/share/nginx/html --installer nginx --redirect \
        --register-unsafely-without-email -n --agree-tos --domains ${DNS_HOSTNAME}

echo "========== Install additional packages"
yum install zsh -y

echo "========== Apply updates to Linux OS"
#yum update -y

echo "========== FINAL REBOOT"
#reboot


