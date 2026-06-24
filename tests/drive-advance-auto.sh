#!/usr/bin/env bash
# tests/drive-advance-auto.sh — --advance-auto write-back gating (PRO-80).
#
# Locks the safety property of the Linear write-back relaxation: the driver auto-writes
# ONLY the reversible AUTO-phase columns (Verifying / In Review), NEVER a gate column
# (Needs Decision / Building / Done / Canceled / Planning), only the equivalent of the
# human command (no --force, so a gated issue still refuses), and never without the flag.
# Hermetic + at the function level (the drive-loop-e2e.sh pattern): a temp repo, a stub
# advance recorder, PSDRIVE_BUILD_STUB (no codex), no network, no real Linear.
set -uo pipefail
export PSDRIVE_TEST=1
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
D="$repo_root/scripts/pandastack-drive"
export PSDRIVE_WORKER_JOB_ROOT="$(mktemp -d)"
fail=0
ok(){ echo "PASS: $1"; }
no(){ echo "FAIL: $1"; fail=1; }

calls="$(mktemp)"
stub="$(mktemp)"; printf '#!/usr/bin/env bash\necho "$@" >> "%s"\nexit 0\n' "$calls" > "$stub"; chmod +x "$stub"

PSDRIVE_TEST=1 PSDRIVE_ADVANCE_CMD="$stub" PSDRIVE_CALLS="$calls" \
python3 - "$D" <<'PY'
import sys, os, json, subprocess, tempfile, importlib.util
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("psdrive", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("psdrive", loader)); loader.exec_module(m)
calls = os.environ["PSDRIVE_CALLS"]
rc = 0
def check(desc, cond):
    global rc
    print(("PASS: " if cond else "FAIL: ") + desc); rc = rc or (0 if cond else 1)

# 1. allowlist: exactly the two reversible AUTO columns; no gate column auto-writable
A = set(m.AUTO_WRITE_STATES)
check("allowlist == {Verifying, In Review}", A == {"Verifying", "In Review"})
check("no gate column auto-writable",
      not (A & {"Building", "Needs Decision", "Done", "Canceled", "Planning", "Backlog"}))

# 2. exec_build tags the AUTO target (advance + advance_to) on a stubbed PASS build
repo = tempfile.mkdtemp()
for c in (["init","-q"], ["config","user.email","t@t.t"], ["config","user.name","t"]):
    subprocess.run(["git","-C",repo,*c], check=True)
open(os.path.join(repo,"seed.txt"),"w").write("seed\n")
subprocess.run(["git","-C",repo,"add","-A"], check=True)
subprocess.run(["git","-C",repo,"commit","-qm","seed"], check=True)
os.environ["PSDRIVE_BUILD_STUB"] = "PASS"
os.environ["PSDRIVE_BUILD_STUB_FILE"] = "x"
x = {"id":"AAX-1","project":"murmur","repo":repo,"title":"feat","next":"BUILD",
     "to_state":"Verifying","build":True,
     "desc":"Goal: ship feature\nContext: because\n```acceptance\ntest -f x\n```\n"}
r = m.exec_build(x, merge_auto=False)
check("build PASS", r.get("verdict") == "PASS")
check("build sets advance command", bool(r.get("advance")))
check("build advance_to == Verifying (AUTO target)", r.get("advance_to") == "Verifying")

# 3. do_advance is exactly the human command: right args, NO --force, returns ok
open(calls,"w").close()
ok_, _ = m.do_advance("AAX-1", "Verifying")
argv = open(calls).read()
check("do_advance returns ok on a 0-exit advance", ok_ is True)
check("do_advance passes --issue AAX-1 --to Verifying", "--issue AAX-1" in argv and "Verifying" in argv)
check("do_advance passes NO --force (gated issues still refuse)", "--force" not in argv)

# 4. the REAL main-loop gate (m.should_auto_write), exercised both ways over real dicts
check("flag OFF never writes", m.should_auto_write(False, r) is False)
check("flag ON + Verifying target writes", m.should_auto_write(True, r) is True)
check("flag ON + Done (gate) target does NOT write",
      m.should_auto_write(True, {"advance":"x","advance_to":"Done"}) is False)
check("flag ON + Building (gate) target does NOT write",
      m.should_auto_write(True, {"advance":"x","advance_to":"Building"}) is False)
sys.exit(rc)
PY
[ $? -eq 0 ] || fail=1

# 5. CLI guard: --advance-auto requires --only (never global)
if PSDRIVE_TEST=1 "$D" --json --advance-auto >/dev/null 2>&1; then
  no "--advance-auto without --only must error"
else
  ok "--advance-auto without --only errors"
fi

exit $fail
