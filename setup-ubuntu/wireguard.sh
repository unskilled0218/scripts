#!/usr/bin/env bash
set -euo pipefail

sudo nmcli connection modify "Wired connection 1" connection.id "Home Ethernet"

sudo cat >> /etc/NetworkManager/dispatcher.d/91-wg-home <<EOF
#!/bin/bash

HOME_CONNECTION='Home Ethernet'
WG_SERVICE='wg-quick@home'

case "$2" in
  up|down) ;;
  *) exit 0 ;;
esac

if nmcli -t -f NAME connection show --active | grep -Fqx "$HOME_CONNECTION"; then
  nmcli radio wifi off
  systemctl stop "$WG_SERVICE"
else
  nmcli radio wifi on
  systemctl start "$WG_SERVICE"
fi
EOF