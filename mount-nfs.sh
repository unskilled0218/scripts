#!/bin/bash

uid=1000
gid=$(getent passwd "$uid" | cut -d: -f4)

home=$(getent passwd "$uid" | cut -d: -f6) || return 1
[ -n "$home" ] || {
  echo "No user found with UID $uid" >&2
  return 1
}

mount() {
  local nfsdirname="$1"
  local dirname="$2"

  sudo install -d -o "$uid" -g "$gid" -m 0775 "$home/$dirname"
  cat >> /etc/fstab <<EOF
truenas.lan:/mnt/my-1/${nfsdirname} $home/$dirname nfs defaults,_netdev,nofail 0 0
EOF
}

mkdir $home/nas
chown -R $uid:$gid $home/nas

mount media nas/media
mount torrent nas/torrent
mount theatre nas/theatre
mount sync nas/sync
mount sync/Sync/Music Music
mount sync/Sync/Pictures Pictures
mount sync/Sync/My Documents/My
mount sync/Sync/Notes Documents/Notes
mount sync/Sync/Books Documents/Books

sudo systemctl daemon-reload
sudo mount -a