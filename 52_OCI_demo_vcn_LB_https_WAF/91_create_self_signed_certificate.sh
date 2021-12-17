#!/bin/bash

# This script creates a self signed certificate as described in MOS note
# Oracle Cloud Infrastructure - How Create a SSL Certificate for a Load Balancer (Doc ID 2617046.1)
#
# it will generate several files including the following files needed by OCI LOAD BALANCER in HTTPS mode
# - loadbalancer.crt
# - ca.crt
# - loadbalancer.key

cd cert
openssl genrsa -out ca.key 2048
openssl req -new -key ca.key -out ca.csr -subj "/C=FR/ST=PACA/L=Aix/O=cpauliat/OU=home/CN=lb07c.cpauliat.eu"
openssl x509 -req -in ca.csr -signkey ca.key -out ca.crt
openssl genrsa -out loadbalancer.key 2048
openssl req -new -key loadbalancer.key -out loadbalancer.csr -subj "/C=FR/ST=PACA/L=Aix/O=cpauliat/OU=home/CN=lb07c.cpauliat.eu"
openssl x509 -req -in loadbalancer.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out loadbalancer.crt -days 50000
openssl x509 -in loadbalancer.crt -text
