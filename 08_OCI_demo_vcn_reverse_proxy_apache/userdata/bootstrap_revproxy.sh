#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
IP_S1=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_ip_s1`
IP_S2=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_ip_s2`

echo "========== Install and configure Apache for reverse proxy"
yum install httpd -y
echo "This is the reverse proxy host" > /var/www/html/index.html
cat > /etc/httpd/conf.d/reverse-proxy.conf << EOF
# -- cpauliat
ProxyRequests Off

<VirtualHost *:80>
    ProxyPass /s1 http://${IP_S1}
    ProxyPassReverse /s1 http://${IP_S1}

    ProxyPass /s2 http://${IP_S2}
    ProxyPassReverse /s2 http://${IP_S2}
</VirtualHost>
EOF
systemctl enable httpd
systemctl start httpd

echo "========== Open port 80/tcp in Linux Firewall"
/bin/firewall-offline-cmd --add-port=80/tcp
# /bin/firewall-cmd --add-port=80/tcp --permanent
# /bin/firewall-cmd --reload

echo "========== Apply latest updates to Linux OS"
#yum update -y

echo "========== Final reboot"
reboot
