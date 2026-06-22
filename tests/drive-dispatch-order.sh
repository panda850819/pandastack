#!/usr/bin/env bash
# tests/drive-dispatch-order.sh — PRO-69: the dispatch loop runs BUILDS before read-only AUTO
# steps, so under --max 1 a build (which earns the streak) is never starved by a read-only
# PLAN/verify proposal that the driver re-proposes every tick. Stable: priority order is kept
# within builds and within read-only items; inert when no build is present.
set -uo pipefail
export PSDRIVE_TEST=1
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
D="$repo_root/scripts/pandastack-drive"
fail=0

out="$(PSDRIVE_TEST=1 python3 - "$D" <<'PY'
import sys, json, importlib.util
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("psdrive", sys.argv[1])
m = importlib.util.module_from_spec(importlib.util.spec_from_loader("psdrive", loader)); loader.exec_module(m)

def ids(items): return [e["id"] for e in m.dispatch_order(items)]

# 1. a read-only proposal ahead of a build (by priority) → build dispatched FIRST
mixed = [{"id": "PLAN-hi", "build": False}, {"id": "BUILD-lo", "build": True}]
assert ids(mixed) == ["BUILD-lo", "PLAN-hi"], ids(mixed)

# 2. stable within each group (priority order preserved)
many = [{"id": "P1"}, {"id": "B1", "build": True}, {"id": "P2"}, {"id": "B2", "build": True}]
assert ids(many) == ["B1", "B2", "P1", "P2"], ids(many)

# 3. inert when there is no build (build_auto off → every item read-only → original order)
ro = [{"id": "A"}, {"id": "B"}, {"id": "C"}]
assert ids(ro) == ["A", "B", "C"], ids(ro)

# 4. all builds → order preserved
ab = [{"id": "B1", "build": True}, {"id": "B2", "build": True}]
assert ids(ab) == ["B1", "B2"], ids(ab)
print("OK")
PY
)" || true

echo "$out" | grep -q "^OK$" && echo "PASS: dispatch_order runs builds first, stable, inert without builds" \
  || { echo "FAIL: $out"; fail=1; }

[ "$fail" -eq 0 ] && echo "OK: drive-dispatch-order all green" || echo "FAILURES present"
exit "$fail"
