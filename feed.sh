#!/usr/bin/env bash
set -eu

NEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INBOX="$NEST/inbox"
mkdir -p "$INBOX"

MESSAGE="${1:-hello}"
NAME="${2:-sample.txt}"

HATCHING="$INBOX/$NAME.hatching"
FINAL="$INBOX/$NAME"

printf '%s\n' "$MESSAGE" > "$HATCHING"
mv "$HATCHING" "$FINAL"

echo "fed $FINAL"
