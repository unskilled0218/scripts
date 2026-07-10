#!/bin/bash

# Returns "true" if running under GNOME (Wayland or X11), otherwise "false"
is_gnome() {
  # GNOME on Wayland
  if [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ] || [ "${DESKTOP_SESSION:-}" = "gnome" ]; then
    return 0
  fi

  # GNOME on X11 (common cases)
  if [ "${XDG_SESSION_DESKTOP:-}" = "gnome" ] || [ "${DESKTOP_SESSION:-}" = "gnome" ]; then
    return 0
  fi

  # Fallback: check gnome-shell process
  if command -v pgrep >/dev/null 2>&1 && pgrep -x gnome-shell >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

sudo apt update && apt full-upgrade -y

sudo apt install -y flatpak syncthing wireguard vim wireguard

if is_gnome; then
  sudo apt install -y gnome-software-plugin-flatpak
fi

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub io.gitlab.librewolf-community -y
flatpak install flathub org.mozilla.firefox -y
flatpak install flathub org.torproject.torbrowser-launcher -y
flatpak install flathub com.discordapp.Discord -y
flatpak install flathub com.vscodium.codium -y
flatpak install flathub org.gnome.gedit -y
flatpak install flathub io.freetubeapp.FreeTube -y
flatpak install flathub com.bitwarden.desktop -y
flatpak install flathub io.github.ungoogled_software.ungoogled_chromium -y
flatpak install flathub org.qbittorrent.qBittorrent -y
flatpak install flathub com.moonlight_stream.Moonlight -y
flatpak install flathub io.bassi.Amberol -y
flatpak install flathub org.kde.haruna -y
flatpak install flathub com.orcaslicer.OrcaSlicer -y

wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
sudo apt update && sudo apt install signal-desktop -y

reboot