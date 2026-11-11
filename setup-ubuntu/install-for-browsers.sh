#!/bin/bash
set -euo pipefail
nss_database="sql:$HOME/.pki/nssdb"

# chromium
if ! command -v certutil >/dev/null 2>&1; then
  sudo apt install -y libnss3-tools
fi

mkdir -p "$HOME/.pki/nssdb"

if [[ ! -f "$HOME/.pki/nssdb/cert9.db" ]]; then
  certutil -N -d "$nss_database" --empty-password
fi

find "$cert_destination" -type f -name '*.crt' -print0 |
  while IFS= read -r -d '' cert; do
    certutil -d "$nss_database" -A \
      -n "${cert##*/}" -t "C,," -i "$cert"
    echo "Imported: $cert into $nss_database"
  done

# Run install-all-certs.sh first, then close LibreWolf before running this script.
cert_source="/usr/local/share/ca-certificates"
librewolf_profiles="$HOME/.var/app/io.gitlab.librewolf-community/.librewolf"

librewolf_databases=()
if [[ -d "$librewolf_profiles" ]]; then
  mapfile -d '' -t librewolf_databases < <(find "$librewolf_profiles" -type f -name 'cert9.db' -print0)
fi

if ((${#librewolf_databases[@]} == 0)); then
  echo "No LibreWolf Flatpak profiles found. Launch LibreWolf once, close it, then rerun this script." >&2
  exit 1
fi

if [[ ! -d "$cert_source" ]]; then
  echo "Certificate directory not found: $cert_source. Run install-all-certs.sh first." >&2
  exit 1
fi

if ! command -v certutil >/dev/null 2>&1; then
  sudo apt install -y libnss3-tools
fi

find "$cert_source" -type f -name '*.crt' -print0 |
  while IFS= read -r -d '' cert; do
    for database in "${librewolf_databases[@]}"; do
      nss_database="sql:${database%/*}"
      certutil -d "$nss_database" -A \
        -n "${cert##*/}" -t "C,," -i "$cert"
      echo "Imported: $cert into $nss_database"
    done
  done
