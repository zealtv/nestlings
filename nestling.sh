#!/usr/bin/env bash
set -u

POLL_INTERVAL="${POLL_INTERVAL:-1}"

NEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INBOX="$NEST/inbox"
DONE="$NEST/done"
FAILED="$NEST/failed"
LOG_DIR="$NEST/log"
LOG_FILE="$LOG_DIR/nestling.log"

mkdir -p "$INBOX" "$DONE" "$FAILED" "$LOG_DIR"
touch "$LOG_FILE"

log() {
  printf '%s | nestling | %s | %s | %s\n' \
    "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" "$3" >> "$LOG_FILE"
}

tend() {
  local src="$1"
  local ready_name name staged final
  ready_name="$(basename "$src")"
  name="${ready_name%.ready}"
  staged="$DONE/$name.incoming"
  final="$DONE/$name"

  if ! content=$(cat "$src"); then
    mv "$src" "$FAILED/$ready_name"
    log "FAIL" "$ready_name" "could not read"
    return
  fi

  {
    printf '[tended by nestling]\n'
    printf '%s\n' "$content"
  } > "$staged" || {
    rm -f "$staged"
    mv "$src" "$FAILED/$ready_name"
    log "FAIL" "$ready_name" "could not write"
    return
  }

  if ! mv "$staged" "$final"; then
    rm -f "$staged"
    mv "$src" "$FAILED/$ready_name"
    log "FAIL" "$ready_name" "could not place in done"
    return
  fi

  rm -f "$src"
  log "OK" "$ready_name" "tended"
}

echo "nestling tending its nest (POLL_INTERVAL=$POLL_INTERVAL)"
log "START" "-" "nestling started"

while true; do
  for src in "$INBOX"/*.ready; do
    [ -f "$src" ] || continue
    tend "$src"
  done
  sleep "$POLL_INTERVAL"
done
