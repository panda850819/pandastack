#!/usr/bin/env bash
# tests/learning-refresh.sh — learning-refresh surfaces ONLY learnings that decay has
# silently suppressed (eff confidence < 3) and recurrence is not keeping alive; never
# user-stated, never high-recurrence, never already-stale. Propose-only, no mutation.
# (PRO-45 / read-side)
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
S="$repo_root/scripts/learning-refresh"
fail=0
tmp="$(mktemp -d)/learnings"
mkdir -p "$tmp"

# anchor now=2026-06-01; created 2025-06-01 = ~365d = 12 decay steps.
# (1) STALE-1: confidence 8, observed, recurrence 1, old -> eff = 8-12 = 0 (<3) -> candidate
cat > "$tmp/stale-1.md" <<'MD'
---
type: pitfall
key: old-decayed-thing
confidence: 8
source: observed
recurrence: 1
created: 2025-06-01
---
body
MD
# (2) USERSTATED: user-stated never decays -> not candidate even if old
cat > "$tmp/userstated.md" <<'MD'
---
type: pitfall
key: user-told-us
confidence: 8
source: user-stated
recurrence: 1
created: 2025-06-01
---
body
MD
# (3) RECUR: high recurrence keeps it alive -> not candidate even if decayed
cat > "$tmp/recur.md" <<'MD'
---
type: pattern
key: repeat-offender
confidence: 8
source: observed
recurrence: 5
created: 2025-06-01
---
body
MD
# (4) FRESH: recent + high confidence -> eff high -> not candidate
cat > "$tmp/fresh.md" <<'MD'
---
type: pitfall
key: fresh-thing
confidence: 9
source: observed
recurrence: 1
created: 2026-05-20
---
body
MD
# (5) ALREADY: already status:stale -> not re-proposed
cat > "$tmp/already.md" <<'MD'
---
type: pitfall
key: already-stale
confidence: 8
source: observed
recurrence: 1
status: stale
created: 2025-06-01
---
body
MD

pass(){ echo "PASS: $1"; }
fl(){ echo "FAIL: $1"; fail=1; }

out="$("$S" "$tmp" --now 2026-06-01 --json 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || fl "learning-refresh errored (rc=$rc)"
J(){ echo "$out" | python3 -c "import json,sys;r=json.load(sys.stdin);ks=[c['key'] for c in r['candidates']];sys.exit(0 if ($1) else 1)"; }

J "'old-decayed-thing' in ks"   && pass "decayed + low-recurrence -> candidate"        || fl "stale-1 not flagged"
J "'user-told-us' not in ks"    && pass "user-stated never decays -> not candidate"    || fl "user-stated wrongly flagged"
J "'repeat-offender' not in ks" && pass "high recurrence -> not candidate"             || fl "recur wrongly flagged"
J "'fresh-thing' not in ks"     && pass "fresh/high-confidence -> not candidate"       || fl "fresh wrongly flagged"
J "'already-stale' not in ks"   && pass "already status:stale -> not re-proposed"      || fl "already-stale re-flagged"
J "len(ks)==1"                  && pass "exactly one candidate"                        || fl "wrong candidate count"

# propose-only: the corpus is never mutated
before="$(cat "$tmp/stale-1.md")"
"$S" "$tmp" --now 2026-06-01 >/dev/null 2>&1
[ "$before" = "$(cat "$tmp/stale-1.md")" ] && pass "propose-only: source file untouched" || fl "mutated a learning"

[ "$fail" -eq 0 ] && echo "OK: learning-refresh all green" || echo "FAILURES present"
exit "$fail"
