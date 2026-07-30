#!/bin/bash

mkdir $1 && cd $1

# Root CA
openssl genrsa -out $1CA.key 4096
openssl req -x509 -new -nodes -key $1CA.key   -sha256 -days 3650   -out $1CA.crt   -subj "/CN=Local LAN $1 CA"

# Server cert config (SAN must include *.lan)
cat >> server-ext.cnf <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = $1
DNS = lan
EOF

# Server key + CSR
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr   -subj "/CN=$1"

# Sign server cert with CA
openssl x509 -req -in server.csr   -CA $1CA.crt -CAkey $1CA.key -CAcreateserial   -out server.crt -days 825 -sha256   -extfile server-ext.cnf

