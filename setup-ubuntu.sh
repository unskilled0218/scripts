#!/bin/bash

sudo apt update && apt full-upgrade -y

sudo apt install -y flatpak vim wireguard nfs-common

curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/is_gnome.sh" -o /tmp/is_gnome.sh
source /tmp/is_gnome.sh

if is_gnome; then
  sudo apt install -y gnome-software-plugin-flatpak
fi

# flatpak things
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/install-flatpak-things.sh" | bash

# Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
sudo apt update && sudo apt install signal-desktop -y

# Helium
curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/helium.gpg
echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" | sudo tee /etc/apt/sources.list.d/helium.list
sudo apt update && sudo apt install -y helium-bin

# ntr
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/install_latest_deb_and_run.sh" | bash -s -- "https://codeberg.org/musty8682/ntr-app/releases/"

# Mount nfs
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/mount-nfs.sh" | bash

# Install custom certs
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/install-all-certs.sh" | bash
