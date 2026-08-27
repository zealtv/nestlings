#!/usr/bin/env bash
# usage: ./install.sh [host-dir]
# Lays down a .nest/ at the host directory — a sanctioned standalone install
# for scopes not delivered by any bundle. Idempotent: re-running repairs
# nestling.sh and README.md and re-seeds missing trays; it never touches
# tray contents or the host-customized tend.md (copied only when absent).
# When streamed rather than run from a checkout, payloads come from upstream.
set -euo pipefail

UPSTREAM_BASE="${NESTLINGS_SOURCE_BASE:-https://raw.githubusercontent.com/zealtv/nestlings/main}"
script_source="${BASH_SOURCE[0]:-}"
repo_dir=""
if [[ -n "$script_source" ]]; then
  candidate="$(cd "$(dirname "$script_source")" && pwd)"
  if [[ -f "$candidate/.nest/nestling.sh" && -f "$candidate/README.md" ]]; then
    repo_dir="$candidate"
  fi
fi

install_payload() {
  local relative="$1" destination="$2" landing="$2.landing"

  if [[ -n "$repo_dir" ]]; then
    cp -f "$repo_dir/$relative" "$destination"
    return
  fi

  command -v curl >/dev/null 2>&1 || {
    echo "curl is required when install.sh is streamed" >&2
    exit 1
  }
  [[ ! -e "$landing" ]] || {
    echo "temporary path already exists: $landing" >&2
    exit 1
  }
  if ! curl -fsSL "$UPSTREAM_BASE/$relative" -o "$landing"; then
    rm -f "$landing"
    exit 1
  fi
  mv -f "$landing" "$destination"
}

target="${1:-.}"
[ -d "$target" ] || { echo "no such host dir: $target" >&2; exit 1; }

dest="$target/.nest"
mkdir -p "$dest/in" "$dest/out" "$dest/dropped"
install_payload .nest/nestling.sh "$dest/nestling.sh"
chmod +x "$dest/nestling.sh"
install_payload README.md "$dest/README.md"
if [ ! -e "$dest/tend.md" ]; then
  install_payload .nest/tend.md "$dest/tend.md"
fi

echo "installed $dest"
