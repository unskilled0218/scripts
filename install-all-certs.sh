#!/bin/bash

if [ -z "$1" ]; then
  echo "Need certs path"
  exit 0
fi

mapfile -t paths < <(find $1 -type f -name "*.lanCA.crt" -print)

if ((${#paths[@]} == 0)); then
  echo "empty"
else
  for p in "${paths[@]}"; do
    ca="$(basename "$p")"
    sudo cp $p /usr/local/share/ca-certificates/$ca
    sudo update-ca-certificates
    openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /usr/local/share/ca-certificates/$ca.crt
  done
fi
