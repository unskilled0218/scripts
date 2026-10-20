#!/usr/bin/env bash
set -euo pipefail

sudo cat >> /usr/local/sbin/mount-nfs-when-wired.sh <<EOF
#!/usr/bin/env bash
set -euo pipefail

SERVER="truenas.lan"

EXPORTS=(
  "/mnt/my-1/theatre"
  "/mnt/my-1/torrent"
  "/mnt/my-1/dash-board-wallpaper"
  "/mnt/my-1/container"
)

MOUNTPOINTS=(
  "/home/think/my-1/theatre"
  "/home/think/my-1/torrent"
  "/home/think/my-1/wallpaper"
  "/home/think/my-1/container"
)

if ((${#EXPORTS[@]} != ${#MOUNTPOINTS[@]})); then
  echo "Error: EXPORTS and MOUNTPOINTS must have the same number of entries." >&2
  exit 1
fi

# Consider the NFS server available only if its NFS port responds.
server_up=false
if timeout 3 nc -z "$SERVER" 2049 >/dev/null 2>&1; then
  server_up=true
fi

for i in "${!EXPORTS[@]}"; do
  export_path=${EXPORTS[$i]}
  mountpoint_path=${MOUNTPOINTS[$i]}

  if [[ "$server_up" == true ]]; then
    mkdir -p "$mountpoint_path"
    if ! mountpoint -q "$mountpoint_path"; then
      mount -t nfs "${SERVER}:${export_path}" "$mountpoint_path"
    fi
  elif mountpoint -q "$mountpoint_path"; then
    echo "NFS server unavailable; unmounting $mountpoint_path"
    umount "$mountpoint_path" || {
      echo "Could not unmount $mountpoint_path (it may be busy)." >&2
    }
  fi
done
EOF

sudo chmod 0700 /usr/local/sbin/mount-nfs-when-wired.sh

sudo cat >> /etc/NetworkManager/dispatcher.d/90-mount-nfs-when-wired <<EOF
#!/usr/bin/env bash

# NetworkManager passes the interface name as $1 and the event as $2.
if [[ "${2:-}" == "up" ]]; then
  /usr/local/sbin/mount-nfs-when-wired.sh
fi
EOF

sudo chown root:root /etc/NetworkManager/dispatcher.d/90-mount-nfs-when-wired
sudo chmod 0700 /etc/NetworkManager/dispatcher.d/90-mount-nfs-when-wired
