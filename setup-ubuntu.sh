#!/bin/bash

sudo apt update && sudo apt full-upgrade -y

sudo apt install -y flatpak vim wireguard nfs-common software-properties-common

curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/is_gnome.sh" -o /tmp/is_gnome.sh
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/is_installed.sh" -o /tmp/is_installed.sh
source /tmp/is_gnome.sh
source /tmp/is_installed.sh

if is_gnome; then
  sudo apt install -y gnome-software-plugin-flatpak
fi

# flatpak add flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub com.vscodium.codium -y
flatpak install flathub io.freetubeapp.FreeTube -y
flatpak install flathub com.bitwarden.desktop -y
flatpak install flathub com.moonlight_stream.Moonlight -y
flatpak install flathub com.orcaslicer.OrcaSlicer -y
flatpak install flathub org.kde.haruna -y

if ! is_installed firefox; then
  flatpak install flathub org.mozilla.firefox -y
fi

if ! is_installed gedit; then
  flatpak install flathub org.gnome.gedit -y
fi

# Community

## Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
sudo apt update && sudo apt install signal-desktop -y

## Discord
flatpak install flathub com.discordapp.Discord -y

# Browser

## LibreWolf
sudo apt update && sudo apt install extrepo -y
sudo extrepo enable librewolf && sudo extrepo update librewolf
sudo apt update && sudo apt install librewolf -y

## Helium
curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/helium.gpg
echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" | sudo tee /etc/apt/sources.list.d/helium.list
sudo apt update && sudo apt install -y helium-bin

## TOR
flatpak install flathub org.torproject.torbrowser-launcher -y

## ungoogled chromium
sudo add-apt-repository -y ppa:xtradeb/apps
sudo apt update
sudo apt install -y ungoogled-chromium

# ntr
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/install-deb-and-run.sh" | bash -s -- "https://codeberg.org/musty8682/ntr-app/releases/"

# Mount nfs
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/mount-nfs.sh" | bash

# Install custom certs
curl -fsSLk "https://git.lan/dev/scripts/raw/branch/main/install-all-certs.sh" | bash
