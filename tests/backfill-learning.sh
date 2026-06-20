#!/usr/bin/env bash
# tests/backfill-learning.sh — backfill-learning-first-seen: adds first_seen (from
# created / filename) + recurrence:1 to learning files that lack them, idempotently,
# never overwriting existing values, never touching non-learning files. (PRO-39 / Gap 1)
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
S="$repo_root/scripts/backfill-learning-first-seen"
fail=0
tmp="$(mktemp -d)"

# (1) learning missing both, has created -> first_seen=created, recurrence=1
mkdir -p "$tmp/pitfalls"
cat > "$tmp/pitfalls/2026-01-02-x.md" <<'MD'
---
type: pitfall
key: some-key
confidence: 8
created: 2026-05-04
last_seen: 2026-05-04
---
## Problem
body stays.
MD

# (2) learning already having first_seen + recurrence -> untouched
cat > "$tmp/pitfalls/already.md" <<'MD'
---
type: pitfall
key: done-key
first_seen: 2026-03-03
recurrence: 4
created: 2026-03-03
---
body.
MD

# (3) learning missing created, derive from filename
cat > "$tmp/pitfalls/2026-06-09-fromname.md" <<'MD'
---
type: pattern
key: name-key
confidence: 5
---
body.
MD

# (4) non-learning md -> never touched
cat > "$tmp/notes.md" <<'MD'
---
type: meeting
key: nope
---
body.
MD

pass(){ echo "PASS: $1"; }
fl(){ echo "FAIL: $1"; fail=1; }

python3 "$S" "$tmp" >/dev/null 2>&1 || fl "backfill run errored"

grep -q "^first_seen: 2026-05-04$" "$tmp/pitfalls/2026-01-02-x.md" && grep -q "^recurrence: 1$" "$tmp/pitfalls/2026-01-02-x.md" \
  && pass "missing both + created -> first_seen=created, recurrence=1" || fl "case1 wrong"
grep -q "^## Problem$" "$tmp/pitfalls/2026-01-02-x.md" && pass "body preserved" || fl "body lost"

grep -q "^first_seen: 2026-03-03$" "$tmp/pitfalls/already.md" && grep -q "^recurrence: 4$" "$tmp/pitfalls/already.md" \
  && pass "existing values untouched (no overwrite)" || fl "case2 overwritten"

grep -q "^first_seen: 2026-06-09$" "$tmp/pitfalls/2026-06-09-fromname.md" \
  && pass "missing created -> first_seen from filename" || fl "case3 wrong"

grep -q "first_seen" "$tmp/notes.md" && fl "non-learning file was touched" || pass "non-learning file untouched"

# idempotent: second run changes nothing
before="$(md5 -q "$tmp/pitfalls/2026-01-02-x.md" 2>/dev/null || md5sum "$tmp/pitfalls/2026-01-02-x.md")"
python3 "$S" "$tmp" >/dev/null 2>&1
after="$(md5 -q "$tmp/pitfalls/2026-01-02-x.md" 2>/dev/null || md5sum "$tmp/pitfalls/2026-01-02-x.md")"
[ "$before" = "$after" ] && pass "idempotent (second run is a no-op)" || fl "not idempotent"

[ "$fail" -eq 0 ] && echo "OK: backfill-learning all green" || echo "FAILURES present"
exit "$fail"
