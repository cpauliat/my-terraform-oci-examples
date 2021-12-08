#!/bin/bash

### Send stdout and stderr to /var/log/cloud-init2.log
exec 1> /var/log/cloud-init2.log 2>&1

echo "========== Get argument(s) passed thru metadata"
HOST1_HOSTNAME=`curl -L http://169.254.169.254/opc/v1/instance/metadata/myarg_host1_hostname`

echo "========== Create SSH config file for user opc"
cat >> /home/opc/.ssh/config << EOF
Host $HOST1_HOSTNAME
    Hostname $HOST1_HOSTNAME
    User opc
    IdentityFile /home/opc/.ssh/sshkey_host1
    StrictHostKeyChecking no
EOF
chmod 600 /home/opc/.ssh/config
chown -R opc:opc /home/opc/.ssh

echo "========== Install Ansible"
yum install ansible -y

echo "========== Create ansible_hosts file in /home/opc"
mkdir -p -m 700 /home/opc/ansible
chown opc:opc /home/opc/ansible
cat  > /home/opc/ansible/ansible_hosts << EOF
[hosts_grp_1]
$HOST1_HOSTNAME
EOF
chown -R opc:opc /home/opc/ansible

echo "========== Wait for private ssh key file to be copied"
while [ ! -f /home/opc/.ssh/sshkey_host1 ]; do sleep 5; done
chmod 600 /home/opc/.ssh/sshkey_host1

echo "========== Wait for ansible_playbook.yml file to be copied"
while [ ! -f /home/opc/ansible_playbook.yml ]; do sleep 5; done
mv /home/opc/ansible_playbook.yml /home/opc/ansible/ansible_playbook.yml

echo "========== Run Ansible playbook"
su - opc -c "cd ~/ansible; ansible-playbook -i ./ansible_hosts ./ansible_playbook.yml 2>&1 | tee ansible_playbook.log" 

echo "========== Apply latest updates to Linux OS"
#yum update -y

echo "========== Final reboot"
#reboot
