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
domain: personal
classification: hybrid
allowed-tools: Bash, Read, Write, Edit, Grep
version: "0.1.2"
user-invocable: true
---

# Evening Distill

Write an end-of-day personal handoff for Panda and append it to today's daily note.

## Contract
- Run from `<personal-vault>`.
- Default target: `Blog/_daily/YYYY-MM-DD.md`.
- Smoke target: if the user/task names `/tmp/evening-distill-smoke.md`, write the block there instead of the daily note.
- Use the default `gog` account for all Google sources (configure once via `gog config set default_account`). If `gog` has no default, abort with the actionable error from `gog` itself rather than guessing.
- Never read Slack or work-only sources.
- If today's evening block already exists, replace only that block.
- Never replace the rest of the daily note.
- Catch each source failure and write `(source unavailable: <reason>)` in that section.
- Empty successful source means `(none)`.
- After writing, echo one line: `evening-distill wrote <target> sections=3`.
- **Never create a fake `$HOME` or copy `~/.pdctx` into cwd.** The real `$HOME` is correctly set by hermes / the calling shell. Any sandbox staging belongs in `/tmp`, not in the vault.

## Sources

1. Today's daily note: read `Blog/_daily/$(date +%Y-%m-%d).md`; count closed `^- \[x\]` and open `^- \[ \]` items; extract the top completed item with the biggest payoff signal.
2. Tomorrow's calendar: `gog calendar events --tomorrow --max 5 --plain`; format the first 3 events as start time, title, attendee count, and prep needed.
3. Gmail carry-over: `gog gmail search 'is:unread newer_than:24h' --max 10 --plain`; keep the top 3 threads likely to matter tomorrow.
4. Vault focus seed: `gbq "today OR open todos OR P0 OR tomorrow"`, use the top relevant hit for tomorrow's first focus.
5. Writing seeds: reuse the strongest 3 note or writing candidates surfaced in today's daily note and recent vault hits.

## Template

```markdown
## Evening Distill (auto · YYYY-MM-DD HH:MM)

### 1. 分門別類

#### 今日收尾
- <N action items closed, top completed item with payoff>

#### 明日延續
- <top remaining unchecked items from today's daily note>

#### 明日行事曆
- <first 3 meetings or events, each with prep needed>

#### Email carry-over
- <personal Gmail unread threads likely to matter tomorrow, top 3>

#### 寫作種子
- <top 3 writing or note candidates worth carrying into tomorrow>

### 2. 時間點應該做什麼
- <tonight / before sleep: final cleanup or capture>
- <tomorrow morning first block: first focus>
- <before first meeting or afternoon block: prep needed>

### 3. 建議行動
- <one concrete action per line, imperative>
- <second concrete action per line>
- <third concrete action per line>
```

## Write Algorithm

1. Compose the full block with exactly the three top-level sections above.
2. Under `### 1. 分門別類`, always keep the five subsections in this order: `今日收尾`, `明日延續`, `明日行事曆`, `Email carry-over`, `寫作種子`.
3. Under `### 2. 時間點應該做什麼`, write 2-4 bullets in chronological order. Use concrete clock times when available from calendar; otherwise use relative windows like `今晚睡前`, `明早第一段`, `下午前`.
4. Under `### 3. 建議行動`, write 3-5 standalone bullets, one action per line. Do not merge multiple actions into one bullet.
5. If writing to smoke target, write only the block to `/tmp/evening-distill-smoke.md`.
6. If writing to daily note, preserve YAML frontmatter and the `# YYYY-MM-DD Daily Log` heading.
7. Append the evening block near the end of the daily note.
8. If an existing `## Evening Distill (auto · ...)` block appears before the next `## ` heading or EOF, replace that block.
9. Re-run once for idempotency when smoke-testing; the target must not duplicate the evening block.
