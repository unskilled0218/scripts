#!/bin/bash

mapfile -t paths < <(find ~/backup/sync/certs -type f -name "*.lanCA.crt" -print)

if ((${#paths[@]} == 0)); then
  echo "empty"
else
  for p in "${paths[@]}"; do
    ca="$(basename "$p")"
    sudo cp $p /usr/local/share/ca-certificates/$ca
    sudo update-ca-certificates
    openssl verify -CAfile /etc/ssl/certs/ca-certificates.crt /usr/local/share/ca-certificates/$ca
  done
fi
