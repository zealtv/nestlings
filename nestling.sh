#!/usr/bin/env bash
set -u

POLL_INTERVAL="${POLL_INTERVAL:-1}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEST="$ROOT/.nest"
IN="$NEST/in"
DONE="$NEST/done"
FAILED="$NEST/failed"
LOG_DIR="$NEST/log"
LOG_FILE="$LOG_DIR/nestling.log"

mkdir -p "$IN" "$DONE" "$FAILED" "$LOG_DIR"
touch "$LOG_FILE"

log() {
  printf '%s | nestling | %s | %s | %s\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" "$3" >> "$LOG_FILE"
}

tend() {
  local src="$1"
  local name hatching final
  name="$(basename "$src")"
  hatching="$DONE/$name.hatching"
  final="$DONE/$name"

  if ! content=$(cat "$src"); then
    mv "$src" "$FAILED/$name"
    log "FAIL" "$name" "could not read"
    return
  fi

  {
    printf '[tended by nestling]\n'
    printf '%s\n' "$content"
  } > "$hatching" || {
    rm -f "$hatching"
    mv "$src" "$FAILED/$name"
    log "FAIL" "$name" "could not write"
    return
  }

  if ! mv "$hatching" "$final"; then
    rm -f "$hatching"
    mv "$src" "$FAILED/$name"
    log "FAIL" "$name" "could not place in done"
    return
  fi

  rm -f "$src"
  log "OK" "$name" "tended"
}

echo "nestling tending its nest (POLL_INTERVAL=$POLL_INTERVAL)"
log "START" "-" "nestling started"

while true; do
  for src in "$IN"/*; do
    [ -f "$src" ] || continue
    case "$src" in *.hatching) continue;; esac
    tend "$src"
  done
  sleep "$POLL_INTERVAL"
done
