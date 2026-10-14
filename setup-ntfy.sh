#!/bin/bash

sudo apt install ntfy libnotify-bin -y

mkdir -p ~/.config/ntfy

cat >> ~/.config/ntfy/client.yml <<EOF
default-host: https://ntfy.lan

subscribe:
- topic: general
  command: 'notify-send "$message"'
EOF

cat >> ~/.config/systemd/user/ntfy-client.service <<EOF
[Unit]
Description=ntfy client
After=network.target

[Service]
ExecStart=/usr/bin/ntfy subscribe --config "%h/.config/ntfy/client.yml" --from-config
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user enable ntfy-client
systemctl --user enable --now ntfy-client