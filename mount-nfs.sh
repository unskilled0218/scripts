#!/bin/bash

mkdir -p ~/nas ~/nas/media ~/nas/torrent ~/nas/theatre ~/nas/sync

cat >> /etc/fstab <<EOF
truenas.lan:/mnt/my-1/media/ /home/think/nas/media nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/torrent/ /home/think/nas/torrent nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/theatre/ /home/think/nas/theatre nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/ /home/think/nas/sync nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/Music /home/think/Music nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/Pictures /home/think/Pictures nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/My /home/think/Documents/My nfs defaults,_netdev,nofail 0 0
truenas.lan:/mnt/my-1/sync/Sync/Notes /home/think/Documents/Notes nfs defaults,_netdev,nofail 0 0
EOF