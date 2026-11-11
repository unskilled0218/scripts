#!/bin/bash
set -euo pipefail

cert_source="$HOME/backup/sync/certs"
cert_destination="/usr/local/share/ca-certificates"
ca_bundle="/etc/ssl/certs/ca-certificates.crt"

if [[ ! -d "$cert_source" ]]; then
  echo "Certificate directory not found: $cert_source" >&2
  exit 1
fi

mapfile -d '' -t certificates < <(find "$cert_source" -type f -name '*.lanCA.crt' -print0)

if ((${#certificates[@]} == 0)); then
  echo "No *.lanCA.crt certificates found in $cert_source"
else
  sudo mkdir -p "$cert_destination"
  for cert in "${certificates[@]}"; do
    sudo cp -- "$cert" "$cert_destination/${cert##*/}"
  done

  sudo update-ca-certificates

  for cert in "${certificates[@]}"; do
    openssl verify -CAfile "$ca_bundle" "$cert_destination/${cert##*/}"
  done
fi
