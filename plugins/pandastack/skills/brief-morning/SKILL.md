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
domain: personal
classification: hybrid
allowed-tools: Bash, Read, Write, Edit, Grep
version: "0.1.2"
user-invocable: true
---

# Morning Briefing

Produce a one-page morning briefing for Panda and prepend it to today's daily note.

## Contract

- Run from `<personal-vault>`.
- Default target: `Blog/_daily/YYYY-MM-DD.md`.
- Smoke target: if the user/task names `/tmp/morning-briefing-smoke.md`, write there instead of the daily note.
- Use the personal Google account configured at `${PANDASTACK_USER_EMAIL}` for all Google sources in this workflow. If the env var is unset, abort with an actionable error rather than guessing.
- Never read Slack or work-only sources.
- If today's briefing already exists, replace only that briefing block.
- Never replace the rest of the daily note.
- Catch each source failure and write `(source unavailable: <reason>)` in that section.
- Empty successful source means `(none)`.
- **Never create a fake `$HOME` or copy `~/.pdctx` into cwd.** The real `$HOME` is correctly set by hermes / the calling shell. Any sandbox staging belongs in `/tmp`, not in the vault.
- After writing, echo one line: `morning-briefing wrote <target> sections=3`.

## Sources

1. Yesterday's daily note: read `Blog/_daily/$(date -v-1d +%Y-%m-%d).md`; within `## Action Items`, extract unchecked `- [ ]` lines.
2. Calendar: `gog calendar events "${PANDASTACK_USER_EMAIL}" --today --max 5 --plain --account "${PANDASTACK_USER_EMAIL}"`; format the first 3 events as start time, title, attendee count, and prep needed.
3. Gmail: `gog gmail search 'is:unread newer_than:12h' --max 10 --plain --account "${PANDASTACK_USER_EMAIL}"`; keep the top 3 personal-priority or urgent threads.
4. Vault focus seed: `gbq "yesterday distill OR open todos OR P0"`, use the top relevant hit.
5. Writing seeds: reuse the strongest 3 note candidates from yesterday's distill / queue-worthy items in the vault.

## Template

```markdown
## Morning Briefing (auto · YYYY-MM-DD HH:MM)

### 1. 分門別類

#### 昨日未完成
- <todo from yesterday's daily note ## Action Items, only unchecked>

#### 今日行事曆
- <first 3 meetings, each with prep needed>

#### Email P0
- <personal Gmail unread threads within 12h, top 3>

#### 寫作種子
- <top 3 writing / note candidates worth developing today>

### 2. 時間點應該做什麼
- <now ~ first meeting: highest-leverage focus block>
- <before each timed event: prep or reply needed>
- <afternoon / after lunch: second focus block>

### 3. 建議行動
- <one concrete action per line, imperative>
- <second concrete action per line>
- <third concrete action per line>
```

## Write Algorithm

1. Compose the full briefing block with exactly the three top-level sections above.
2. Under `### 1. 分門別類`, always keep the four subsections in this order: `昨日未完成`, `今日行事曆`, `Email P0`, `寫作種子`.
3. Under `### 2. 時間點應該做什麼`, write 2-4 bullets in chronological order. Use concrete clock times when available from calendar; otherwise use relative windows like `現在`, `中午前`, `下午`.
4. Under `### 3. 建議行動`, write 3-5 standalone bullets, one action per line. Do not merge multiple actions into one bullet.
5. If writing to smoke target, write only the briefing block to `/tmp/morning-briefing-smoke.md`.
6. If writing to daily note, preserve YAML frontmatter and the `# YYYY-MM-DD Daily Log` heading.
7. Insert the briefing after the H1.
8. If an existing `## Morning Briefing (auto · ...)` block appears before the next `## ` heading, replace that block.
9. Re-run once for idempotency when smoke-testing; the file must still contain one briefing block.
