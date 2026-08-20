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

install_latest_deb_and_run() {
  local releases_url="${1:?usage: $0 RELEASES_URL [RUN_CMD...]}"
  shift || true

  local run_cmd=("$@")

  local script_dir deb_url tmp latest_page deb_file

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  latest_page="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "${releases_url}")"

  deb_url="$(
    curl -fsSL "${latest_page}" |
      grep -Eo 'https?://[^"]+\.deb' |
      head -n 1
  )"

  [[ -n "${deb_url}" ]] || { echo "Could not find a .deb asset for latest in: ${releases_url}" >&2; return 1; }

  deb_file="${script_dir}/$(basename "${deb_url}")"

  curl -fsSL "${deb_url}" -o "${deb_file}"

  sudo dpkg -i "${deb_file}" || sudo apt-get -f install -y

  if (( ${#run_cmd[@]} > 0 )); then
    "${run_cmd[@]}"
  else
    echo "Installed. Provide a command to run, e.g.:"
    echo "  $0 ${releases_url} <command> [args...]"
    return 0
  fi
}

sudo apt update && apt full-upgrade -y

sudo apt install -y flatpak vim wireguard

if is_gnome; then
  sudo apt install -y gnome-software-plugin-flatpak
fi

curl -fsSL "https://git.lan/dev/scripts/src/branch/main/setup-ubuntu.sh" | bash

# Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
wget -O signal-desktop.sources https://updates.signal.org/static/desktop/apt/signal-desktop.sources;
cat signal-desktop.sources | sudo tee /etc/apt/sources.list.d/signal-desktop.sources > /dev/null
sudo apt update && sudo apt install signal-desktop -y

# ntr
install_latest_deb_and_run "https://codeberg.org/musty8682/ntr-app/releases/"

# Helium
curl -fsSL https://raw.githubusercontent.com/imputnet/helium-linux/main/pubkey.asc | sudo gpg --dearmor -o /usr/share/keyrings/helium.gpg
echo "deb [signed-by=/usr/share/keyrings/helium.gpg] https://pkg.helium.computer/deb stable main" | sudo tee /etc/apt/sources.list.d/helium.list
sudo apt update && sudo apt install -y helium-bin

reboot