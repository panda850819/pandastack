---
name: knowledge-ship
version: 0.1.0
status: draft
origin: manual
description: |
  Close the loop on a knowledge/ note. Three-stage pipeline:
  Close (mechanic) → Extract (semantic learning) → Backflow (system update).
  Marks note as verified, records where it was used, and routes any extracted
  generalizable principle / SOP candidate / source-quality signal back to the
  right layer (rules, work-vault, feed-curator). The point is not to bless the
  note — the point is to feed the system so it gets smarter on the next loop.
  Trigger: /knowledge-ship <note-path>, "ship this note", "close out this note".
tags: [vault, knowledge, lifecycle, ship]
related_skills: [wiki-lint, daily-distill, feed-curator]
---

# /knowledge-ship

Close a `knowledge/<domain>/<note>.md` note's lifecycle.

Run from vault root (`~/site/knowledge/obsidian-vault`). Pass the note path as `$ARGUMENTS`. If empty, ask.

## Scope: vault-only

This skill **never writes to external systems** (Notion / Jira / Linear / Slack / X / GitHub). Every mutation lands inside the Obsidian vault directory tree (`knowledge/`, `Inbox/`, work-vault SOP draft, `~/.claude/` rules / memory drafts). External systems are only read for reference, never written to.

If a Backflow path appears to need external action, write the proposal as a markdown file under `Inbox/ship-proposals/` for the user to manually push later — do not call any external API.

## Anti-ceremony rule

Default to **Close-only** (Stage 1) unless user explicitly opts into Extract / Backflow, OR Stage 1 detects a Backflow trigger condition (3+ citations, work-problem solve, repeat source).

Open with one question:

> 「Close-only 還是完整 ship（Close + Extract + Backflow）？」

Default to Close-only on no answer. Skip the question entirely if `$ARGUMENTS` includes `--full` or `--close-only`.

If Extract returns "no new insight" — that is a valid result. Do not force three answers.

---

## Stage 1: Close (mechanic)

Always run. Pure file operations.

### 1.1 Read the note

```bash
NOTE="$ARGUMENTS"
[ -z "$NOTE" ] && echo "需要 note path" && exit 1
[ ! -f "$NOTE" ] && echo "note 不存在: $NOTE" && exit 1
```

Read frontmatter and body. Extract: `date`, `type`, `source`, `tags`, existing `verified`, `last_human_review`, `used_in`.

### 1.2 Update frontmatter

Set:
- `verified: true`
- `last_human_review: <today YYYY-MM-DD>`

Append to `used_in:` (create if missing) — ask user one line:

> 「這個 note 是在什麼 context 被用到？(blog post / work decision / 引用 to another note / 其他)」

Record as one entry: `- {context}: {short description} ({YYYY-MM-DD})`.

If user skips the question, set `used_in_review_only: true` instead — meaning verified by review, not by use.

### 1.3 Source-quality signal

If the note has a `source:` URL, append to `Inbox/feeds/source-quality.json`:

```json
{ "url": "<source>", "note": "<note path>", "signal": "shipped", "ts": "<ISO8601>" }
```

Create file if missing. feed-curator reads this on next run.

### 1.4 Detect Backflow triggers

Scan and report:

- **Citation count**: `rg -l "\[\[$(basename "$NOTE" .md)\]\]" knowledge/ Blog/ | wc -l`
- **Solved a work problem?**: check `used_in` for keywords `work`, `yei`, `sommet`, `abyss`, or note tags containing `work`
- **Repeat source domain**: count how many notes in vault share this `source:` domain

### 1.5 Show & Confirm (gate)

Before stopping or moving to Stage 2, show user **everything that was just written**, including diffs, so they can verify before doing anything else (manual push, edit, or revert).

Print:

```
=== /knowledge-ship 完成（vault 已更新）===

Close 完成: <note path>
  citations: N
  used_in: <latest entry>
  source domain count: M
  Backflow triggers detected: [<list>]

== 已寫入 ==
1. <note path> (frontmatter)
   diff:
   + verified: true
   + last_human_review: <YYYY-MM-DD>
   + used_in:
   +   - <context>: <description> (<date>)

2. Inbox/feeds/source-quality.json (appended)
   added entry:
   { "url": "<source>", "note": "<note path>", "signal": "shipped", "ts": "<ISO>" }

== 接下來 ==
- 一切已寫入 vault，外部系統未動
- 你可以直接 review 上面的檔案、手動編輯、或不做任何事
- 要繼續 Stage 2 (Extract) + Stage 3 (Backflow) 嗎？[y/N]
```

If user says no / stops here, write the ship-log entry (see Output section) and exit.

If no Backflow triggers AND user picked Close-only at the start, default to "stop here, show summary, exit". Don't ask the Stage 2 question.

---

## Stage 2: Extract (semantic)

Run only on full ship OR when Stage 1 detected a Backflow trigger.

Ask user three questions, one at a time. Allow "skip" / "無" answers.

1. **解了什麼具體問題？** (一句話。如果只是「這是個有用的 framework」這種空話，重問或允許 skip)
2. **這是哪一類知識？** (framework / case / data / playbook / model / heuristic — pick one)
3. **有沒有 generalizable principle 可以抽出？** (如果有，寫一句話 principle；如果沒有，skip)

Store answers in memory (this session) for Stage 3. If all three are skipped, log `extract: empty` and skip Stage 3.

---

## Stage 3: Backflow (system update)

Use the routing table below. Each row fires if its condition matches. Multiple rows can fire on the same ship.

| 條件 | 動作 | 落點 |
|---|---|---|
| Q3 produced a generalizable principle | Draft a `~/.claude/rules/<slug>.md` proposal (do NOT auto-write — show diff, ask) | `~/.claude/rules/` |
| Q1 = debug pattern / pitfall / architecture decision (= compound territory) | Draft `docs/learnings/<category>/<slug>.md` (categories: patterns / pitfalls / architecture). Includes problem / failed-attempts / root-cause / fix / prevention. Replaces standalone `pandastack:compound` skill. | `docs/learnings/<category>/` |
| citation count ≥3 AND knowledge type = framework/playbook | Add entry to `knowledge/<domain>/_index.md` under "Frequently referenced" section (create section if missing) | `_index.md` |
| Q1 names a work problem AND principle is reusable | Draft SOP candidate at `~/site/knowledge/work-vault/sop/<slug>.md` (de-sensitive: strip company/person/$/ticker names from any draft) | `work-vault/sop/` |
| source domain has ≥3 shipped notes | Append to `Inbox/feeds/source-quality.json` with `signal: high-quality-source` (one entry per domain, not per note) | feed-curator data |
| Q2 = heuristic AND principle short enough (<200 chars) | Draft addition to user's memory `feedback_*` or `project_*` (show diff, ask) | `~/.claude/projects/-Users-panda-site-knowledge-obsidian-vault/memory/` |

**Critical**: Stage 3 NEVER writes destructively without showing a diff and asking. The point is reversible system update, not silent mutation.

For each fired row, output:

```
Backflow proposal: <落點>
---
<diff or new file content>
---
Apply? [y/N/edit]
```

`edit` opens user's $EDITOR with the proposal.

---

## Output

Final summary block, written to stdout AND appended to a daily ship log at `Inbox/ship-log/YYYY-MM-DD.md` (create if missing):

```markdown
## /knowledge-ship <note-path> @ HH:MM

- Close: ✓ (verified, last_human_review, used_in: <context>)
- Extract: <empty | 3 answers summary>
- Backflow:
  - <action 1> → <落點>
  - <action 2> → <落點>
- Triggers detected: [<list>]
- Citations: N
```

This log is what retro-week / retro-month reads to compute "ship rate".

---

## Failure modes (and what to do)

| 症狀 | 處理 |
|---|---|
| Note path doesn't exist | Abort, suggest `qmd search` to find it |
| Note already has `verified: true` AND `last_human_review` within 30 days | Ask "重新 ship 嗎？" — don't silently re-stamp |
| `Inbox/feeds/source-quality.json` malformed | Backup to `.bak`, recreate |
| `_index.md` missing for the domain | Create skeleton (just `# <Domain> Index\n\n## Frequently referenced\n`) |
| User aborts mid-Stage-3 | All Stage 1 mutations stay (already applied), Stage 3 proposals discarded |

---

## Future use (read this when you wonder if ship was worth it)

After two weeks of using `/knowledge-ship`:

1. **Search**: `qmd query` ranks shipped notes higher (verified=true, recent review). Wiki-lint stops flagging them as stale.
2. **Reuse**: `rg "used_in:" knowledge/ -A 3` lists every note that has earned its keep. Use this list when starting a new blog post or strategic memo.
3. **System learning**: feed-curator pulls `source-quality.json`. Sources you've shipped from get ranked higher next cycle.
4. **Retro signal**: `Inbox/ship-log/` aggregates into retro-week as `knowledge ship rate = ships per week`. Track trend, not absolute count.

The point of ship is not the ship. The point is that next month's you has a smarter system.
