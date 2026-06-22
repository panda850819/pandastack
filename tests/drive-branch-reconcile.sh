#!/usr/bin/env bash
# tests/drive-branch-reconcile.sh — PRO-56: reconcile the kept psdrive/<ISSUE> branch so an
# issue can be re-driven after its work-order rotates, WITHOUT breaking the branch's role as
# the re-build lock (the Linear advance is human-run, so an auto-merged issue stays in BUILD;
# retiring its branch would rebuild + re-merge the same work every tick → streak inflation).
# Pure logic + throwaway git repos; no network, no Linear, no codex. PSDRIVE_TEST=1.
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

# stubbed PASS build with an explicit source_rev; prints {merged,ran,verdict,why}
run_build() {  # <repo> <id> <merge_auto 1|0> <source_rev>
  PSDRIVE_TEST=1 PSDRIVE_BUILD_STUB=PASS PSDRIVE_BUILD_STUB_FILE=".psdrive-stub" PSDRIVE_BLAST_POLICY="$pol" \
    python3 - "$D" "$1" "$2" "$3" "$4" <<'PY'
import sys, json, importlib.util
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("psdrive", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("psdrive", loader)); loader.exec_module(m)
repo, iid, ma, srev = sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
desc = "Goal: x\nContext: y\n```acceptance\ntest -f .psdrive-stub\n```\n"
x = {"id": iid, "project": "t", "repo": repo, "title": "t", "next": "BUILD",
     "to_state": "Verifying", "build": True, "desc": desc, "source_rev": srev}
r = m.exec_build(x, merge_auto=(ma == "1"))
print(json.dumps({"merged": r.get("merged"), "ran": r.get("ran"),
                  "verdict": r.get("verdict"), "why": r.get("why")}, ensure_ascii=False))
PY
}

bexists()  { git -C "$1" rev-parse --verify -q "psdrive/$2" >/dev/null 2>&1; }
brev()     { git -C "$1" log -1 --format=%B "psdrive/$2" 2>/dev/null | sed -n 's/^psdrive-source-rev: //p' | tail -1; }
nmerges()  { git -C "$1" rev-list --count --merges psdrive/integration 2>/dev/null; }

# ---------- 1. auto-merge is the re-build LOCK: it merges ONCE, never re-merges ----------
# (the issue stays in BUILD until a human advances it; a second tick must NOT re-merge.)
r1="$(fresh_repo)"
o="$(run_build "$r1" AM-1 1 sha256:aaa)"
[ "$(jget "$o" merged)" = "psdrive/integration" ] && ok "auto-merge merged into integration" || bad "auto-merge didn't merge: $o"
o2="$(run_build "$r1" AM-1 1 sha256:aaa)"               # same fingerprint, still in BUILD
[ "$(jget "$o2" ran)" = "False" ] && ok "second tick skipped (branch is the re-build lock)" || bad "re-built an auto-merged issue: $o2"
[ "$(nmerges "$r1")" = "1" ] && ok "exactly one merge — no streak inflation" || bad "re-merged the same work ($(nmerges "$r1") merges)"

# ---------- 2. work-order rotation retires the stale branch and rebuilds (re-drivable) ----------
r2="$(fresh_repo)"
run_build "$r2" RO-1 0 sha256:aaa >/dev/null      # kept branch at rev aaa
bexists "$r2" RO-1 && ok "rev-aaa build kept the branch" || bad "first build lost the branch"
o="$(run_build "$r2" RO-1 0 sha256:bbb)"           # work-order rotated → must rebuild
[ "$(jget "$o" verdict)" = "PASS" ] && ok "rotated work-order rebuilds (not skipped)" || bad "rotation skipped instead of rebuilding: $o"
[ "$(brev "$r2" RO-1)" = "sha256:bbb" ] && ok "rebuilt branch carries the new fingerprint" || bad "branch fingerprint not updated: $(brev "$r2" RO-1)"

# ---------- 3. same fingerprint, awaiting review → skip preserved (surface, don't retry) ----------
r3="$(fresh_repo)"
run_build "$r3" SK-1 0 sha256:aaa >/dev/null
o="$(run_build "$r3" SK-1 0 sha256:aaa)"
[ "$(jget "$o" ran)" = "False" ] && ok "same fingerprint, awaiting review → skipped" || bad "regressed surface-don't-retry: $o"
echo "$(jget "$o" why)" | grep -q "review/advance" && ok "skip reason preserved" || bad "skip reason changed: $o"
bexists "$r3" SK-1 && ok "awaiting-review branch still kept" || bad "awaiting-review branch wrongly retired"

# ---------- 4. rotation under --merge-auto adds exactly one new merge (no oscillation) ----------
r4="$(fresh_repo)"
run_build "$r4" MX-1 1 sha256:aaa >/dev/null      # merge #1 (rev aaa)
run_build "$r4" MX-1 1 sha256:aaa >/dev/null      # same fingerprint → skip, no merge
run_build "$r4" MX-1 1 sha256:bbb >/dev/null      # rotated → rebuild + merge #2
[ "$(nmerges "$r4")" = "2" ] && ok "one merge per work-order revision (no re-merge churn)" || bad "merge count wrong: $(nmerges "$r4") (want 2)"

[ "$fail" -eq 0 ] && echo "OK: drive-branch-reconcile all green" || echo "FAILURES present"
exit "$fail"
