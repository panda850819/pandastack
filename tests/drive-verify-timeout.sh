#!/usr/bin/env bash
# tests/drive-verify-timeout.sh — PRO-60: the F-A pre-build sentinel and the PRO-57 stability
# re-runs share ONE configurable verify budget (PSDRIVE_VERIFY_TIMEOUT) with the build's
# host-verify, instead of a hardcoded-smaller cap. A slow-but-valid acceptance that fits the
# build budget is no longer falsely demoted; a tiny budget demotes it (proving the cap is the
# shared, configurable budget — not a hardcoded 600). PSDRIVE_TEST=1.
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
  git -C "$r" init -q; git -C "$r" config user.email t@t.t; git -C "$r" config user.name t
  echo seed > "$r/seed.txt"; git -C "$r" add -A; git -C "$r" commit -qm seed >/dev/null
  echo "$r"
}

run_build() {  # <repo> <id> <acceptance>   (merge_auto on; env carries the budget)
  PSDRIVE_TEST=1 PSDRIVE_BUILD_STUB=PASS PSDRIVE_BUILD_STUB_FILE=".psdrive-stub" PSDRIVE_BLAST_POLICY="$pol" \
  PSDRIVE_MERGE_RERUNS="${PSDRIVE_MERGE_RERUNS:-0}" PSDRIVE_VERIFY_TIMEOUT="${PSDRIVE_VERIFY_TIMEOUT:-}" \
    python3 - "$D" "$1" "$2" "$3" <<'PY'
import sys, json, importlib.util
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("psdrive", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("psdrive", loader)); loader.exec_module(m)
repo, iid, acc = sys.argv[2], sys.argv[3], sys.argv[4]
desc = "Goal: x\nContext: y\n```acceptance\n" + acc + "\n```\n"
x = {"id": iid, "project": "t", "repo": repo, "title": "t", "next": "BUILD",
     "to_state": "Verifying", "build": True, "desc": desc, "source_rev": "sha256:aaa"}
print(json.dumps({"merged": m.exec_build(x, merge_auto=True).get("merged")}, ensure_ascii=False))
PY
}

# a discriminating acceptance (absent file fails pre-build) that takes ~2s to evaluate.
SLOW='sleep 2; test -f .psdrive-stub'

# ---------- 1. the full verify budget lets a slow-but-valid acceptance auto-merge ----------
r1="$(fresh_repo)"
o="$(PSDRIVE_VERIFY_TIMEOUT=60 run_build "$r1" SLOW-OK "$SLOW")"
[ "$(jget "$o" merged)" = "psdrive/integration" ] && ok "slow-but-valid acceptance merges within the budget" || bad "slow acceptance not merged at 60s budget: $o"

# ---------- 2. a tiny budget demotes the SAME acceptance (cap is the shared, configurable budget) ----------
r2="$(fresh_repo)"
o="$(PSDRIVE_VERIFY_TIMEOUT=1 run_build "$r2" SLOW-TO "$SLOW")"
[ "$(jget "$o" merged)" = "None" ] && ok "tiny budget times out the pre-build/verify → not merged" || bad "tiny budget did not apply to the verify path: $o"

[ "$fail" -eq 0 ] && echo "OK: drive-verify-timeout all green" || echo "FAILURES present"
exit "$fail"
