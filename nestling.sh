#!/usr/bin/env bash
set -u

POLL_INTERVAL="${POLL_INTERVAL:-1}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEST="$ROOT/.nest"
IN="$NEST/in"
OUT="$NEST/out"
DROPPED="$NEST/dropped"

mkdir -p "$IN" "$OUT" "$DROPPED"

say() {
  printf '%s nestling: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

drop() {
  local src="$1" name="$2" reason="$3"
  mv "$src" "$DROPPED/$name" 2>/dev/null || true
  printf '# %s\n\n%s\n' "$name" "$reason" > "$DROPPED/$name.reason.md"
  say "dropped $name: $reason"
}

tend() {
  local src="$1"
  local name claim hatching final
  name="$(basename "$src")"
  claim="$IN/$name.tending"
  hatching="$OUT/$name.hatching"
  final="$OUT/$name"

  if [ -e "$final" ] || [ -e "$hatching" ]; then
    drop "$src" "$name" "out/$name already exists"
    return
  fi

  mv "$src" "$claim" 2>/dev/null || return

  if ! mv "$claim" "$hatching"; then
    drop "$claim" "$name" "could not stage in out/"
    return
  fi

  if ! mv "$hatching" "$final"; then
    drop "$hatching" "$name" "could not finalize in out/"
    return
  fi
}

say "tending $NEST (POLL_INTERVAL=$POLL_INTERVAL)"

while true; do
  for src in "$IN"/*; do
    [ -e "$src" ] || continue
    case "$src" in
      *.hatching) continue;;
      *.tending) continue;;
    esac
    tend "$src"
  done
  sleep "$POLL_INTERVAL"
done
