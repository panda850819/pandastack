---
name: process-decisions
description: Walk through ticked [x] items in Inbox/cron-reports/, execute each one, mark it done. Closes the loop started by launchd cron jobs (wiki-lint, harness-audit, retro-preps). Triggers on "/process-decisions", "process cron decisions", "review ticked items", "跑 cron decisions".
---

# Process Decisions

Closes the cron loop: the launchd jobs generate `## Top 3 Decisions` blocks with y/n checkboxes in `Inbox/cron-reports/*.md`. When Panda ticks `[ ]` → `[x]`, this skill walks through them, executes each, and marks them done.

## When to use

- Panda ticked items in a cron report (wiki-lint, harness-audit, retro-prep) and wants them actioned.
- Weekend cleanup: batch-process everything ticked over the past week.
- Triggers: `/process-decisions`, "process cron decisions", "review ticked items".

## Scope

Look at `<personal-vault>/Inbox/cron-reports/*.md` only. Do NOT touch other Inbox files or vault knowledge notes except via the executed actions.

## Step 1: Scan ticked items

```bash
cd <personal-vault>
# Find all [x] lines inside ## Top 3 Decisions blocks, last 14 days, not already ✓ done
find Inbox/cron-reports -name "*.md" -type f -mtime -14 | while read f; do
  awk '/^## Top 3 Decisions/{flag=1; next} /^## /{flag=0} flag && /^- \[x\]/ && !/✓/' "$f" | \
    sed "s|^|$f: |"
done
```

List file + line content. If empty, say so and stop.

## Step 2: For each ticked item, route by keyword

Parse the action phrase. The decisions use a stable format: `- [x] {action}: {target} — {one-line why}`.

| Keyword in action | Handler |
|---|---|
| `link`, `cross-link` | Add wiki-link from an MOC (`_index.md`) or a related note. Use Grep to find candidate parent note, then Edit to insert `[[stem]]`. |
| `merge` | Show both notes. Do NOT auto-merge — ask Panda which to keep as canonical, then propose the merge as a single Edit diff. |
| `archive` | `mv` note to `knowledge/_archive/` (create subdir mirroring original path if needed). |
| `promote` (skill) | `mv ~/.claude/skills/_staging/<name> ~/.claude/skills/<name>`. |
| `delete`, `rm` | Confirm once with Panda, then `rm`. Never silent. |
| `demote` (agent→skill) | Read current agent file, propose the skill-equivalent file, ask before writing. |
| else | Read surrounding context from the source report, act with LLM judgment. Ask Panda if ambiguous. |

Execute each action in turn, one at a time. After each success:

1. Edit the report line: append ` ✓ YYYY-MM-DD` at the end of the `- [x]` line so it's skipped on re-runs.
2. Print a one-line confirmation to console.

On failure:

1. Leave the line as `- [x]` (no ✓), so it re-appears next run.
2. Append a comment line below it: `  > skipped: {reason}`.
3. Continue to the next item — one failure doesn't abort the batch.

## Step 3: Summary + daily note

After processing all items, emit:

- Total ticked: N
- Executed: X
- Skipped: Y (list reasons)
- Asked for confirmation: Z

Append to today's daily note `Blog/_daily/YYYY-MM-DD.md` under `## Cron Actions` (create if missing):

```
- process-decisions: X/N executed ({list of reports touched})
```

## Safety

- Vault mutations (archive, delete, merge) are **draft-first when non-trivial**. Use Edit/Write with clear preview. Panda's auto-resolver rule applies: reversible = auto, hard-to-reverse = ask.
- Never delete a file unless the decision explicitly said `delete` or `rm`. `archive` → `mv` to `_archive/` is preferred.
- After any destructive step, log it to `/tmp/process-decisions-YYYY-MM-DD.log` with before/after paths so Panda can reverse.

## Out of scope

- Auto-ticking items (that's Panda's job).
- Running cron jobs themselves (launchd/hermes handle that).
- Acting on items older than 14 days (assume stale, need fresh context).

## Related

- `<personal-vault>/Inbox/cron-reports/` — input
- `~/.claude/skills/wiki-lint/SKILL.md` — produces wiki-lint decisions
- `~/.claude/skills/harness-slim/SKILL.md` — produces harness-audit decisions
- `~/.claude/rules/auto-resolver.md` — governs when to auto vs draft-first
