#!/usr/bin/env bash
set -euo pipefail

APP_ID="io.gitlab.librewolf-community"
CERT="${1:-}"

if [[ -z "$CERT" || ! -f "$CERT" ]]; then
    echo "Usage: $0 /path/to/custom-ca.crt"
    exit 1
fi

if ! command -v flatpak >/dev/null 2>&1; then
    echo "Error: flatpak is not installed."
    exit 1
fi

if ! flatpak info "$APP_ID" >/dev/null 2>&1; then
    echo "Error: LibreWolf Flatpak is not installed."
    exit 1
fi

if ! command -v certutil >/dev/null 2>&1; then
    echo "Installing NSS tools..."
    sudo apt update
    sudo apt install -y libnss3-tools
fi

if pgrep -af 'librewolf' >/dev/null; then
    echo "Close LibreWolf completely before continuing."
    exit 1
fi

PROFILE_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/librewolf"

if [[ ! -d "$PROFILE_ROOT" ]]; then
    echo "LibreWolf profile directory not found."
    echo "Start LibreWolf once, create/open a profile, close it, and rerun this script."
    exit 1
fi

PROFILE="$(
    find "$PROFILE_ROOT" -mindepth 1 -maxdepth 2 -type f -name prefs.js \
        -printf '%h\n' | head -n 1
)"

if [[ -z "$PROFILE" ]]; then
    echo "Could not find a LibreWolf profile."
    exit 1
fi

DB="$PROFILE"

# Create the NSS database if it does not yet exist.
if [[ ! -f "$DB/cert9.db" ]]; then
    certutil -N -d "sql:$DB" --empty-password
fi

CERT_NAME="$(basename "$CERT")"
NICKNAME="Custom CA - $CERT_NAME"

# Replace an existing certificate with the same nickname.
certutil -D \
    -d "sql:$DB" \
    -n "$NICKNAME" 2>/dev/null || true

certutil -A \
    -d "sql:$DB" \
    -n "$NICKNAME" \
    -t "C,," \
    -i "$CERT"

echo "Imported certificate into:"
echo "  $PROFILE"
echo
echo "Certificate nickname:"
echo "  $NICKNAME"
echo
echo "Restart LibreWolf and test the affected HTTPS site."
