#!/bin/bash

# ---- API key pair (will create files apikey.pem and apikey_public.pem)
# ---- see doc on https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm
openssl genrsa -out ./apikey.pem 2048
chmod 600 ./apikey.pem
openssl rsa -pubout -in ./apikey.pem -out ./apikey_public.pem 
