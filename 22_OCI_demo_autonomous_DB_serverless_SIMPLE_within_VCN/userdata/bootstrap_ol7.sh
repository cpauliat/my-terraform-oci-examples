#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init.log
exec 1> /var/log/cloud-init.log 2>&1

echo "==========  Install OCI utilities and start OCI daemon"
yum -y install oci-utils
systemctl enable ocid.service
systemctl start ocid.service

echo "========== Install Oracle Instant client 19.5"
yum install -y oracle-database-preinstall-19c.x86_64            # this creates oracle user
yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-basic-19.5.0.0.0-1.x86_64.rpm
yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-sqlplus-19.5.0.0.0-1.x86_64.rpm
yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-tools-19.5.0.0.0-1.x86_64.rpm
yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-devel-19.5.0.0.0-1.x86_64.rpm
yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-jdbc-19.5.0.0.0-1.x86_64.rpm
yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-odbc-19.5.0.0.0-1.x86_64.rpm

echo "========== Create directory for ADB wallet"
mkdir -p 700 /home/oracle/credentials_adb
chown -R oracle:dba /home/oracle/credentials_adb

echo "========== Configure SSH key for user oracle"
mkdir -p 700 /home/oracle/.ssh 
cp -p /home/opc/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
chown -R oracle:dba /home/oracle/.ssh

echo "========== Configure environment variables for user oracle"
cat << EOF >> /home/oracle/.bash_profile
PATH=$PATH:/usr/lib/oracle/19.5/client64/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/18.3/client64/lib
TNS_ADMIN=/home/oracle/credentials_adb
export PATH LD_LIBRARY_PATH TNS_ADMIN
echo "Oracle Instant Client 19.5 installed"
echo
EOF

echo "========== Install additional packages"
yum install nmap -y

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
