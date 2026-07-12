#!/usr/bin/env bash
# Keep Agent Worker as an opt-in native-subagent protocol, not another runner.
set -euo pipefail
cd "$(dirname "$0")/.."

check_contract() {
  local dispatch="$1"
  local field

  [ "$(grep -Fc 'Explicit Agent Worker / parallel read-only research' "$dispatch")" -eq 1 ]
  grep -Fq 'at most two' "$dispatch"
  grep -Fq 'disable nested delegation' "$dispatch"
  grep -Fq 'keep every pilot worker read-only' "$dispatch"
  grep -Fq 'main agent verifies evidence' "$dispatch"
  grep -Fq 'owns elapsed time, token usage' "$dispatch"

  for field in objective scope deliverable acceptance permissions budget \
               status findings evidence gaps; do
    grep -Fq "\`$field\`" "$dispatch"
  done
}

check_contract DISPATCH.md
grep -Fq 'Native read-only Agent Worker fan-out' skills/engineering/handover/SKILL.md
grep -Fq 'mechanical write delegation from Claude Code to Codex' skills/engineering/handover/SKILL.md

test ! -e skills/engineering/agent-worker/SKILL.md
test ! -e scripts/agent-worker

mutant="$(mktemp)"
trap 'rm -f "$mutant"' EXIT
sed 's/`gaps`/gaps/' DISPATCH.md > "$mutant"
if check_contract "$mutant" 2>/dev/null; then
  echo 'FAIL: contract check accepted a missing required field marker' >&2
  exit 1
fi

echo 'OK: Agent Worker stays a thin native-subagent contract.'
