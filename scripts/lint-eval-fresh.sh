#!/usr/bin/env bash
# lint-eval-fresh.sh — every skill must carry an eval.md, and that eval.md must
# have been generated against the CURRENT SKILL.md. Each eval.md records the
# git blob hash of the SKILL.md it scored (evaluated_skill_hash); this lint
# recomputes the hash and fails on missing or drifted evals. Turns per-skill
# eval files from silent sediment into a caught, fixable signal.
#
# Usage:
#   bash scripts/lint-eval-fresh.sh           # check every skill
#   bash scripts/lint-eval-fresh.sh <name>    # check one skill (exit 0/1)
#
# Skills live at skills/<bucket>/<skill>/. Fix a failure with /skill-eval <name>.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"
only="${1:-}"
scorecard="$repo_root/skills/meta/writing-great-skills/SKILL.md"
scorecard_version="$(sed -n 's/^version:[[:space:]]*//p' "$scorecard" | head -1 | tr -d '"[:space:]')"
expected_rubric="writing-great-skills@$scorecard_version"
scorecard_axes=()
while IFS= read -r axis; do
  scorecard_axes+=("$axis")
done < <(
  sed -n '/^## The scorecard$/,/^## /p' "$scorecard" |
    sed -n 's/^[0-9][0-9]*\. \*\*\([^*][^*]*\)\*\*.*/\1/p'
)

fail=0
checked=0

while IFS= read -r skdir; do
  [ -n "$skdir" ] || continue
  name="$(basename "$skdir")"
  [ -z "$only" ] || [ "$name" = "$only" ] || continue
  checked=$((checked + 1))

  skill_md="$skdir/SKILL.md"
  eval_md="$skdir/eval.md"
  rel="${skdir#"$repo_root"/}"

  if [ ! -f "$eval_md" ]; then
    echo "FAIL: $rel/ has no eval.md  (run: /skill-eval $name)"
    fail=1
    continue
  fi

  current="$(git -C "$repo_root" hash-object "$skill_md")"
  recorded="$(sed -n 's/^evaluated_skill_hash:[[:space:]]*//p' "$eval_md" | head -1 | tr -d '[:space:]')"
  rubric="$(sed -n 's/^rubric:[[:space:]]*//p' "$eval_md" | head -1 | tr -d '[:space:]')"

  if [ -z "$recorded" ]; then
    echo "FAIL: $rel/eval.md missing evaluated_skill_hash"
    fail=1
  elif [ "$current" != "$recorded" ]; then
    echo "FAIL: $rel/ eval is stale — SKILL.md changed since eval (run: /skill-eval $name)"
    echo "       SKILL.md=$current  eval=$recorded"
    fail=1
  fi

  if [ -z "$rubric" ]; then
    echo "FAIL: $rel/eval.md missing rubric"
    fail=1
  elif [ "$rubric" != "$expected_rubric" ]; then
    echo "FAIL: $rel/eval.md rubric is stale — expected $expected_rubric, found $rubric"
    fail=1
  fi

  for axis in "${scorecard_axes[@]}"; do
    if ! grep -Fq "| $axis |" "$eval_md"; then
      echo "FAIL: $rel/eval.md missing scorecard axis: $axis"
      fail=1
    fi
  done
done <<< "$(find "$skills_dir" -mindepth 2 -maxdepth 2 -type d ! -path '*/.archive/*' ! -path '*/_deprecated/*' | sort)"

if [ -n "$only" ] && [ "$checked" -eq 0 ]; then
  echo "FAIL: no skill named '$only' under skills/"
  exit 1
fi

if [ "$fail" -eq 0 ]; then
  echo "OK: all $checked skill eval(s) fresh (hash + $expected_rubric axes match current scorecard)."
fi
exit "$fail"
