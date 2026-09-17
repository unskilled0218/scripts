#!/bin/bash

uid=1000
gid=$(getent passwd "$uid" | cut -d: -f4)

home=$(getent passwd "$uid" | cut -d: -f6) || return 1
[ -n "$home" ] || {
  echo "No user found with UID $uid" >&2
  return 1
}

mkuserdir() {
  local dirname="${1:-mydir}"

  sudo install -d -o "$uid" -g "$gid" -m 0755 "$home/$dirname"
}

mkuserdir nas
mkuserdir nas/media
mkuserdir nas/torrent
mkuserdir nas/theatre
mkuserdir nas/sync

cat >> /etc/fstab <<EOF
truenas.lan:/mnt/my-1/media/ /home/${USER}/nas/media nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/torrent/ /home/${USER}/nas/torrent nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/theatre/ /home/${USER}/nas/theatre nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/ /home/${USER}/nas/sync nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/Music /home/${USER}/Music nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/Pictures /home/${USER}/Pictures nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/My /home/${USER}/Documents/My nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/Notes /home/${USER}/Documents/Notes nfs defaults,_netdev,nofail 0 0
EOF

sudo systemctl daemon-reload
sudo mount -a