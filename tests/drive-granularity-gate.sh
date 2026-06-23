#!/usr/bin/env bash
# tests/drive-granularity-gate.sh — PRO-74: granularity alignment (the loop's Nyquist
# criterion). A card whose Deliverable ships an executable REQUIRES the `runtime` sensor
# layer; if the verify neither declares it (`layers:`, PRO-73) nor exercises it (the
# acceptance actually runs the artifact), the card is gated needs-spec with a "sensor gap"
# — the verify is coarser than the task and would alias a broken/non-executable binary into
# "done" (the PRO-22 class). Conservative: scoped to the Deliverable section, so an
# acceptance that merely RUNS a binary is not mistaken for the task PRODUCING one.
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$repo_root/scripts" <<'PY'
import sys
sys.path.insert(0, sys.argv[1])
import pslib
ok = True
def chk(cond, label):
    global ok
    print(("PASS: " if cond else "FAIL: ") + label)
    ok = ok and bool(cond)

GOAL = "## Goal\nship it\n## Context\ny\n"
DELIV_EXE = "\n## Deliverable\n* `bin/hermes-drift-check` executable + tests\n"

# Deliverable ships bin/, verify only typechecks (no runtime decl, never runs it) -> GAP
GAP = GOAL + "```acceptance\nlayers: typecheck\nnpm run typecheck\n```" + DELIV_EXE
# Same task, but the acceptance actually RUNS the binary -> runtime covered
COV_RUN = GOAL + "```acceptance\nbin/hermes-drift-check && grep -q ALL out\n```" + DELIV_EXE
# Same task, but `layers:` declares runtime -> covered
COV_DECL = GOAL + "```acceptance\nlayers: typecheck, runtime\nnpm run typecheck\n```" + DELIV_EXE
# No Deliverable section (existing-style card), acceptance runs a bin -> NOT required (no false gap)
NO_DELIV = GOAL + "```acceptance\nbin/x --baseline tests/fixtures/clean && grep -q ok out\n```"

chk(pslib.required_layers(GAP) == ["runtime"], "Deliverable shipping bin/ -> requires runtime")
chk(pslib.required_layers(NO_DELIV) == [], "no Deliverable section -> requires nothing (no false positive)")

chk(pslib.sensor_gap(GAP) is not None and "runtime" in pslib.sensor_gap(GAP), "typecheck-only verify on an executable task -> sensor gap")
chk(pslib.sensor_gap(COV_RUN) is None, "acceptance that runs the binary -> runtime covered, no gap")
chk(pslib.sensor_gap(COV_DECL) is None, "`layers: runtime` declared -> covered, no gap")
chk(pslib.sensor_gap(NO_DELIV) is None, "card that only runs a bin (no deliverable) -> no gap")

# readiness wiring: the gap gates a Building card as needs-spec; aligned ones pass
g = pslib.readiness_gap("Building", GAP)
chk(g is not None and "sensor gap" in g, "Building card with a sensor gap -> needs-spec")
chk(pslib.readiness_gap("Building", COV_RUN) is None, "Building card whose verify runs the artifact passes readiness")
chk(pslib.readiness_gap("Building", COV_DECL) is None, "Building card declaring `layers: runtime` passes readiness")
chk(pslib.readiness_gap("Building", NO_DELIV) is None, "existing-style card (no deliverable) still passes readiness")

sys.exit(0 if ok else 1)
PY
rc=$?
[ "$rc" -eq 0 ] && echo "OK: drive-granularity-gate all green" || echo "FAILURES present"
exit "$rc"
