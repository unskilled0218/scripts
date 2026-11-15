#!/usr/bin/env bash
set -euo pipefail

cat >> $HOME/.local/bin/wacom-set.sh <<EOF
#!/usr/bin/env bash

MAC="F8:A7:22:A7:2F:D7"  # Replace with your tablet's Bluetooth MAC

STYLUS="Wacom One pen tablet small stylus"
ERASER="Wacom One pen tablet small eraser"

SPEED=-0.3

was_connected=false

while true; do
  if bluetoothctl info "$MAC" 2>/dev/null | grep -q "Connected: yes"; then
    if [ "$was_connected" = false ]; then
      sleep 2  # Give the desktop time to recognize the tablet
      while true; do
        if xsetwacom --list devices 2>/dev/null | grep -Fq "$STYLUS"; then
          xsetwacom set "$STYLUS" Mode Relative
          xsetwacom set "$STYLUS" Rotate half

          xsetwacom set "$ERASER" Mode Relative
          xsetwacom set "$ERASER" Rotate half

          STYLUS_ID=$(xinput list --id-only "$STYLUS" 2>/dev/null | head -n1)
          ERASER_ID=$(xinput list --id-only "$STYLUS" 2>/dev/null | head -n1)
          if [[ -n "$STYLUS_ID" ]]; then
            xinput --set-prop "$STYLUS_ID" "libinput Accel Speed" $SPEED 2>/dev/null || true
          fi
          if [[ -n "$ERASER_ID" ]]; then
            xinput --set-prop "$ERASER_ID" "libinput Accel Speed" $SPEED 2>/dev/null || true
          fi
        fi
        sleep 3
      done
      was_connected=true
    fi
  else
    was_connected=false
  fi

  sleep 2
done
EOF

cat >> $HOME/.config/systemd/user/wacom-watch.service <<EOF
[Unit]
Description=Apply Wacom tablet settings when connected
After=bluetooth.target

[Service]
Type=simple
ExecStart=%h/.local/bin/wacom-set.sh
Restart=on-failure

[Install]
WantedBy=default.target
EOF

chmod +x $HOME/.local/bin/wacom-set.sh
systemctl --user daemon-reload
systemctl --user enable --now wacom-watch.service