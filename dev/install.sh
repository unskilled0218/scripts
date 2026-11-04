#!/usr/bin/env bash
set -euo pipefail

source_dir=''
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
  source_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
fi
force=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      cat <<'HELP'
Usage: install.sh [--force] [--source directory]
Install dhelp, dup, de, cdc, and update-scripts into ~/.local/bin.
Protect unrelated files and locally edited commands unless --force is used.
Use --source to install commands from another directory.
Requires Bash, sha256sum, and standard GNU file utilities. No sudo is needed.
When piped into Bash, also requires Git and downloads main from https://git.lan/dev/scripts.
Set GITEA_TOKEN for private repository access, or use Git's credential helper.
The Git download verifies TLS; the server certificate must be trusted.
HELP
      exit 0
      ;;
    --force) force=true; shift ;;
    --source)
      if [[ $# -lt 2 || -z "$2" ]]; then
        printf 'Option --source requires a directory.\n' >&2
        exit 2
      fi
      source_dir="$2"
      shift 2
      ;;
    *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
  esac
done

if [[ -z "$source_dir" ]]; then
  if ! command -v git >/dev/null 2>&1; then
    printf 'Git is required for installation through curl | bash.\n' >&2
    exit 1
  fi
  temporary=$(mktemp -d "${TMPDIR:-/tmp}/dev-scripts-install.XXXXXXXX")
  trap 'rm -rf -- "$temporary"' EXIT
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM
  if [[ -n "${GITEA_TOKEN:-}" ]]; then
    cat > "$temporary/askpass" <<'ASKPASS'
#!/usr/bin/env bash
case "$1" in
  *Username*) printf '%s\n' 'oauth2' ;;
  *) printf '%s\n' "$GITEA_TOKEN" ;;
esac
ASKPASS
    chmod 700 "$temporary/askpass"
    export GIT_ASKPASS="$temporary/askpass"
  fi
  GIT_TERMINAL_PROMPT=0 git -c http.sslVerify=true clone --quiet --depth 1 --single-branch \
    --branch main -- https://git.lan/dev/scripts.git "$temporary/repository" </dev/null
  options=()
  if [[ "$force" == true ]]; then
    options=(--force)
  fi
  bash "$temporary/repository/dev/install.sh" "${options[@]}" \
    --source "$temporary/repository/dev" </dev/null
  exit 0
fi

commands=(dhelp dup de cdc update-scripts)
destination="$HOME/.local/bin"
state="$HOME/.local/share/dev-scripts"
manifest="$state/checksums"
declare -A previous=()
if [[ -f "$manifest" ]]; then
  while read -r checksum name; do
    if [[ "$checksum" =~ ^[0-9a-f]{64}$ && "$name" =~ ^(dhelp|dup|de|cdc|update-scripts)$ ]]; then
      previous["$name"]="$checksum"
    fi
  done < "$manifest"
fi

for name in "${commands[@]}"; do
  if [[ ! -f "$source_dir/$name" ]]; then
    printf 'Source command not found: %s\n' "$source_dir/$name" >&2
    exit 1
  fi
  bash -n "$source_dir/$name"
  target="$destination/$name"
  if [[ -d "$target" && ! -L "$target" ]]; then
    printf 'Destination is a directory: %s\n' "$target" >&2
    exit 1
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    managed=false
    if [[ -f "$target" && ! -L "$target" && -n "${previous[$name]:-}" ]]; then
      checksum=$(sha256sum -- "$target")
      [[ "${checksum%% *}" != "${previous[$name]}" ]] || managed=true
    fi
    if [[ "$managed" == false && "$force" == false ]]; then
      printf 'Unmanaged or edited command; use --force to replace: %s\n' "$target" >&2
      exit 1
    fi
  fi
done

mkdir -p -- "$destination" "$state"
# Staging beside the commands allows atomic replacement of individual files.
stage=$(mktemp -d "$destination/.dev-scripts.XXXXXXXX")
changed=()
complete=false
cleanup() {
  status=$?
  trap - EXIT HUP INT TERM
  if [[ "$complete" == false ]]; then
    for name in "${changed[@]}"; do
      if [[ -e "$stage/backup/$name" || -L "$stage/backup/$name" ]]; then
        mv -fT -- "$stage/backup/$name" "$destination/$name" || printf 'Could not restore %s\n' "$name" >&2
      else
        rm -f -- "$destination/$name"
      fi
    done
  fi
  rm -rf -- "$stage"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
mkdir -- "$stage/backup"
for name in "${commands[@]}"; do
  install -m 755 -- "$source_dir/$name" "$stage/$name"
  bash -n "$stage/$name"
  checksum=$(sha256sum -- "$stage/$name")
  printf '%s %s\n' "${checksum%% *}" "$name" >> "$stage/checksums"
  if [[ -e "$destination/$name" || -L "$destination/$name" ]]; then
    cp -a -- "$destination/$name" "$stage/backup/$name"
  fi
done
for name in "${commands[@]}"; do
  changed+=("$name")
  mv -fT -- "$stage/$name" "$destination/$name"
done
mv -fT -- "$stage/checksums" "$manifest"
complete=true
printf 'Installed or updated: %s\n' "${commands[*]}"
case ":${PATH:-}:" in
  *":$destination:"*) ;;
  *) printf 'Add this line to your shell startup file (for example, ~/.bashrc):\nexport PATH="$HOME/.local/bin:$PATH"\n' ;;
esac
