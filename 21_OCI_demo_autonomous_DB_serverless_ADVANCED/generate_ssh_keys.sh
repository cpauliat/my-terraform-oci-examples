#!/bin/bash

mkdir -p sshkeys
cd sshkeys
rm -f ./id_rsa_bastion* ./id_rsa_dbclient*
ssh-keygen -t rsa -P "" -f ./id_rsa_bastion
ssh-keygen -t rsa -P "" -f ./id_rsa_dbclient
