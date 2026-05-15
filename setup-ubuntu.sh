#!/bin/bash

sudo apt update && apt full-upgrade -y

sudo apt install -y flatpak
sudo apt install gnome-software-plugin-flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub io.gitlab.librewolf-community -y
flatpak install flathub org.torproject.torbrowser-launcher -y
flatpak install flathub com.discordapp.Discord -y
flatpak install flathub com.vscodium.codium -y
flatpak install flathub io.freetubeapp.FreeTube -y
flatpak install flathub com.bitwarden.desktop -y
flatpak install flathub io.github.ungoogled_software.ungoogled_chromium -y

wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
sudo apt update && sudo apt install signal-desktop -y

sudo apt install -y syncthing