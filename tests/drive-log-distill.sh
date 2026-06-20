#!/usr/bin/env bash
# tests/drive-log-distill.sh — drive-log-distill surfaces stuck-PASS (verified green
# K+ ticks, never advanced) and persistent-gate (in gate_ids M+ ticks) from the driver
# ledger; clean ids stay quiet. Pure logic over a fixture log. (PRO-40 / Gap 3)
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
S="$repo_root/scripts/drive-log-distill"
fail=0
tmp="$(mktemp -d)"
log="$tmp/drive-log.jsonl"

# STUCK-1 passes 5 ticks (flag). ONCE passes 1 tick (quiet).
# GATED-1 sits in gate_ids 4 ticks (flag). GATED-ONCE 1 tick (quiet).
{
  echo '{"ts":"t1","executed":[{"id":"STUCK-1","verdict":"PASS"},{"id":"ONCE","verdict":"PASS"}],"gate_ids":["GATED-1","GATED-ONCE"]}'
  echo '{"ts":"t2","executed":[{"id":"STUCK-1","verdict":"PASS"}],"gate_ids":["GATED-1"]}'
  echo '{"ts":"t3","executed":[{"id":"STUCK-1","verdict":"PASS"}],"gate_ids":["GATED-1"]}'
  echo '{"ts":"t4","executed":[{"id":"STUCK-1","verdict":"PASS"}],"gate_ids":["GATED-1"]}'
  echo '{"ts":"t5","executed":[{"id":"STUCK-1","verdict":"PASS"}],"gate_ids":[]}'
} > "$log"

pass(){ echo "PASS: $1"; }
fl(){ echo "FAIL: $1"; fail=1; }

out="$("$S" "$log" --json 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || fl "distill errored (rc=$rc)"

echo "$out" | python3 -c "import json,sys;r=json.load(sys.stdin);sys.exit(0 if any(x['id']=='STUCK-1' and x['pass_ticks']==5 for x in r['stuck_pass']) else 1)" \
  && pass "stuck-PASS: STUCK-1 (5 ticks) flagged" || fl "STUCK-1 not flagged"
echo "$out" | python3 -c "import json,sys;r=json.load(sys.stdin);sys.exit(0 if not any(x['id']=='ONCE' for x in r['stuck_pass']) else 1)" \
  && pass "stuck-PASS: ONCE (1 tick) not flagged" || fl "ONCE wrongly flagged"
echo "$out" | python3 -c "import json,sys;r=json.load(sys.stdin);sys.exit(0 if any(x['id']=='GATED-1' and x['gate_ticks']==4 for x in r['persistent_gate']) else 1)" \
  && pass "persistent-gate: GATED-1 (4 ticks) flagged" || fl "GATED-1 not flagged"
echo "$out" | python3 -c "import json,sys;r=json.load(sys.stdin);sys.exit(0 if not any(x['id']=='GATED-ONCE' for x in r['persistent_gate']) else 1)" \
  && pass "persistent-gate: GATED-ONCE (1 tick) not flagged" || fl "GATED-ONCE wrongly flagged"

# clean log -> nothing flagged, exit 0
echo '{"ts":"t1","executed":[{"id":"A","verdict":"PASS"}],"gate_ids":["B"]}' > "$tmp/clean.jsonl"
cout="$("$S" "$tmp/clean.jsonl" 2>&1)"; crc=$?
{ [ "$crc" -eq 0 ] && grep -q "clean" <<<"$cout"; } && pass "clean log -> nothing flagged, exit 0" || fl "clean log misreported"

[ "$fail" -eq 0 ] && echo "OK: drive-log-distill all green" || echo "FAILURES present"
exit "$fail"
