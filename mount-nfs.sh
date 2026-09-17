#!/bin/bash

mkdir -p /home/${USER}/nas /home/${USER}/nas/media /home/${USER}/nas/torrent /home/${USER}/nas/theatre /home/${USER}/nas/sync

sudo cat >> /etc/fstab <<EOF
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