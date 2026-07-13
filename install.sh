#!/usr/bin/env bash
# usage: ./install.sh <host-dir>
# Lays down a .nest/ at the host directory — a sanctioned standalone install
# for scopes not delivered by any bundle. Idempotent: re-running repairs
# nestling.sh and README.md and re-seeds missing trays; it never touches
# tray contents or the host-customized tend.md (copied only when absent).
# nestling.sh has no init subcommand, so the trays are seeded here.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target="${1:?usage: install.sh <host-dir>}"
[ -d "$target" ] || { echo "no such host dir: $target" >&2; exit 1; }

dest="$target/.nest"
mkdir -p "$dest/in" "$dest/out" "$dest/dropped"
cp -f "$REPO_DIR/.nest/nestling.sh" "$dest/nestling.sh"
chmod +x "$dest/nestling.sh"
cp -f "$REPO_DIR/README.md" "$dest/README.md"
if [ ! -e "$dest/tend.md" ] && [ -e "$REPO_DIR/.nest/tend.md" ]; then
  cp "$REPO_DIR/.nest/tend.md" "$dest/tend.md"
fi

echo "installed $dest"
