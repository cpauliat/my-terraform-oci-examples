#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

install_oracle_instant_client_19.5()
{
  echo "---- Install Oracle Instant client 19.5"
  yum install -y oracle-database-preinstall-19c.x86_64            # this creates oracle user
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-basic-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-sqlplus-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-tools-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-devel-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-jdbc-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-odbc-19.5.0.0.0-1.x86_64.rpm

  echo "---- Configure environment variables for user oracle"
  cat << EOF >> /home/oracle/.bash_profile
  PATH=$PATH:/usr/lib/oracle/19.5/client64/bin
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/18.3/client64/lib
  TNS_ADMIN=/home/oracle/credentials_adb
  export PATH LD_LIBRARY_PATH TNS_ADMIN
  echo "Oracle Instant Client 19.5 installed"
  echo
EOF
  chown oracle:dba /home/oracle/.bash_profile
}

echo "========== Get argument(s) passed thru metadata"
#AUTH_TOKEN=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_auth_token`
#REGION=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_region`
#USERNAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_username`
#NAMESPACE=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_namespace`
DB_NAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_db_name`
DB_PASSWORD=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_db_password`
WALLET_FILENAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_wallet_filename`

echo "==========  Install OCI utilities and start OCI daemon"
yum -y install oci-utils
systemctl enable ocid.service
systemctl start ocid.service

echo "========== Install Oracle Instant client 19.5"
install_oracle_instant_client_19.5

echo "========== Configure SSH key for user oracle"
mkdir -p 700 /home/oracle/.ssh 
cp -p /home/opc/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
chown -R oracle:dba /home/oracle/.ssh

echo "========== Create a script to connect to ADB instance with sqlplus"
cat << EOF > /home/oracle/sqlplus.sh
sqlplus admin/${DB_PASSWORD}@${DB_NAME}_medium
EOF
chown oracle:dba /home/oracle/sqlplus.sh
chmod 700 /home/oracle/sqlplus.sh

echo "========== Install additional packages"
yum install nmap -y

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Configure ADB wallet"
# waiting for wallet.zip file to be copied using remote-exec
while true
do
  if [ -f /tmp/${WALLET_FILENAME} ]; then break; fi
  printf "."
  sleep 10
done

# continuing
mkdir -p 700 /home/oracle/credentials_adb
chown -R oracle:dba /home/oracle/credentials_adb

cd /home/oracle/credentials_adb
unzip /tmp/${WALLET_FILENAME}
mv /tmp/${WALLET_FILENAME} /home/oracle
sed -i.bak 's#?/network/admin#/home/oracle/credentials_adb#' /home/oracle/credentials_adb/sqlnet.ora
chown -R oracle:dba /home/oracle/credentials_adb /home/oracle/${WALLET_FILENAME}

echo "========== Final reboot"
reboot
