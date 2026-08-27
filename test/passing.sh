#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
SENDER="$TMP/sender"
RECEIVER="$TMP/receiver"
ITEM="sender--review-brief--20260827"

fail() { echo "not ok - $*" >&2; exit 1; }
assert_exists() { [[ -e "$1" ]] || fail "missing $1"; }
assert_absent() { [[ ! -e "$1" ]] || fail "unexpected $1"; }
assert_contains() { grep -Fq -- "$2" "$1" || fail "$1 does not contain [$2]"; }

mkdir -p "$SENDER" "$RECEIVER"
"$ROOT/install.sh" "$SENDER" >/dev/null
"$ROOT/install.sh" "$RECEIVER" >/dev/null

# A partial landing is never listed, claimed, or mistaken for a complete item.
mkdir -p "$RECEIVER/.nest/in/partial.landing"
printf 'incomplete\n' > "$RECEIVER/.nest/in/partial.landing/chunk"
[[ -z "$("$RECEIVER/.nest/nestling.sh" list)" ]] || fail "partial landing was listed"
if "$RECEIVER/.nest/nestling.sh" claim partial >/dev/null 2>&1; then
  fail "partial landing was claimable"
fi
assert_exists "$RECEIVER/.nest/in/partial.landing/chunk"

# The sender addresses the adjacent receiving nest and passes one envelope.
mkdir -p "$TMP/request/attachments"
printf '# review brief\n\n- origin: %s\n- inbound item: %s\n- reply nest: %s\n' "$SENDER" "$ITEM" "$SENDER/.nest" > "$TMP/request/request.md"
printf '# brief\n\nPlease review this.\n' > "$TMP/request/attachments/brief.md"
"$RECEIVER/.nest/nestling.sh" ingest "$TMP/request" "$ITEM" >/dev/null
assert_exists "$RECEIVER/.nest/in/$ITEM/request.md"
assert_contains "$RECEIVER/.nest/in/$ITEM/request.md" "inbound item: $ITEM"

# A repeated name fails closed and leaves the first arrival unchanged.
printf 'replacement\n' > "$TMP/request/attachments/brief.md"
if "$RECEIVER/.nest/nestling.sh" ingest "$TMP/request" "$ITEM" >/dev/null 2>&1; then
  fail "duplicate pass overwrote the first arrival"
fi
assert_contains "$RECEIVER/.nest/in/$ITEM/attachments/brief.md" "Please review this."

# The receiver keeps its hatch record and sends a separate reply item back.
"$RECEIVER/.nest/nestling.sh" claim "$ITEM" >/dev/null
printf '# receiver receipt\n\nReviewed %s and sent a reply.\n' "$ITEM" > "$TMP/receiver-receipt.md"
"$RECEIVER/.nest/nestling.sh" complete "$ITEM" "$TMP/receiver-receipt.md" "$ITEM.receipt.md" >/dev/null
mkdir -p "$TMP/reply/attachments"
printf '# reply\n\n- replying to: %s\n' "$ITEM" > "$TMP/reply/request.md"
printf '# review\n\nApproved.\n' > "$TMP/reply/attachments/review.md"
"$SENDER/.nest/nestling.sh" ingest "$TMP/reply" receiver--reply--20260827 >/dev/null

assert_exists "$RECEIVER/.nest/out/$ITEM.receipt.md"
assert_exists "$SENDER/.nest/in/receiver--reply--20260827/request.md"
assert_contains "$SENDER/.nest/in/receiver--reply--20260827/request.md" "replying to: $ITEM"
assert_contains "$SENDER/.nest/in/receiver--reply--20260827/attachments/review.md" "Approved."
assert_absent "$SENDER/.nest/out/receiver--reply--20260827"

echo "ok - adjacent nests exchanged a request and reply"
