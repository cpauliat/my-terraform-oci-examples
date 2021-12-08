#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

install_oracle_instant_client_18.5()
{
  echo "========== Install Oracle Instant client 18.5"
  yum install -y oracle-database-preinstall-18c.x86_64            # this creates oracle user
  yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.5-basic-18.5.0.0.0-3.x86_64.rpm
  yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.5-sqlplus-18.5.0.0.0-3.x86_64.rpm
  yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.5-tools-18.5.0.0.0-3.x86_64.rpm
  yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.5-devel-18.5.0.0.0-3.x86_64.rpm
  yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.5-jdbc-18.5.0.0.0-3.x86_64.rpm
  yum install -y http://yum.oracle.com/repo/OracleLinux/OL7/oracle/instantclient/x86_64/getPackage/oracle-instantclient18.5-odbc-18.5.0.0.0-3.x86_64.rpm

  echo "========== Configure environment variables for user oracle"
  cat << EOF >> /home/oracle/.bash_profile
PATH=$PATH:/usr/lib/oracle/18.5/client64/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/18.5/client64/lib
TNS_ADMIN=/home/oracle
export PATH LD_LIBRARY_PATH TNS_ADMIN
echo "Oracle Instant Client 18.5 installed"
echo
echo create a tnsnames.ora file in /home/oracle
EOF
  chown oracle:dba /home/oracle/.bash_profile
}

install_oracle_instant_client_19.5()
{
  # -- Install Oracle instant client 19.5 for Oracle Database
  yum install -y oracle-database-preinstall-19c.x86_64		# this creates oracle user
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-basic-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-sqlplus-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-tools-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-devel-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-jdbc-19.5.0.0.0-1.x86_64.rpm
  yum install -y https://download.oracle.com/otn_software/linux/instantclient/195000/oracle-instantclient19.5-odbc-19.5.0.0.0-1.x86_64.rpm

  # -- postinstall for user oracle (TNS_ADMIN is the location of tnsnames.ora file)
  cat << EOF >> /home/oracle/.bash_profile
PATH=$PATH:/usr/lib/oracle/19.5/client64/bin
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/oracle/19.5/client64/lib
TNS_ADMIN=/home/oracle
export PATH LD_LIBRARY_PATH TNS_ADMIN
echo "Oracle Instant Client 19.5 installed"
echo
echo create a tnsnames.ora file in /home/oracle
EOF
  chown oracle:dba /home/oracle/.bash_profile
}

echo "========== Get argument(s) passed thru metadata"
DB_CLIENT_VERSION=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_db_client_version`

echo "========== Install and configure Oracle Instant client (including oracle user creation)"
case $DB_CLIENT_VERSION in
  18) install_oracle_instant_client_18.5 ;;
  19) install_oracle_instant_client_19.5 ;;
esac

echo "========== Configure SSH key for user oracle"
mkdir -p 700 /home/oracle/.ssh
cp -p /home/opc/.ssh/authorized_keys /home/oracle/.ssh/authorized_keys
chown -R oracle:dba /home/oracle/.ssh

echo "========== Install additional packages"
yum install zsh -y

echo "========== Apply latest updates to Linux OS"
yum update -y

echo "========== Final reboot"
reboot
