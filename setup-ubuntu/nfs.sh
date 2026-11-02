#!/usr/bin/env bash
set -euo pipefail

mount() {
  local nfsdirname="$1"
  local dirname="$2"

  mkdir -p $dirname
  cat >> /etc/fstab <<EOF
$nfsdirname $dirname nfs defaults,_netdev,nofail 0 0
EOF
}

SERVER="truenas.lan"

EXPORTS=(
  "/mnt/backup/my/sync"
  "/mnt/backup/my/Music"
  "/mnt/backup/theatre"
  "/mnt/backup/torrent"
  "/mnt/backup/my/wallpaper"
)

MOUNTPOINTS=(
  "/home/think/backup/sync"
  "/home/think/Music"
  "/home/think/backup/theatre"
  "/home/think/backup/torrent"
  "/home/think/backup/wallpaper"
)

if ((${#EXPORTS[@]} != ${#MOUNTPOINTS[@]})); then
  echo "Error: EXPORTS and MOUNTPOINTS must have the same number of entries." >&2
  exit 1
fi

for i in "${!EXPORTS[@]}"; do
  export_path=${EXPORTS[$i]}
  mountpoint_path=${MOUNTPOINTS[$i]}

  mkdir -p "$mountpoint_path"
  if ! mountpoint -q "$mountpoint_path"; then
    mount "${SERVER}:${export_path}" "$mountpoint_path"
  fi
done

sudo systemctl daemon-reload
sudo mount -a
