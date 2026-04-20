#!/usr/bin/env bash
set -u

POLL_INTERVAL="${POLL_INTERVAL:-1}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEST="$ROOT/.nest"
IN="$NEST/in"
OUT="$NEST/out"
UNHATCHED="$NEST/unhatched"

mkdir -p "$IN" "$OUT" "$UNHATCHED"

say() {
  printf '%s nestling: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2
}

unhatch() {
  local src="$1" name="$2" reason="$3"
  mv "$src" "$UNHATCHED/$name" 2>/dev/null || true
  printf '# %s\n\n%s\n' "$name" "$reason" > "$UNHATCHED/$name.reason.md"
  say "unhatched $name: $reason"
}

tend() {
  local src="$1"
  local name claim hatching final
  name="$(basename "$src")"
  claim="$IN/$name.tending"
  hatching="$OUT/$name.hatching"
  final="$OUT/$name"

  if [ -e "$final" ] || [ -e "$hatching" ]; then
    unhatch "$src" "$name" "out/$name already exists"
    return
  fi

  mv "$src" "$claim" 2>/dev/null || return

  if ! mv "$claim" "$hatching"; then
    unhatch "$claim" "$name" "could not stage in out/"
    return
  fi

  if ! mv "$hatching" "$final"; then
    unhatch "$hatching" "$name" "could not finalize in out/"
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
