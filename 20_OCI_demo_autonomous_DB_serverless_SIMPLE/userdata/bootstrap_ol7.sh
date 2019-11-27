#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init.log
exec 1> /var/log/cloud-init.log 2>&1

echo "==========  Install OCI utilities and start OCI daemon"
yum -y install oci-utils
systemctl enable ocid.service
systemctl start ocid.service

echo "========== Install Oracle Instant client 18.3"
yum install -y oracle-database-preinstall-18c.x86_64            # this creates oracle user
yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.3-basic-18.3.0.0.0-3.x86_64.rpm
yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.3-sqlplus-18.3.0.0.0-3.x86_64.rpm
yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.3-tools-18.3.0.0.0-3.x86_64.rpm
yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.3-devel-18.3.0.0.0-3.x86_64.rpm
yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.3-jdbc-18.3.0.0.0-3.x86_64.rpm
yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.3-odbc-18.3.0.0.0-3.x86_64.rpm

echo "========== Create directory for ADB wallet"
mkdir -p 700 /home/oracle/credentials_adb
chown -R oracle:dba /home/oracle/credentials_adb

echo "========== Configure SSH key for user oracle"
mkdir -p 700 /home/oracle/.ssh 
cp -p /home/opc/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
chown -R oracle:dba /home/oracle/.ssh

echo "========== Configure environment variables for user oracle"
cat << EOF >> /home/oracle/.bash_profile
PATH=$PATH:/usr/lib/oracle/18.3/client64/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/18.3/client64/lib
TNS_ADMIN=/home/oracle/credentials_adb
export PATH LD_LIBRARY_PATH TNS_ADMIN
echo "Oracle Instant Client 18.3 installed"
echo
EOF

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
