#!/bin/bash

sudo cp $1/$1CA.crt /usr/local/share/ca-certificates/$1CA.crt
sudo update-ca-certificates
openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /usr/local/share/ca-certificates/$1CA.crt
