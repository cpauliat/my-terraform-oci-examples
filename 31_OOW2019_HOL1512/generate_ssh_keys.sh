#!/bin/bash

# ---- SSH key pair (will create files sshkey and sshkey.pub)
rm -f ./sshkey ./sshkey.pub
ssh-keygen -t rsa -P "" -f ./sshkey
