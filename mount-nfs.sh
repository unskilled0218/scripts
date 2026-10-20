#!/bin/bash

mount() {
  local nfsdirname="$1"
  local dirname="$2"

  mkdir -p $dirname
  cat >> /etc/fstab <<EOF
$nfsdirname $dirname nfs defaults,_netdev,nofail 0 0
EOF
}

mount truenas.lan:/mnt/my-1/sync /home/think/my-1/sync
mount truenas.lan:/mnt/my-1/sync/Music /home/think/Music
mount truenas.lan:/mnt/my-1/sync/Pictures /home/think/Pictures
mount truenas.lan:/mnt/my-1/sync/Sync/My /home/think/Documents/My
mount truenas.lan:/mnt/my-1/sync/Sync/Notes /home/think/Documents/Notes

sudo systemctl daemon-reload
sudo mount -a