#!/usr/bin/env bash
# PreToolUse guard — hard-blocks destructive Bash commands at code level.
# Nisi principle: enforce, don't instruct. A prompt-level "please confirm"
# can be skipped by the agent; an exit-2 hook cannot.
#
# Reads PreToolUse stdin JSON, inspects tool_input.command, exit 2 to block.
# Evaluates each ; && || newline segment independently so a benign segment
# can't carry a bypass for a dangerous one. Bypass: a TRAILING `# FORCE_OK`
# comment (not a substring anywhere), or PANDA_FORCE=1 in the environment.
#
# Test offline (zero risk):
#   echo '{"tool_name":"Bash","tool_input":{"command":"git push --force"}}' | ./pretooluse-destructive-guard.sh; echo $?
set -euo pipefail

INPUT=$(cat)
TOOL=$(printf '%s' "$INPUT" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_name",""))' 2>/dev/null || true)
[ "$TOOL" = "Bash" ] || exit 0

CMD=$(printf '%s' "$INPUT" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)
[ -n "$CMD" ] || exit 0

# Bypass: marker must be a TRAILING comment, not a mention mid-command.
printf '%s' "$CMD" | grep -qE '#[[:space:]]*FORCE_OK[[:space:]]*$' && exit 0
[ "${PANDA_FORCE:-}" = "1" ] && exit 0

block() {
  echo "BLOCKED by pandastack destructive-guard: $1" >&2
  echo "High-blast-radius op (force-push / recursive-force-rm / hard-reset / clean -f / DROP). Confirm explicitly or narrow it; append '# FORCE_OK' as a trailing comment to override." >&2
  exit 2
}

# Split on ; && || and newlines; evaluate each segment on its own.
SEGS=$(printf '%s' "$CMD" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g')
while IFS= read -r seg; do
  [ -n "$seg" ] || continue
  low=$(printf '%s' "$seg" | tr 'A-Z' 'a-z')

  # rm: blocks only when BOTH recursive AND force are present (any flag form /
  # order: -rf, -fr, -r -f, --recursive --force). `rm -i -v` etc. pass.
  if printf '%s' "$seg" | grep -qE '(^|[^a-zA-Z._-])rm([^a-zA-Z._]|$)' \
     && printf '%s' "$seg" | grep -qE '(-[a-zA-Z]*r|--recursive)' \
     && printf '%s' "$seg" | grep -qE '(-[a-zA-Z]*f|--force)'; then
    block "$seg"
  fi

  # git push force: --force(-with-lease), a bundled short flag containing f
  # (-f / -uf), or a +ref refspec (git push origin +main). Tolerates global
  # options between git and push (git -C dir push ...).
  if printf '%s' "$low" | grep -qE '(^|[^a-z])git([^a-z]|$)' && printf '%s' "$low" | grep -qE '(^|[^a-z])push([^a-z]|$)'; then
    if printf '%s' "$low" | grep -qE -- '--force' \
       || printf '%s' "$low" | grep -qE '[[:space:]]-[a-z]*f([[:space:]]|$)' \
       || printf '%s' "$low" | grep -qE 'push[[:space:]][^|]*[[:space:]]\+[^[:space:]]'; then
      block "$seg"
    fi
  fi

  # git reset --hard
  if printf '%s' "$low" | grep -qE '(^|[^a-z])git([^a-z]|$)' && printf '%s' "$low" | grep -qE '(^|[^a-z])reset([^a-z]|$)' && printf '%s' "$low" | grep -qE -- '--hard'; then
    block "$seg"
  fi

  # git clean -f / --force
  if printf '%s' "$low" | grep -qE '(^|[^a-z])git([^a-z]|$)' && printf '%s' "$low" | grep -qE '(^|[^a-z])clean([^a-z]|$)' && printf '%s' "$low" | grep -qE '(-[a-z]*f|--force)'; then
    block "$seg"
  fi

  # SQL destructive (substring; known to also catch SQL mentioned in strings).
  printf '%s' "$seg" | grep -qiE '(drop|truncate)[[:space:]]+(table|database|schema)' && block "$seg"
done <<EOF
$SEGS
EOF
exit 0
