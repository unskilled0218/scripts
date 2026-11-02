#!/bin/bash

local releases_url="${1:?usage: $0 RELEASES_URL [RUN_CMD...]}"
local pkg_ext="$2"
shift || true

local run_cmd=("$@")

local script_dir pkg_url tmp latest_page pkg_file

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

latest_page="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "${releases_url}")"

pkg_url="$(
  curl -fsSL "${latest_page}" |
    grep -Eo 'https?://[^"]+\.pkg' |
    head -n 1
)"

[[ -n "${pkg_url}" ]] || { echo "Could not find a .pkg asset for latest in: ${releases_url}" >&2; return 1; }

pkg_file="${script_dir}/$(basename "${pkg_url}")"

curl -fsSL "${pkg_url}" -o "${pkg_file}"

if [[ "$value" == "deb" ]]; then
  sudo dpkg -i "${pkg_file}" || sudo apt-get -f install -y
elif [[ "$value" == "flatpak" ]]; then
  flatpak install -y --user "${pkg_file}"
else
  echo "It's neither deb nor flatpak"
fi

if (( ${#run_cmd[@]} > 0 )); then
  "${run_cmd[@]}"
else
  echo "Installed. Provide a command to run, e.g.:"
  echo "  $0 ${releases_url} <command> [args...]"
  return 0
fi