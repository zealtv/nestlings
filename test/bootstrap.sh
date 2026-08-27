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
cmp -s "$ROOT/README.md" "$REPO/.nest/README.md" || fail "installed README differs from protocol README"
assert_absent "$REPO/.loom"
assert_absent "$REPO/.lore"
assert_absent "$REPO/.glean"
assert_absent "$REPO/.groundhog"

# Re-installation repairs owned payloads and trays without changing local policy
# or material already waiting in the nest.
printf '# host policy\n\nKeep this customization.\n' > "$REPO/.nest/tend.md"
printf 'damaged\n' > "$REPO/.nest/README.md"
rm -rf "$REPO/.nest/out"
printf 'deferred\n' > "$REPO/.nest/in/deferred.md"
"$ROOT/install.sh" "$REPO" >/dev/null
assert_contains "$REPO/.nest/tend.md" "Keep this customization."
cmp -s "$ROOT/README.md" "$REPO/.nest/README.md" || fail "re-install did not repair README"
assert_exists "$REPO/.nest/out"
assert_contains "$REPO/.nest/in/deferred.md" "deferred"

# Composition examples remain documentation and host policy: the installed
# runtime does not invoke or require any sibling primitive.
if grep -Eiq 'loom|lore|glean|groundhog' "$REPO/.nest/nestling.sh" "$ROOT/install.sh"; then
  fail "optional composition leaked into the runtime"
fi

# Add only the pointer and material that this establishment request justifies.
printf 'For incoming material, read `.nest/tend.md` and inspect `.nest/in/`.\n' > "$REPO/AGENTS.md"
mkdir -p "$TMP/establish-repository/attachments"
printf '# establish\n\nRetain the attached brief under docs; add no optional tools yet.\n' > "$TMP/establish-repository/request.md"
printf '# initial brief\n' > "$TMP/establish-repository/attachments/brief.md"
"$REPO/.nest/nestling.sh" ingest "$TMP/establish-repository" >/dev/null
[[ "$("$REPO/.nest/nestling.sh" list)" == $'deferred.md\nestablish-repository' ]] || fail "deferred items are not visible with the establishment request"
"$REPO/.nest/nestling.sh" claim deferred.md >/dev/null
assert_exists "$REPO/.nest/in/deferred.md.tending"
"$REPO/.nest/nestling.sh" drop deferred.md "verified deferred capture" >/dev/null

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
