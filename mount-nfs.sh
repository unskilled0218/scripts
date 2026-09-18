#!/bin/bash

mount() {
  local nfsdirname="$1"
  local dirname="$2"

  mkdir -p $dirname
  cat >> /etc/fstab <<EOF
$nfsdirname $dirname nfs defaults,_netdev,nofail 0 0
EOF
}

mount truenas.lan:/mnt/my-1/media ~/nas/media
mount truenas.lan:/mnt/my-1/torrent ~/nas/torrent
mount truenas.lan:/mnt/my-1/theatre ~/nas/theatre
mount truenas.lan:/mnt/my-1/sync ~/nas/sync
mount truenas.lan:/mnt/my-1/sync/Sync/Music ~/Music
mount truenas.lan:/mnt/my-1/sync/Sync/Pictures ~/Pictures
mount truenas.lan:/mnt/my-1/sync/Sync/My ~/Documents/My
mount truenas.lan:/mnt/my-1/sync/Sync/Notes ~/Documents/Notes
mount truenas.lan:/mnt/my-1/sync/Sync/Books ~/Documents/Books

sudo systemctl daemon-reload
sudo mount -a