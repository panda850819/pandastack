---
name: brief-morning
aliases: [morning-briefing]
description: Produce a one-page morning briefing and prepend it to today's daily note. Triggers on /brief-morning, /morning-briefing (alias), Hermes cron 0 8 * * *, and manual pdctx call personal:writer "/brief-morning".
reads:
  - vault: Blog/_daily/*.md
  - cli: date
  - cli: gbq
  - cli: gog
writes:
  - vault: Blog/_daily/*.md
  - file: /tmp/morning-briefing-smoke.md
  - cli: stdout
forbids:
  - file: /Users/panda/site/knowledge/work-vault/**
domain: personal
classification: hybrid
allowed-tools: Bash, Read, Write, Edit, Grep
version: "0.1.1"
user-invocable: true
---

# Morning Briefing

Produce a one-page morning briefing for Panda and prepend it to today's daily note.

## Contract

- Run from `<personal-vault>`.
- Default target: `Blog/_daily/YYYY-MM-DD.md`.
- Smoke target: if the user/task names `/tmp/morning-briefing-smoke.md`, write there instead of the daily note.
- Use Panda's personal Google account `pandap.d819@gmail.com` for all Google sources in this workflow.
- Never read Slack or work-only sources.
- If today's briefing already exists, replace only that briefing block.
- Never replace the rest of the daily note.
- Catch each source failure and write `(source unavailable: <reason>)` in that section.
- Empty successful source means `(none)`.
- **Never create a fake `$HOME` or copy `~/.pdctx` into cwd.** The real `$HOME` is correctly set by hermes / the calling shell. Any sandbox staging belongs in `/tmp`, not in the vault.
- After writing, echo one line: `morning-briefing wrote <target> sections=5`.

## Sources

1. Yesterday's daily note: read `Blog/_daily/$(date -v-1d +%Y-%m-%d).md`; within `## Action Items`, extract unchecked `- [ ]` lines.
2. Calendar: `gog calendar events pandap.d819@gmail.com --today --max 5 --plain --account pandap.d819@gmail.com`; format the first 3 events as start time, title, attendee count, and prep needed.
3. Gmail: `gog gmail search 'is:unread newer_than:12h' --max 10 --plain --account pandap.d819@gmail.com`; keep the top 3 personal-priority or urgent threads.
4. Vault focus seed: `gbq "yesterday distill OR open todos OR P0"`, use the top relevant hit.
5. Writing seeds: reuse the strongest 3 note candidates from yesterday's distill / queue-worthy items in the vault.

## Template

```markdown
## Morning Briefing (auto · YYYY-MM-DD HH:MM)

### Yesterday's open items
- <todo from yesterday's daily note ## Action Items, only unchecked>

### Today's calendar
- <first 3 meetings, each with prep needed>

### Email P0
- <personal Gmail unread threads within 12h, top 3>

### Suggested focus
- <1 line: today's #1 thing, derived from yesterday's distill + open items>

### Writing seeds
- <top 3 writing / note candidates worth developing today>
```

## Write Algorithm

1. Compose the full briefing block with exactly the five sections above.
2. If writing to smoke target, write only the briefing block to `/tmp/morning-briefing-smoke.md`.
3. If writing to daily note, preserve YAML frontmatter and the `# YYYY-MM-DD Daily Log` heading.
4. Insert the briefing after the H1.
5. If an existing `## Morning Briefing (auto · ...)` block appears before the next `## ` heading, replace that block.
6. Re-run once for idempotency when smoke-testing; the file must still contain one briefing block.
