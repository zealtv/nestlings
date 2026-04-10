#!/usr/bin/env bash
set -eu

NEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INBOX="$NEST/inbox"
mkdir -p "$INBOX"

MESSAGE="${1:-hello}"
NAME="${2:-sample.txt}"

STAGED="$INBOX/$NAME.incoming"
READY="$INBOX/$NAME.ready"

printf '%s\n' "$MESSAGE" > "$STAGED"
mv "$STAGED" "$READY"

echo "fed $READY"
