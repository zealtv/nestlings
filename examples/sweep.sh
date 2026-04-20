#!/usr/bin/env bash
set -eu

# Prune items in .nest/out/ older than N days (default 7).
# Run from the nest root: ./examples/sweep.sh [days]

DAYS="${1:-7}"
DIR="$PWD/.nest/out"

[ -d "$DIR" ] || { echo "no nest at $DIR" >&2; exit 1; }

find "$DIR" -mindepth 1 -maxdepth 1 ! -name '*.hatching' -mtime +"$DAYS" -print -exec rm -rf {} +
