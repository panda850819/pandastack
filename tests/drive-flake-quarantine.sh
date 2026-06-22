#!/usr/bin/env bash
# tests/drive-flake-quarantine.sh — PRO-57: a single green host-verify is not enough to
# auto-merge. Before merging, the acceptance is re-run in the build worktree; an
# intermittently-green ("lucky tick") acceptance is quarantined (kept for a human PR), and
# only a reproducibly-green low-blast build merges into integration. PSDRIVE_TEST=1.
set -uo pipefail
export PSDRIVE_TEST=1
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
D="$repo_root/scripts/pandastack-drive"
export PSDRIVE_WORKER_JOB_ROOT="$(mktemp -d)"
fail=0
ok() { echo "PASS: $1"; }
bad() { echo "FAIL: $1"; fail=1; }

pol="$(mktemp)"; printf '%s\n' '**/migrations/**' 'scripts/pandastack-drive' > "$pol"
jget() { echo "$1" | python3 -c "import json,sys;print(json.load(sys.stdin).get('$2'))"; }

fresh_repo() {
  local r; r="$(mktemp -d)"
  git -C "$r" init -q
  git -C "$r" config user.email t@t.t; git -C "$r" config user.name t
  echo seed > "$r/seed.txt"; git -C "$r" add -A; git -C "$r" commit -qm seed >/dev/null
  echo "$r"
}

run_build() {  # <repo> <id> <acceptance>
  PSDRIVE_TEST=1 PSDRIVE_BUILD_STUB=PASS PSDRIVE_BUILD_STUB_FILE=".psdrive-stub" PSDRIVE_BLAST_POLICY="$pol" \
    python3 - "$D" "$1" "$2" "$3" <<'PY'
import sys, json, importlib.util
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("psdrive", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("psdrive", loader)); loader.exec_module(m)
repo, iid, acc = sys.argv[2], sys.argv[3], sys.argv[4]
desc = "Goal: x\nContext: y\n```acceptance\n" + acc + "\n```\n"
x = {"id": iid, "project": "t", "repo": repo, "title": "t", "next": "BUILD",
     "to_state": "Verifying", "build": True, "desc": desc, "source_rev": "sha256:aaa"}
r = m.exec_build(x, merge_auto=True)
print(json.dumps({"merged": r.get("merged"), "merge_skip": r.get("merge_skip"),
                  "verdict": r.get("verdict")}, ensure_ascii=False))
PY
}
bexists() { git -C "$1" rev-parse --verify -q "psdrive/$2" >/dev/null 2>&1; }

# flaky: fails pre-build (no stub → F-A sentinel passes), green on the FIRST post-build run
# (machine_green), then fails — a lucky-green tick that must NOT auto-merge.
FLAKY='test -f .psdrive-stub && { n=$(cat .fc 2>/dev/null || echo 0); echo $((n+1)) > .fc; [ "$n" -eq 0 ]; }'
# stable: reproducibly green post-build.
STABLE='test -f .psdrive-stub'

# ---------- 1. flaky (lucky-green) acceptance is quarantined, not merged ----------
r1="$(fresh_repo)"
o="$(run_build "$r1" FLK-1 "$FLAKY")"
[ "$(jget "$o" merged)" = "None" ] && ok "flaky acceptance not merged" || bad "lucky-green merged: $o"
echo "$(jget "$o" merge_skip)" | grep -qi "flak" && ok "merge_skip cites flaky/quarantine" || bad "flake reason missing: $o"
bexists "$r1" FLK-1 && ok "flaky build kept for a human PR" || bad "flaky build lost the branch"
git -C "$r1" rev-parse --verify -q psdrive/integration >/dev/null 2>&1 && bad "flaky created integration" || ok "flaky → no integration merge"

# ---------- 2. reproducibly-green acceptance still merges (no false quarantine) ----------
r2="$(fresh_repo)"
o="$(run_build "$r2" STB-1 "$STABLE")"
[ "$(jget "$o" merged)" = "psdrive/integration" ] && ok "stable green still merges" || bad "stable green wrongly quarantined: $o"

[ "$fail" -eq 0 ] && echo "OK: drive-flake-quarantine all green" || echo "FAILURES present"
exit "$fail"
