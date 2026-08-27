#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() { echo "not ok - $*" >&2; exit 1; }
assert_exists() { [[ -e "$1" ]] || fail "missing $1"; }
assert_absent() { [[ ! -e "$1" ]] || fail "unexpected $1"; }
assert_eq() { [[ "$1" == "$2" ]] || fail "expected [$2], got [$1]"; }
assert_contains() { grep -Fq -- "$2" "$1" || fail "$1 does not contain [$2]"; }

new_nest() {
  local name="$1"
  mkdir -p "$TMP/$name/.nest"
  cp "$ROOT/.nest/nestling.sh" "$TMP/$name/.nest/nestling.sh"
  chmod +x "$TMP/$name/.nest/nestling.sh"
  "$TMP/$name/.nest/nestling.sh" ensure
  NEST="$TMP/$name/.nest"
  NESTLING="$NEST/nestling.sh"
}

claim_dir() {
  local name="$1"
  mkdir -p "$NEST/in/$name"
  "$NESTLING" claim "$name" >/dev/null
}

claim_file() {
  local name="$1"
  printf 'payload\n' > "$NEST/in/$name"
  "$NESTLING" claim "$name" >/dev/null
}

install_racing_mv() {
  local match="$1"
  mkdir -p "$TMP/bin"
  rm -f "$TMP/raced"
  command -v mv > "$TMP/real-mv"
  cat > "$TMP/bin/mv" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
real_mv="$(<"$RACE_ROOT/real-mv")"
dst="${@: -1}"
if [[ "$dst" == "$RACE_MATCH" && ! -e "$RACE_ROOT/raced" ]]; then
  touch "$RACE_ROOT/raced"
  mkdir -p "$dst"
fi
exec "$real_mv" "$@"
EOF
  chmod +x "$TMP/bin/mv"
  export PATH="$TMP/bin:$PATH" RACE_ROOT="$TMP" RACE_MATCH="$match"
}

# Existing lifecycle remains intact.
new_nest lifecycle
printf 'one\n' > "$TMP/source"
"$NESTLING" ingest "$TMP/source" item >/dev/null
assert_eq "$("$NESTLING" list)" item
"$NESTLING" claim item >/dev/null
printf 'done\n' > "$TMP/result"
"$NESTLING" complete item "$TMP/result" >/dev/null
assert_exists "$NEST/out/item"
"$NESTLING" sweep 0 >/dev/null
assert_absent "$NEST/out/item"

# A quick prose capture and a material-plus-note envelope can wait together.
new_nest capture
printf '# check release notes\n\nCompare the draft with the last tag.\n' > "$TMP/check-release-notes.md"
mkdir -p "$TMP/review-source/attachments"
printf '# request\n\nSummarise the attached source.\n' > "$TMP/review-source/request.md"
printf 'source material\n' > "$TMP/review-source/attachments/source.txt"
"$NESTLING" ingest "$TMP/check-release-notes.md" >/dev/null
"$NESTLING" ingest "$TMP/review-source" >/dev/null
assert_eq "$("$NESTLING" list)" $'check-release-notes.md\nreview-source'
assert_contains "$NEST/in/check-release-notes.md" "Compare the draft"
assert_contains "$NEST/in/review-source/request.md" "Summarise the attached source"
assert_contains "$NEST/in/review-source/attachments/source.txt" "source material"
"$NESTLING" claim review-source >/dev/null
assert_exists "$NEST/in/check-release-notes.md"
assert_exists "$NEST/in/review-source.tending/request.md"

# Exercise the complete empty-repository path independently as well as in CI.
bash "$ROOT/test/bootstrap.sh"

# Exercise adjacent request/reply passing independently as well as in CI.
bash "$ROOT/test/passing.sh"

# stale is validated, stable, and read-only for files and directories.
new_nest stale
claim_file old-file
claim_dir old-dir
claim_dir recent
touch -t 200001010000 "$NEST/in/old-file.tending" "$NEST/in/old-dir.tending"
before="$(find "$NEST/in" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort)"
assert_eq "$("$NESTLING" stale 10)" $'old-dir\nold-file'
after="$(find "$NEST/in" -mindepth 1 -maxdepth 1 -exec basename {} \; | sort)"
assert_eq "$after" "$before"
if "$NESTLING" stale nope > /dev/null 2>&1; then fail "stale accepted invalid age"; fi

# Marked directories retry, retain metadata, and stop at the configured cap.
new_nest retry
claim_dir job
touch "$NEST/in/job.tending/.recoverable"
assert_eq "$(NEST_MAX_ATTEMPTS=2 "$NESTLING" resolve job 'model failed')" "re-queued job (attempt 1/2)"
assert_eq "$(<"$NEST/in/job/.attempts")" 1
assert_contains "$NEST/in/job/.recovery.md" "model failed"
assert_contains "$NEST/in/job/.recovery.md" "attempt: 1/2"
"$NESTLING" claim job >/dev/null
NEST_MAX_ATTEMPTS=2 "$NESTLING" resolve job again >/dev/null
"$NESTLING" claim job >/dev/null
assert_eq "$(NEST_MAX_ATTEMPTS=2 "$NESTLING" resolve job again)" "dropped job"
assert_exists "$NEST/dropped/job"
assert_contains "$NEST/dropped/job.reason.md" "recovery attempts exhausted (2/2)"

# Unmarked directories and files drop; malformed state and limits do not move.
claim_dir unmarked
"$NESTLING" resolve unmarked failed >/dev/null
assert_exists "$NEST/dropped/unmarked"
claim_file bare
"$NESTLING" resolve bare failed >/dev/null
assert_exists "$NEST/dropped/bare"
claim_dir malformed
touch "$NEST/in/malformed.tending/.recoverable"
printf 'x\n' > "$NEST/in/malformed.tending/.attempts"
if "$NESTLING" resolve malformed failed > /dev/null 2>&1; then fail "resolve accepted malformed attempts"; fi
assert_exists "$NEST/in/malformed.tending"
claim_dir bad-limit
touch "$NEST/in/bad-limit.tending/.recoverable"
if NEST_MAX_ATTEMPTS=x "$NESTLING" resolve bad-limit failed > /dev/null 2>&1; then fail "resolve accepted invalid limit"; fi
assert_exists "$NEST/in/bad-limit.tending"

# A ready-name collision leaves the claim and its metadata unchanged.
claim_dir collision
touch "$NEST/in/collision.tending/.recoverable"
mkdir "$NEST/in/collision"
if "$NESTLING" resolve collision failed > /dev/null 2>&1; then fail "resolve ignored ready collision"; fi
assert_exists "$NEST/in/collision.tending"
assert_absent "$NEST/in/collision.tending/.attempts"

# A producer winning the ready-name race cannot absorb or replace the claim.
claim_dir raced
touch "$NEST/in/raced.tending/.recoverable"
printf '1\n' > "$NEST/in/raced.tending/.attempts"
printf 'prior recovery\n' > "$NEST/in/raced.tending/.recovery.md"
install_racing_mv "$NEST/in/raced"
if NEST_MAX_ATTEMPTS=3 "$NESTLING" resolve raced failed > /dev/null 2>&1; then fail "resolve ignored concurrent ready collision"; fi
assert_exists "$NEST/in/raced"
assert_exists "$NEST/in/raced.tending"
assert_absent "$NEST/in/raced/raced.tending"
assert_eq "$(<"$NEST/in/raced.tending/.attempts")" 1
assert_eq "$(<"$NEST/in/raced.tending/.recovery.md")" "prior recovery"
PATH="${PATH#*:}"
unset RACE_ROOT RACE_MATCH

# Embedded whitespace is malformed rather than being joined into a new count.
claim_dir spaced-attempts
touch "$NEST/in/spaced-attempts.tending/.recoverable"
printf '1 2\n' > "$NEST/in/spaced-attempts.tending/.attempts"
if "$NESTLING" resolve spaced-attempts failed > /dev/null 2>&1; then fail "resolve accepted spaced attempts"; fi
assert_exists "$NEST/in/spaced-attempts.tending"

# Ordinary and recovery drops keep every same-named history and reason.
new_nest drop-race
claim_file concurrent-drop
install_racing_mv "$NEST/dropped/concurrent-drop"
"$NESTLING" drop concurrent-drop raced >/dev/null
assert_exists "$NEST/dropped/concurrent-drop"
assert_eq "$(find "$NEST/dropped" -mindepth 1 -maxdepth 1 -name 'concurrent-drop.*' ! -name '*.reason.md' | wc -l | tr -d ' ')" 1
PATH="${PATH#*:}"
unset RACE_ROOT RACE_MATCH

new_nest collisions
for reason in first second third; do
  claim_file duplicate
  "$NESTLING" drop duplicate "$reason" >/dev/null
done
assert_eq "$(find "$NEST/dropped" -mindepth 1 -maxdepth 1 ! -name '*.reason.md' ! -name .gitkeep | wc -l | tr -d ' ')" 3
assert_eq "$(find "$NEST/dropped" -mindepth 1 -maxdepth 1 -name '*.reason.md' | wc -l | tr -d ' ')" 3
assert_exists "$NEST/dropped/duplicate"
ls "$NEST/dropped"/duplicate.*.* >/dev/null

for reason in fourth fifth; do
  claim_file duplicate
  "$NESTLING" resolve duplicate "$reason" >/dev/null
done
assert_eq "$(find "$NEST/dropped" -mindepth 1 -maxdepth 1 ! -name '*.reason.md' ! -name .gitkeep | wc -l | tr -d ' ')" 5
assert_eq "$(find "$NEST/dropped" -mindepth 1 -maxdepth 1 -name '*.reason.md' | wc -l | tr -d ' ')" 5

echo "ok - nestlings lifecycle and recovery"
