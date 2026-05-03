---
name: evening-distill
description: End-of-day signal sweep that stages distill candidates in Inbox/distill-queue.md and writes an Evening Distill block. Triggers on /evening-distill, Hermes cron 0 22 * * *, and manual pdctx call personal:writer "/evening-distill".
reads:
  - vault: Blog/_daily/*.md
  - vault: Inbox/**
  - cli: date
  - cli: gbq
  - cli: slack
writes:
  - vault: Blog/_daily/*.md
  - vault: Inbox/distill-queue.md
  - file: /tmp/evening-distill-smoke.md
  - cli: stdout
forbids:
  - file: /Users/panda/site/knowledge/work-vault/**
domain: personal
classification: hybrid
allowed-tools: Bash, Read, Write, Edit, Grep
version: "0.1.0"
user-invocable: true
---

# Evening Distill
Scan today's signals, stage 1-3 distill candidates, and write an evening block.

## Contract
- Run from `<personal-vault>`.
- Default target: `Blog/_daily/YYYY-MM-DD.md`.
- Smoke target: if the user/task names `/tmp/evening-distill-smoke.md`, write the block there instead of the daily note.
- Queue target: `Inbox/distill-queue.md`; create it with `# Distill Queue` if missing.
- If today's evening block already exists, replace only that block.
- Dedupe queue appends by vault path; never append the same path twice.
- Catch each source failure and write `(source unavailable: <reason>)` in that section.
- Empty successful source means `(none)`.
- Do not promote notes; only propose human-reviewed candidates.
- After writing, echo one line: `evening-distill wrote <target> queue_appended=N sections=3`.

## Sources

1. Today's daily note: read `Blog/_daily/$(date +%Y-%m-%d).md`; count closed `^- \[x\]` and open `^- \[ \]` items; extract the top closed item with payoff signal.
2. Slack: `slack search "" --since 12h --limit 30`; keep DMs and Yei channels; group by thread; rank by reply count plus Panda mention; top 3.
3. Vault capture: `gbq "captured today" --limit 10`; also scan today's daily note and `Inbox/` for today's new files when gbq is empty.

Score vault-path candidates by reuse-likely, novel, and small. Pick top 3. If no real vault-path candidate exists, output `(none)` and append nothing.

## Template

```markdown
## Evening Distill (auto · YYYY-MM-DD HH:MM)

### Signal scan
- Daily note today: <N action items closed, M opened, top 1 line>
- Slack today: <top 3 threads by reply count, in DMs + Yei channels>
- gbq today: <new captured notes with novel claims, or (none)>

### Distill candidates (top 3)
- [[<vault path>]], <1-line reason this is worth promoting>

### Promoted to queue
- Appended <N> candidates to [[Inbox/distill-queue.md]]
```

## Write Algorithm

1. Compose the full block with exactly the three sections above.
2. If writing to smoke target, write only the block to `/tmp/evening-distill-smoke.md`.
3. Ensure `Inbox/distill-queue.md` exists with `# Distill Queue` and a blank line.
4. Append only new candidate paths to the queue as `- [[path]], reason (YYYY-MM-DD)`.
5. If writing to daily note, preserve YAML frontmatter and the `# YYYY-MM-DD Daily Log` heading.
6. Append the evening block near the end of the daily note.
7. If an existing `## Evening Distill (auto · ...)` block appears before the next `## ` heading or EOF, replace that block.
8. Re-run once for idempotency when smoke-testing; the queue and target must not duplicate entries.

## Failure Modes
- Daily note missing: write `(source unavailable: daily note missing)`.
- Slack or gbq fails: keep the source line and include a short reason.
- Queue malformed: back up to `Inbox/distill-queue.md.bak-YYYYMMDD-HHMMSS`, recreate header, append deduped candidates.
