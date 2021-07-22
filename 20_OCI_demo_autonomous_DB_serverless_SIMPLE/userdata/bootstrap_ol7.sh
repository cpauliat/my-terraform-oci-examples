#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "==========  Install OCI utilities and start OCI daemon"
yum -y install oci-utils
systemctl enable ocid.service
systemctl start ocid.service

echo "========== Install Oracle Instant client 21c"
yum install -y oracle-database-preinstall-19c.x86_64            # this creates oracle user (no pkg for 21c, use 19c pkg)
yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-sqlplus-21.1.0.0.0-1.x86_64.rpm
yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-tools-21.1.0.0.0-2.x86_64.rpm
yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-devel-21.1.0.0.0-1.x86_64.rpm
yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-jdbc-21.1.0.0.0-1.x86_64.rpm
yum install -y https://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient21/x86_64/getPackage/oracle-instantclient-odbc-21.1.0.0.0-1.x86_64.rpm

echo "========== Create directory for ADB wallet"
mkdir -p 700 /home/oracle/credentials_adb
chown -R oracle:dba /home/oracle/credentials_adb

echo "========== Configure SSH key for user oracle"
mkdir -p 700 /home/oracle/.ssh 
cp -p /home/opc/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
chown -R oracle:dba /home/oracle/.ssh

echo "========== Configure environment variables for user oracle"
cat << EOF >> /home/oracle/.bash_profile
PATH=$PATH:/usr/lib/oracle/21/client64/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/21/client64/lib
TNS_ADMIN=/home/oracle/credentials_adb
export PATH LD_LIBRARY_PATH TNS_ADMIN
echo "Oracle Instant Client 21 installed"
echo
EOF
chown oracle:dba /home/oracle/.bash_profile

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
