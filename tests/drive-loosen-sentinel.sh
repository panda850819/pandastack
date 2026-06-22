#!/usr/bin/env bash
# tests/drive-loosen-sentinel.sh — PRO-59: the F-A mutation sentinel no longer BLOCKS the
# build when the acceptance already passes pre-build (tautological / absolute-path / a
# behaviour-preserving refactor). Such work now BUILDS and opens a human PR — but is marked
# non-discriminating, so the merge gate refuses to AUTO-MERGE it (a post-build PASS proves
# nothing). A discriminating acceptance (fails pre-build) still auto-merges. PSDRIVE_TEST=1.
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

run_build() {  # <repo> <id> <merge_auto 1|0> <acceptance>
  PSDRIVE_TEST=1 PSDRIVE_BUILD_STUB=PASS PSDRIVE_BUILD_STUB_FILE=".psdrive-stub" PSDRIVE_BLAST_POLICY="$pol" \
    python3 - "$D" "$1" "$2" "$3" "$4" <<'PY'
import sys, json, importlib.util
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("psdrive", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("psdrive", loader)); loader.exec_module(m)
repo, iid, ma, acc = sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
desc = "Goal: x\nContext: y\n```acceptance\n" + acc + "\n```\n"
x = {"id": iid, "project": "t", "repo": repo, "title": "t", "next": "BUILD",
     "to_state": "Verifying", "build": True, "desc": desc, "source_rev": "sha256:aaa"}
r = m.exec_build(x, merge_auto=(ma == "1"))
print(json.dumps({"verdict": r.get("verdict"), "merged": r.get("merged"),
                  "merge_skip": r.get("merge_skip")}, ensure_ascii=False))
PY
}
bexists() { git -C "$1" rev-parse --verify -q "psdrive/$2" >/dev/null 2>&1; }

# ---------- 1. non-discriminating acceptance: builds + PR, never auto-merges ----------
# `true` passes on the pre-build tree → non-discriminating. Old behaviour BLOCKED the build.
r1="$(fresh_repo)"
o="$(run_build "$r1" ND-1 1 'true')"
[ "$(jget "$o" verdict)" = "PASS" ] && ok "non-discriminating acceptance builds (no longer BLOCKED)" || bad "still blocked / not built: $o"
[ "$(jget "$o" merged)" = "None" ] && ok "non-discriminating acceptance is NOT auto-merged" || bad "tautological acceptance auto-merged (fake-green!): $o"
echo "$(jget "$o" merge_skip)" | grep -qiE 'discriminat|pre-build' && ok "merge_skip cites non-discriminating" || bad "missing non-discriminating reason: $o"
bexists "$r1" ND-1 && ok "non-discriminating build kept for a human PR" || bad "lost the branch"

# ---------- 2. a discriminating acceptance (fails pre-build) still auto-merges ----------
r2="$(fresh_repo)"
o="$(run_build "$r2" DSC-1 1 'test -f .psdrive-stub')"
[ "$(jget "$o" merged)" = "psdrive/integration" ] && ok "discriminating acceptance still auto-merges" || bad "loosening broke a legit auto-merge: $o"

[ "$fail" -eq 0 ] && echo "OK: drive-loosen-sentinel all green" || echo "FAILURES present"
exit "$fail"
