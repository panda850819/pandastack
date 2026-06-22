#!/usr/bin/env bash
# tests/drive-graduate.sh — PRO-63 graduation interlock. The gate FAILS CLOSED: it passes
# only with a checked repo, a full clean streak (>=20), zero fake-green, zero reverts/
# rollbacks, and no open disconfirm against the streak's merges. Throwaway git repos +
# fixtures; no network.
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
G="$repo_root/scripts/drive-graduate"
fail=0
ok() { echo "PASS: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

# isolate the graduation + disconfirm logs from the real brain
GRAD="$(mktemp)"; rm -f "$GRAD"
DISC="$(mktemp)"; : > "$DISC"
export PSDRIVE_GRADUATION_LOG="$GRAD" PSDRIVE_DISCONFIRM_LOG="$DISC"

# build a repo with N clean merge commits on psdrive/integration; print its path
build_repo() {  # <n>
  local r; r="$(mktemp -d)"
  git -C "$r" init -q; git -C "$r" config user.email t@t.t; git -C "$r" config user.name t
  echo seed > "$r/seed.txt"; git -C "$r" add -A; git -C "$r" commit -qm seed >/dev/null
  git -C "$r" checkout -q -b psdrive/integration
  local i
  for i in $(seq 1 "$1"); do
    echo "m$i" > "$r/m$i.txt"; git -C "$r" add -A; git -C "$r" commit -qm "merge $i" >/dev/null
  done
  echo "$r"
}

# build a drive-log: one clean auto-merge per streak commit (oldest->newest). Options via env:
#   FAKE_LAST=1   → the last record drops verify_ran (a fake-green merge)
#   ROLL_SHA=<x>  → the last record's merged_sha is replaced with <x> (an unreachable sha)
build_log() {  # <repo> <n>  -> prints jsonl
  python3 - "$1" "$2" <<'PY'
import subprocess, sys, json, os, datetime
repo, n = sys.argv[1], int(sys.argv[2])
shas = subprocess.run(["git","-C",repo,"rev-list","--reverse","psdrive/integration"],
                      capture_output=True, text=True).stdout.split()[1:]  # drop seed
shas = shas[:n]
ts = (datetime.date.today() - datetime.timedelta(days=1)).isoformat() + "T00:00:00Z"
fake_last = os.environ.get("FAKE_LAST") == "1"
roll = os.environ.get("ROLL_SHA")
for i, sha in enumerate(shas):
    last = i == len(shas) - 1
    e = {"id": f"PRO-{i+1}", "verdict": "PASS", "merged": "psdrive/integration",
         "merged_sha": (roll if (roll and last) else sha),
         "verify_required": True, "verify_ran": (False if (fake_last and last) else True),
         "verify_ok": True, "advance": None, "blast": "low"}
    print(json.dumps({"ts": ts, "auto": 1, "gate": 0, "blocked": 0, "gate_ids": [], "executed": [e]}))
PY
}

# ---------- 1. clean 20/20 with a checked repo -> GRADUATED ----------
R="$(build_repo 20)"; L="$(mktemp)"; build_log "$R" 20 > "$L"
out="$("$G" --check --log "$L" --repo "$R" 2>&1)"; rc=$?
[ $rc -eq 0 ] && echo "$out" | grep -q GRADUATED && ok "clean 20/20 + repo -> graduated" || bad "clean run did not graduate (rc=$rc): $out"
[ -s "$GRAD" ] && ok "graduation record written" || bad "no graduation record written"

# idempotent: a second --check does not double-write, still exit 0
n1=$(wc -l < "$GRAD"); "$G" --check --log "$L" --repo "$R" >/dev/null 2>&1
[ "$(wc -l < "$GRAD")" = "$n1" ] && ok "second --check is idempotent (no double record)" || bad "double-wrote graduation record"

# ---------- 2. no --repo -> revert/rollback UNCHECKED -> fails closed ----------
rm -f "$GRAD"
out="$("$G" --check --log "$L" 2>&1)"; rc=$?
[ $rc -eq 1 ] && echo "$out" | grep -q "NOT YET" && ok "no repo -> not graduated (fails closed)" || bad "graduated without a repo check: $out"
echo "$out" | grep -q "FAIL.*checked against a repo" && ok "cites the unverified-data criterion" || bad "missing revert-checked criterion: $out"

# ---------- 3. streak < 20 -> not graduated ----------
R19="$(build_repo 19)"; L19="$(mktemp)"; build_log "$R19" 19 > "$L19"
"$G" --check --log "$L19" --repo "$R19" >/dev/null 2>&1
[ $? -eq 1 ] && ok "streak 19/20 -> not graduated" || bad "graduated on a short streak"

# ---------- 4. one fake-green merge -> not graduated ----------
Rf="$(build_repo 20)"; Lf="$(mktemp)"; FAKE_LAST=1 build_log "$Rf" 20 > "$Lf"
out="$("$G" --check --log "$Lf" --repo "$Rf" 2>&1)"
[ $? -ne 0 ] && echo "$out" | grep -q "fake-green in streak: 1" && ok "a fake-green merge blocks graduation" || bad "graduated with a fake-green: $out"

# ---------- 4b. a fake-green merge OUTSIDE the --days window still blocks (streak-scoped) ----------
# regression for the window/history mismatch: window fake_green reads 0, but the streak does not.
Rw="$(build_repo 20)"; Lw="$(mktemp)"
python3 - "$Rw" > "$Lw" <<'PY'
import subprocess, sys, json, datetime
repo = sys.argv[1]
shas = subprocess.run(["git","-C",repo,"rev-list","--reverse","psdrive/integration"],
                      capture_output=True, text=True).stdout.split()[1:][:20]
recent = (datetime.date.today() - datetime.timedelta(days=1)).isoformat() + "T00:00:00Z"
old    = (datetime.date.today() - datetime.timedelta(days=30)).isoformat() + "T00:00:00Z"
for i, sha in enumerate(shas):
    fake = (i == 0)                       # oldest merge is fake-green and 30 days old (outside 7d window)
    e = {"id": f"PRO-{i+1}", "verdict": "PASS", "merged": "psdrive/integration", "merged_sha": sha,
         "verify_required": True, "verify_ran": (not fake), "verify_ok": True, "advance": None, "blast": "low"}
    print(json.dumps({"ts": (old if fake else recent), "auto":1,"gate":0,"blocked":0,"gate_ids":[],"executed":[e]}))
PY
out="$("$G" --check --log "$Lw" --repo "$Rw" --days 7 2>&1)"
[ $? -ne 0 ] && echo "$out" | grep -q "fake-green in streak: 1" && ok "old fake-green outside window still blocks (no phantom 20/20)" || bad "graduated with an out-of-window fake-green: $out"

# ---------- 5. open disconfirm against a streak merge -> not graduated ----------
Rd="$(build_repo 20)"; Ld="$(mktemp)"; build_log "$Rd" 20 > "$Ld"
disc_sha="$(git -C "$Rd" rev-list --reverse psdrive/integration | sed -n '5p')"   # the 4th merge
echo "{\"ts\":\"2026-06-20T00:00:00Z\",\"sha\":\"$disc_sha\",\"class\":\"subtly-wrong\",\"why\":\"t\"}" > "$DISC"
out="$("$G" --check --log "$Ld" --repo "$Rd" 2>&1)"
[ $? -ne 0 ] && echo "$out" | grep -q "open disconfirms vs streak: 1" && ok "open disconfirm on a streak merge blocks graduation" || bad "graduated despite an open disconfirm: $out"
: > "$DISC"

# ---------- 6. a rolled-back (unreachable) merge sha -> not graduated ----------
Rr="$(build_repo 20)"; Lr="$(mktemp)"
side="$(git -C "$Rr" commit-tree HEAD^{tree} -m orphan 2>/dev/null)"   # a real commit NOT on integration
ROLL_SHA="$side" build_log "$Rr" 20 > "$Lr"
out="$("$G" --check --log "$Lr" --repo "$Rr" 2>&1)"
[ $? -ne 0 ] && echo "$out" | grep -q "rolled_back 1 == 0" && ok "a rolled-back merge sha blocks graduation" || bad "graduated with a rolled-back sha: $out"

[ "$fail" -eq 0 ] && echo "OK: drive-graduate all green" || echo "FAILURES present"
exit "$fail"
