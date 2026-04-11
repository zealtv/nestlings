#!/usr/bin/env bash
set -eu

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IN="$ROOT/.nest/in"
mkdir -p "$IN"

MESSAGE="${1:-hello}"
NAME="${2:-sample.txt}"

HATCHING="$IN/$NAME.hatching"
FINAL="$IN/$NAME"

printf '%s\n' "$MESSAGE" > "$HATCHING"
mv "$HATCHING" "$FINAL"

echo "fed $FINAL"
