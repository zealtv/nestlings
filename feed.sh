#!/usr/bin/env bash
set -eu

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IN="$ROOT/.nest/in"
mkdir -p "$IN"

usage() {
  cat <<'EOF'
Usage:
  ./feed.sh --text "message" [name]
  ./feed.sh [--copy|--move] source_path [name]

Notes:
  --copy is the default and is the safer choice.
  The item is placed in .nest/in as name.hatching first, then renamed to name.
  If [name] is omitted for --text, feed.sh generates a short unique .txt filename.
EOF
}

generated_text_name() {
  printf 'note-%s-%s.txt' "$(date '+%Y%m%d-%H%M%S')" "$$"
}

mode="copy"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --copy)
      mode="copy"
      shift
      ;;
    --move)
      mode="move"
      shift
      ;;
    --text)
      message="${2:-}"
      [ -n "$message" ] || { echo "missing message for --text" >&2; exit 1; }
      name="${3:-$(generated_text_name)}"
      hatching="$IN/$name.hatching"
      final="$IN/$name"
      [ ! -e "$hatching" ] || { echo "already exists: $hatching" >&2; exit 1; }
      [ ! -e "$final" ] || { echo "already exists: $final" >&2; exit 1; }
      printf '%s\n' "$message" > "$hatching"
      mv "$hatching" "$final"
      echo "fed $final"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

src="${1:-}"
[ -n "$src" ] || { usage >&2; exit 1; }
[ -e "$src" ] || { echo "not found: $src" >&2; exit 1; }

name="${2:-$(basename "$src")}"
hatching="$IN/$name.hatching"
final="$IN/$name"

[ ! -e "$hatching" ] || { echo "already exists: $hatching" >&2; exit 1; }
[ ! -e "$final" ] || { echo "already exists: $final" >&2; exit 1; }

if [ "$mode" = "copy" ]; then
  if [ -d "$src" ]; then
    cp -R "$src" "$hatching"
  else
    cp "$src" "$hatching"
  fi
else
  mv "$src" "$hatching"
fi

mv "$hatching" "$final"
echo "fed $final ($mode)"
