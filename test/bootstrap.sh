#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
REPO="$TMP/fresh-repository"

fail() { echo "not ok - $*" >&2; exit 1; }
assert_exists() { [[ -e "$1" ]] || fail "missing $1"; }
assert_absent() { [[ ! -e "$1" ]] || fail "unexpected $1"; }
assert_contains() { grep -Fq -- "$2" "$1" || fail "$1 does not contain [$2]"; }

# Begin with an otherwise empty host and stream the upstream-shaped installer.
mkdir -p "$REPO"
(
  cd "$REPO"
  NESTLINGS_SOURCE_BASE="file://$ROOT" bash -s < "$ROOT/install.sh"
) >/dev/null
[[ "$(find "$REPO" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" == 1 ]] || fail "installer added more than .nest"
assert_exists "$REPO/.nest/nestling.sh"
assert_exists "$REPO/.nest/tend.md"
assert_absent "$REPO/.loom"
assert_absent "$REPO/.lore"
assert_absent "$REPO/.glean"
assert_absent "$REPO/.groundhog"

# Add only the pointer and material that this establishment request justifies.
printf 'For incoming material, read `.nest/tend.md` and inspect `.nest/in/`.\n' > "$REPO/AGENTS.md"
mkdir -p "$TMP/establish-repository/attachments"
printf '# establish\n\nRetain the attached brief under docs; add no optional tools yet.\n' > "$TMP/establish-repository/request.md"
printf '# initial brief\n' > "$TMP/establish-repository/attachments/brief.md"
"$REPO/.nest/nestling.sh" ingest "$TMP/establish-repository" >/dev/null
[[ "$("$REPO/.nest/nestling.sh" list)" == establish-repository ]] || fail "establishment request is not ready"

# Tend into the justified project structure and hatch a durable receipt.
"$REPO/.nest/nestling.sh" claim establish-repository >/dev/null
mkdir -p "$REPO/docs"
cp "$REPO/.nest/in/establish-repository.tending/attachments/brief.md" "$REPO/docs/brief.md"
printf '# repository established\n\n- retained the original brief at: path:docs/brief.md\n- added: nothing yet\n- next material belongs in: .nest/in/\n' > "$TMP/repository-established.md"
"$REPO/.nest/nestling.sh" complete establish-repository "$TMP/repository-established.md" repository-established.md >/dev/null

assert_exists "$REPO/docs/brief.md"
assert_exists "$REPO/.nest/out/repository-established.md"
assert_absent "$REPO/.nest/in/establish-repository.tending"
assert_contains "$REPO/.nest/out/repository-established.md" "path:docs/brief.md"
assert_contains "$REPO/.nest/out/repository-established.md" "added: nothing yet"

echo "ok - fresh repository established from a nest"
