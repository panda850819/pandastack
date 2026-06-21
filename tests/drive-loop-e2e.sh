#!/usr/bin/env bash
# tests/drive-loop-e2e.sh — end-to-end loop demonstration at the goal's N=20.
#
# Drives the REAL pipeline (build → host-verify → blast-classify → integration merge →
# structured ledger) 20 times with --merge-auto ON, then GREPS the real ledger for the
# goal's own fake-green predicate and computes the merge streak. This proves the
# MECHANISM at the success-signal's scale; the build CONTENT is stubbed (no codex), but
# every host-verify, blast-classification, git merge, and ledger record is the real one.
#
# What this does NOT prove (by definition, not by omission): the production trust streak
# — "20 auto-merges with no subsequent HUMAN revert over a rolling 7 days". That needs
# real work + a human declining to revert, behind your --merge-auto ratchet. A stub run
# has no reviewer and no revert decision, so that streak is earned operationally, not here.
set -uo pipefail
export PSDRIVE_TEST=1
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
D="$repo_root/scripts/pandastack-drive"
export PSDRIVE_WORKER_JOB_ROOT="$(mktemp -d)"
N="${PSDRIVE_E2E_N:-20}"
fail=0

pol="$(mktemp)"
printf '%s\n' '**/migrations/**' '**/secrets/**' '**/*.env' 'scripts/pandastack-drive' > "$pol"

repo="$(mktemp -d)"
git -C "$repo" init -q
git -C "$repo" config user.email t@t.t; git -C "$repo" config user.name t
echo seed > "$repo/seed.txt"; git -C "$repo" add -A; git -C "$repo" commit -qm seed >/dev/null
mref="$(git -C "$repo" symbolic-ref --short HEAD)"
mbefore="$(git -C "$repo" rev-parse HEAD)"
ledger="$(mktemp)"
drivelog="$(mktemp)"

# ---- drive N real low-blast build→verify→merge cycles, collect the real ledger ----
PSDRIVE_TEST=1 PSDRIVE_BLAST_POLICY="$pol" python3 - "$D" "$repo" "$N" "$ledger" "$drivelog" <<'PY'
import sys, os, json, importlib.util
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("psdrive", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("psdrive", loader)); loader.exec_module(m)
repo, N, ledger_path, drivelog_path = sys.argv[2], int(sys.argv[3]), sys.argv[4], sys.argv[5]
os.environ["PSDRIVE_BUILD_STUB"] = "PASS"
records = []
for i in range(1, N + 1):
    fn = f"feat-{i}.txt"
    os.environ["PSDRIVE_BUILD_STUB_FILE"] = fn        # distinct low-blast file per issue → clean merges
    desc = f"Goal: ship feature {i}\nContext: e2e\n```acceptance\ntest -f {fn}\n```\n"
    x = {"id": f"LO-{i}", "project": "t", "repo": repo, "title": f"feature {i}",
         "next": "BUILD", "to_state": "Verifying", "build": True, "desc": desc}
    r = m.exec_build(x, merge_auto=True)
    records.append(m.ledger_record(x, r))
with open(ledger_path, "w") as f:
    for rec in records:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")
# also emit drive-log rows so drive-pulse (the dashboard reader) can read the streak
with open(drivelog_path, "w") as f:
    for i, rec in enumerate(records, 1):
        f.write(json.dumps({"ts": f"2026-06-{(i % 28) + 1:02d}T00:00:00Z", "executed": [rec]},
                           ensure_ascii=False) + "\n")
print(f"drove {len(records)} build→verify→merge cycles")
PY
[ $? -eq 0 ] || { echo "FAIL: e2e driver loop errored"; exit 1; }

# ---- assert the real ledger against the goal's own predicates ----
PSDRIVE_TEST=1 python3 - "$ledger" "$N" <<'PY'
import sys, json
recs = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
N = int(sys.argv[2])
assert len(recs) == N, (len(recs), N)

merged = [r for r in recs if r.get("merged") == "psdrive/integration"]
assert len(merged) == N, f"expected {N} merges into integration, got {len(merged)}"
assert all(r["blast"] == "low" for r in merged), "every auto-merge must be low-blast"
assert all(r["verify_ran"] and r["verify_ok"] for r in merged), "every auto-merge must be host-verified green"

# the goal's fake-green predicate, merge-scoped, computed off the REAL ledger:
fake_green = [r for r in recs
              if r.get("verdict") == "PASS" and r.get("merged")
              and r.get("verify_required") and not r.get("verify_ran")]
assert len(fake_green) == 0, f"FAKE-GREEN LEAK: {fake_green}"

# merge streak: consecutive auto-merges (no host-revert signal present in a stub run)
streak = 0
for r in recs:
    if r.get("merged"):
        streak += 1
    else:
        streak = 0
assert streak == N, f"merge streak {streak} != {N}"
print(f"PASS: {N}/{N} low-blast host-verified auto-merges into integration")
print(f"PASS: fake-green count == 0  (grep: verdict==PASS AND merged AND verify_required AND NOT verify_ran)")
print(f"PASS: merge streak == {N}")
PY
[ $? -eq 0 ] || fail=1

# ---- integration carries every change; main was never touched ----
icnt="$(git -C "$repo" rev-list --count --merges psdrive/integration 2>/dev/null || echo 0)"
[ "$icnt" = "$N" ] && echo "PASS: integration has $N merge commits" || { echo "FAIL: integration merge commits = $icnt (want $N)"; fail=1; }
miss=0; for i in $(seq 1 "$N"); do git -C "$repo" cat-file -e "psdrive/integration:feat-$i.txt" 2>/dev/null || miss=1; done
[ "$miss" = 0 ] && echo "PASS: integration tree holds all $N feature files" || { echo "FAIL: integration missing a feature file"; fail=1; }
[ "$(git -C "$repo" rev-parse "$mref")" = "$mbefore" ] && echo "PASS: main HEAD unchanged across $N merges" || { echo "FAIL: main moved"; fail=1; }
[ -z "$(git -C "$repo" remote)" ] && echo "PASS: no remote ever added (driver never pushed)" || { echo "FAIL: a remote appeared"; fail=1; }

# ---- kill-switch: one flag halts the next dispatch before any work ----
ks="$(mktemp -u).STOP"; : > "$ks"
fx="$(mktemp)"
printf '{"issues":[{"identifier":"LO-99","title":"one more","project":"t","state":"Building","priority":1,"description":"Goal: x\\nContext: y\\n```acceptance\\ntest -f z\\n```","created_at":"2026-06-10T00:00:00Z"}]}' > "$fx"
out="$(PSDRIVE_TEST=1 PSDRIVE_STOP_FLAG="$ks" PSDRIVE_FIXTURE="$fx" "$D" --execute --build-auto --merge-auto --only t --max 1 2>&1)"
echo "$out" | grep -q "kill-switch" && echo "PASS: kill-switch flag → zero dispatch (loop self-stops)" || { echo "FAIL: kill-switch not honored"; fail=1; }
echo "$out" | grep -q "@@PSDRIVE_LEDGER@@" && { echo "FAIL: dispatched despite kill-switch"; fail=1; } || echo "PASS: no dispatch line emitted under kill-switch"
[ "$(git -C "$repo" rev-list --count --merges psdrive/integration)" = "$N" ] && echo "PASS: integration unchanged while stopped" || { echo "FAIL: a merge slipped through the kill-switch"; fail=1; }

# ---- drive-pulse (the dashboard reader) reports the goal signal off the real data ----
pulse="$("$repo_root/scripts/drive-pulse" "$drivelog" --repo "$repo" --now 2026-07-01 --days 60 --json 2>&1)"
echo "$pulse" | python3 -c "
import json,sys
r=json.load(sys.stdin)['goal_signals']
assert r['fake_green']==0, r
assert r['trust_streak']==$N and r['streak_target']==20, r
assert r['revert_checked'] and r['reverts_seen']==0, r
print(f\"PASS: drive-pulse reads streak {r['trust_streak']}/{r['streak_target']}, fake-green {r['fake_green']}, {r['reverts_seen']} reverts\")
" || { echo "FAIL: drive-pulse goal-signal readout"; fail=1; }

echo "--- real ledger (first 2 records) ---"; head -2 "$ledger"
[ "$fail" -eq 0 ] && echo "OK: drive-loop-e2e all green ($N merges, 0 fake-green, streak $N, kill-switch honored)" || echo "FAILURES present"
exit "$fail"
