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
