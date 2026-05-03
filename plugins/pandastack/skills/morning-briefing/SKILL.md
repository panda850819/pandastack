---
name: morning-briefing
description: Produce a one-page morning briefing and prepend it to today's daily note. Triggers on /morning-briefing, Hermes cron 0 8 * * *, and manual pdctx call personal:writer "/morning-briefing".
reads:
  - vault: Blog/_daily/*.md
  - cli: date
  - cli: gbq
  - cli: gog
  - cli: slack
writes:
  - vault: Blog/_daily/*.md
  - file: /tmp/morning-briefing-smoke.md
  - cli: stdout
forbids:
  - file: /Users/panda/site/knowledge/work-vault/**
domain: personal
classification: hybrid
allowed-tools: Bash, Read, Write, Edit, Grep
version: "0.1.0"
user-invocable: true
---

# Morning Briefing

Produce a one-page morning briefing for Panda and prepend it to today's daily note.

## Contract

- Run from `<personal-vault>`.
- Default target: `Blog/_daily/YYYY-MM-DD.md`.
- Smoke target: if the user/task names `/tmp/morning-briefing-smoke.md`, write there instead of the daily note.
- If today's briefing already exists, replace only that briefing block.
- Never replace the rest of the daily note.
- Catch each source failure and write `(source unavailable: <reason>)` in that section.
- Empty successful source means `(none)`.
- **Never create a fake `$HOME` or copy `~/.pdctx` into cwd.** The real `$HOME` is correctly set by hermes / the calling shell. Any sandbox staging belongs in `/tmp`, not in the vault.
- After writing, echo one line: `morning-briefing wrote <target> sections=5`.

## Sources

1. Yesterday's daily note: read `Blog/_daily/$(date -v-1d +%Y-%m-%d).md`; within `## Action Items`, extract unchecked `- [ ]` lines.
2. Calendar: `gog calendar events list --today --max 5 --plain`; format the first 3 events as start time, title, attendee count, and prep needed.
3. Slack: `slack search '@PandaZeng1 after:$(date -v-1d +%Y-%m-%d)' --limit 10`; keep DMs and Yei channels, top 5 by signal.
4. Gmail: `gog gmail search 'is:unread newer_than:12h' --max 10 --plain`; keep Bob, Yei, or high-priority org mail, top 3.
5. Vault focus seed: `gbq "yesterday distill OR open todos OR P0"`, use the top relevant hit.

## Template

```markdown
## Morning Briefing (auto · YYYY-MM-DD HH:MM)

### Yesterday's open items
- <todo from yesterday's daily note ## Action Items, only unchecked>

### Today's calendar
- <first 3 meetings, each with prep needed>

### Slack (last 12h)
- <DMs to @PandaZeng1, mentions in Yei channels, top 5 by signal>

### Email P0
- <Bob, Yei high-priority, marked unread within 12h, top 3>

### Suggested focus
- <1 line: today's #1 thing, derived from yesterday's distill + open items>
```

## Write Algorithm

1. Compose the full briefing block with exactly the five sections above.
2. If writing to smoke target, write only the briefing block to `/tmp/morning-briefing-smoke.md`.
3. If writing to daily note, preserve YAML frontmatter and the `# YYYY-MM-DD Daily Log` heading.
4. Insert the briefing after the H1.
5. If an existing `## Morning Briefing (auto · ...)` block appears before the next `## ` heading, replace that block.
6. Re-run once for idempotency when smoke-testing; the file must still contain one briefing block.
