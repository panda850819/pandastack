---
name: retro-prep-week
aliases: [weekly-retro-prep]
description: Pre-fetch all retro inputs, write structured prep file to Inbox/retro-prep-YYYY-Wxx.md. Triggers on /retro-prep-week, /weekly-retro-prep (alias), Hermes cron 0 9 * * 5, manual pdctx call personal:writer "/retro-prep-week".
reads:
  - vault: Blog/_daily/*.md
  - cli: date
  - cli: gog
  - cli: slack
writes:
  - vault: Inbox/retro-prep-*.md
  - file: /tmp/retro-prep-smoke.md
  - cli: stdout
domain: personal
classification: hybrid
allowed-tools: Bash, Read, Write, Edit, Grep
version: "0.1.0"
user-invocable: true
---

# Weekly Retro Prep

Pre-fetch and aggregate weekly data; write a structured prep file for /retro-week.

## Contract

- Run from `<personal-vault>`. Compute `WEEK_RANGE=$(date +%Y-W%V)`.
- Default target: `Inbox/retro-prep-$WEEK_RANGE.md`. Overwrite if exists (idempotent).
- Smoke target: write to `/tmp/retro-prep-smoke.md` when task specifies it.
- Each source can fail → `(source unavailable: <reason>)`. Empty source → `(none)`.
- This is **data**, not analysis. Do not editorialize.
- After writing, echo: `weekly-retro-prep wrote <target> sections=8`.
- **Never create a fake `$HOME` or copy `~/.pdctx` into cwd.** The real `$HOME` is correctly set by hermes / the calling shell. Any sandbox staging belongs in `/tmp`, not in the vault.

## Sources

1. Daily notes Mon-Fri: `Blog/_daily/$YYYY-MM-DD.md` for current week.
2. Action items: grep `^- \[x\]` (closed) and `^- \[ \]` (open) across the 5 notes.
3. Calendar: `gog calendar events list --from $MON --to $FRI --max 20 --plain`; count meetings, top 3 by duration, top 3 by attendees, gaps >2h.
4. Slack: `slack search "" --since 7d --limit 100`; DM count, top 3 channels by mention, grep `decided|決定|我們會`.
5. Wins: grep `ship|出貨|完成|merged` across daily notes; up to 5.
6. Blockers: grep `卡住|blocked|wait|等` across daily notes; up to 5.
7. Linear / Notion: try CLIs; skip gracefully with `(none)` if unavailable.

## Output template (8 sections)

```
---
date: $TODAY  type: retro-prep  week: $WEEK_RANGE
---
# Retro Prep · $WEEK_RANGE
## Daily summary (Mon-Fri)
## Action items closed this week
## Action items still open (rolled this week)
## Calendar density
## Slack signal (last 7d)
## Linear / Notion
## Wins (machine-detected candidates)
## Blockers (machine-detected candidates)
## Ready for /retro-week
Next: run `/retro-week` Friday afternoon.
```

## Write Algorithm

1. Compute `MON`/`FRI`/`TODAY`/`WEEK_RANGE` via `date`.
2. Read 5 daily notes; aggregate action items.
3. Call `gog calendar`; catch failure.
4. Call `slack search`; catch failure.
5. Try Linear / Notion; skip if unavailable.
6. Grep daily notes for wins and blockers.
7. Write to target (overwrite if same week). Echo path.
