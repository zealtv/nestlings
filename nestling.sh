#!/usr/bin/env bash
set -u

POLL_INTERVAL="${POLL_INTERVAL:-1}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEST="$ROOT/.nest"
IN="$NEST/in"
OUT="$NEST/out"
FAILED="$NEST/failed"
LOG_DIR="$NEST/log"
LOG_FILE="$LOG_DIR/nestling.log"

mkdir -p "$IN" "$OUT" "$FAILED" "$LOG_DIR"
touch "$LOG_FILE"

log() {
  printf '%s | nestling | %s | %s | %s\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" "$3" >> "$LOG_FILE"
}

store() {
  local src="$1"
  local name hatching final
  name="$(basename "$src")"
  hatching="$OUT/$name.hatching"
  final="$OUT/$name"

  if ! mv "$src" "$hatching"; then
    mv "$src" "$FAILED/$name" 2>/dev/null || true
    log "FAIL" "$name" "could not move to out staging"
    return
  fi

  if ! mv "$hatching" "$final"; then
    mv "$hatching" "$FAILED/$name" 2>/dev/null || true
    log "FAIL" "$name" "could not place in out"
    return
  fi

  log "OK" "$name" "stored in out"
}

echo "nestling tending its nest (POLL_INTERVAL=$POLL_INTERVAL)"
log "START" "-" "nestling started"

while true; do
  for src in "$IN"/*; do
    [ -e "$src" ] || continue
    case "$src" in *.hatching) continue;; esac
    store "$src"
  done
  sleep "$POLL_INTERVAL"
done
