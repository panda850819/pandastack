---
name: evening-distill
description: End-of-day personal handoff that writes an evening briefing block to today's daily note. Triggers on /evening-distill, Hermes cron 0 22 * * *, and manual pdctx call personal:writer "/evening-distill".
reads:
  - vault: Blog/_daily/*.md
  - cli: date
  - cli: gbq
  - cli: gog
writes:
  - vault: Blog/_daily/*.md
  - file: /tmp/evening-distill-smoke.md
  - cli: stdout
forbids:
  - file: /Users/panda/site/knowledge/work-vault/**
domain: personal
classification: hybrid
allowed-tools: Bash, Read, Write, Edit, Grep
version: "0.1.1"
user-invocable: true
---

# Evening Distill

Write an end-of-day personal handoff for Panda and append it to today's daily note.

## Contract
- Run from `<personal-vault>`.
- Default target: `Blog/_daily/YYYY-MM-DD.md`.
- Smoke target: if the user/task names `/tmp/evening-distill-smoke.md`, write the block there instead of the daily note.
- Use Panda's personal Google account `pandap.d819@gmail.com` for all Google sources in this workflow.
- Never read Slack or work-only sources.
- If today's evening block already exists, replace only that block.
- Never replace the rest of the daily note.
- Catch each source failure and write `(source unavailable: <reason>)` in that section.
- Empty successful source means `(none)`.
- After writing, echo one line: `evening-distill wrote <target> sections=6`.
- **Never create a fake `$HOME` or copy `~/.pdctx` into cwd.** The real `$HOME` is correctly set by hermes / the calling shell. Any sandbox staging belongs in `/tmp`, not in the vault.

## Sources

1. Today's daily note: read `Blog/_daily/$(date +%Y-%m-%d).md`; count closed `^- \[x\]` and open `^- \[ \]` items; extract the top completed item with the biggest payoff signal.
2. Tomorrow's calendar: `gog calendar events pandap.d819@gmail.com --tomorrow --max 5 --plain --account pandap.d819@gmail.com`; format the first 3 events as start time, title, attendee count, and prep needed.
3. Gmail carry-over: `gog gmail search 'is:unread newer_than:24h' --max 10 --plain --account pandap.d819@gmail.com`; keep the top 3 threads likely to matter tomorrow.
4. Vault focus seed: `gbq "today OR open todos OR P0 OR tomorrow"`, use the top relevant hit for tomorrow's first focus.
5. Writing seeds: reuse the strongest 3 note or writing candidates surfaced in today's daily note and recent vault hits.

## Template

```markdown
## Evening Distill (auto · YYYY-MM-DD HH:MM)

### Today's closed loop
- <N action items closed, top completed item with payoff>

### Rolled items for tomorrow
- <top remaining unchecked items from today's daily note>

### Tomorrow's calendar
- <first 3 meetings or events, each with prep needed>

### Email carry-over
- <personal Gmail unread threads likely to matter tomorrow, top 3>

### Suggested first focus tomorrow
- <1 line: tomorrow's first thing, derived from open items + vault focus seed>

### Writing seeds
- <top 3 writing or note candidates worth carrying into tomorrow>
```

## Write Algorithm

1. Compose the full block with exactly the six sections above.
2. If writing to smoke target, write only the block to `/tmp/evening-distill-smoke.md`.
3. If writing to daily note, preserve YAML frontmatter and the `# YYYY-MM-DD Daily Log` heading.
4. Append the evening block near the end of the daily note.
5. If an existing `## Evening Distill (auto · ...)` block appears before the next `## ` heading or EOF, replace that block.
6. Re-run once for idempotency when smoke-testing; the target must not duplicate the evening block.
