---
name: done
description: Save session context, summarize work, persist memory at session end. Triggers on "/done", "session done", "wrap up".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
version: "3.0.0"
user-invocable: true
---

# /done — Session Closer

Three steps. Goal: **finish in 1-2 minutes for routine sessions, 3-4 minutes when value scan finds something**. Most sessions end at Step 1.

## Step 1: Save Session MD

### Determine path & metadata

```bash
BRANCH=$(git branch --show-current 2>/dev/null || echo "no-git")
if git rev-parse --show-toplevel &>/dev/null; then
  SESSION_DIR="$(git rev-parse --show-toplevel)/docs/sessions"
else
  SESSION_DIR="/Users/panda/site/knowledge/obsidian-vault/docs/sessions"
fi
mkdir -p "$SESSION_DIR"
# Filename: YYYY-MM-DD-<slug>.md (slug = branch name or topic in kebab-case)
```

**Short or unfocused sessions** (under 10 turns, or no clear single topic): Write a minimal session doc — collapse "What happened" to 1-2 sentences, skip "Retrospective", keep "Current state" and "Follow-ups" only if actionable.

### Write session doc

```markdown
---
date: YYYY-MM-DD
branch: <branch-or-topic>
project: <repo-or-context>
tags: [coding-session, <project>]
---

# <branch-or-topic> — <date>

## What happened
[3-5 sentence narrative — shift handover style, not bullet lists]

## Retrospective
[What shifted in thinking, what was surprising, what was confirmed.
Skip if session was purely mechanical.]

## Current state
[Where things stopped. Be specific.]

## Follow-ups
[Only if P0/P1 actionable items exist. Most sessions have none — omit the section entirely.]
- [ ] [P0/P1 item with concrete action and owner/deadline if known]
```

**Follow-up routing** — do NOT leave follow-ups only in the session doc. Route them:
1. **P0/P1 items** → append to today's daily note under `## Action Items` (with source session link)
2. **Dev tasks** → suggest `gh issue create` — only create if user confirms
3. **Everything else** → drop it. If it's not P0/P1, it won't get done. Don't write it down.

After saving: run `qmd update` (only if session doc is inside the obsidian vault; skip for external repos).

**If `qmd update` fails with `ERR_DLOPEN_FAILED` / `NODE_MODULE_VERSION` mismatch**, this is a recurring better-sqlite3 ABI drift (qmd is `bun link`-ed to `~/site/cli/qmd/`, so its `node_modules/better-sqlite3` must match the *current* Node ABI, not the Node version at `bun link` time). Auto-recover:

```bash
cd ~/site/cli/qmd && npm rebuild better-sqlite3 && qmd update
```

Then continue. If recovery also fails (e.g. node-gyp toolchain broken), surface as a P1 follow-up in the daily note (`qmd broken: <error code> on Node <version>`) and continue with Step 3 sub-checks that don't need qmd.

### Sync to daily note

Daily note path: `~/site/knowledge/obsidian-vault/Blog/_daily/YYYY-MM-DD.md`

Append a concise summary to today's daily note. If the daily note already has session content, merge — don't duplicate. Format:

```markdown
## Session: <topic>
- [2-3 bullet summary of key outcomes, decisions, or artifacts created]
```

If P0/P1 follow-ups were identified, also append them under `## Action Items` (create section if missing):

```markdown
## Action Items
- [ ] [P0] <action> — from [[YYYY-MM-DD-session-slug]]
```

If the daily note doesn't exist yet, create it with standard frontmatter (`date`, `status: draft`).

---

## Step 2: Memory Routing (most sessions skip)

Only save things worth remembering across sessions. The auto-memory system in the system prompt has the routing rules — follow them. Skip if nothing new.

If you DID save memory entries, also note in the daily note's session block: `Memory: +N entries (user/feedback/project/reference)`.

---

## Step 3: Value Scan (skip if session < 5 substantive turns or purely mechanical)

This is the cross-session pattern surfacing layer. **Run all four sub-checks in parallel**, output ONE consolidated block at the end. If nothing surfaces from any check, skip the output entirely — silence is fine.

### 3a. Surprises & validated assumptions

Scan the conversation for:
- Things the user said "yes exactly" / "對" / "確認" to that were non-obvious
- Things that surprised either side (errors that taught something, behavior that contradicted assumptions)
- Decisions made that close off a path

If ≥ 2 surface: include in output as `## Worth saving from this session`.

**For each bullet, tag a routing suggestion** using this table:

| Content type | Route to |
|---|---|
| Searchable technical fact, reusable debugging pattern, domain concept | `knowledge/<area>/` |
| Tool recipe / CLI gotcha / external system pointer | `memory/reference_*.md` |
| Durable preference, how-we-work rule, validated style choice | `memory/feedback_*.md` |
| 3+ step repeatable workflow (even first strike) | `_staging/skill-*` (draft only) |
| Tactical meta-observation, one-session curiosity | drop |

Default to `drop` when in doubt — surfacing is already the baseline value. Only tag a route when the content is actually compound-worthy.

### 3b. Skill candidate detection (two-strike rule)

Apply `~/.claude/rules/skill-emergence.md`:
- Did this session execute a 3+ step repeatable workflow?
- Has a similar workflow been done before?
  ```bash
  qmd vsearch "<one-line description of the workflow>" --limit 3
  ```
- If you find a prior session doing the same thing, surface: `## Skill candidate: <name>` with the concrete pattern (where it ran before, where it ran today).
- Do NOT auto-create the skill. Show the pattern, let user confirm.

### 3c. Past-pattern check (cross-session memory)

Run `qmd vsearch` against `sessions` collection with the topic of this session:
```bash
qmd vsearch "<2-5 keywords from this session's topic>" --limit 5 2>/dev/null \
  | grep -v "^\[node-llama-cpp\]" | grep -v "^load:"
```

If results include sessions from > 7 days ago that look directly relevant:
- Surface as `## Past relevant sessions` with 1-line context per hit
- This is what makes the second brain valuable — not recall, surface
- Skip if all hits are from the last few days (already in working memory)

### 3d. Feedback drift check

Read `~/site/knowledge/obsidian-vault/knowledge/personal/feedback-log.md` (skip if missing).

For each `## YYYY-MM-DD` heading in the file marked `status: active`:
- Compare its **下次怎麼避** action against this session's behavior
- If the session repeated a flagged pattern, surface as `## ⚠ Feedback drift detected` with:
  - which feedback entry
  - what happened in this session
  - quoted "下次怎麼避" line

This step exists to surface bad habits **at session end** so the operator sees them within minutes, not weekly.

### Step 3 output format

Only output a Step 3 block if at least one sub-check found something. Otherwise stay silent. Format:

```markdown
---

## Step 3: Value Scan

### Worth saving from this session
- [bullet] ... (reference to where it was discussed in transcript)
  → route: `knowledge/<area>/<slug>.md` | `memory/reference_*` | `memory/feedback_*` | `_staging/skill-*` | drop

→ Promote any to routed destination? Reply `promote 1,3` or skip.
  (Drafts go to destination path with `status: draft` — still requires your review before commit. `drop` items are skipped.)

### Skill candidate: <name>
- Pattern: <one line>
- Prior instance: <session-slug or daily note ref>
- This session: <what triggered the second strike>
- → Want me to draft the skill? (don't auto-create)

### Past relevant sessions
- [[YYYY-MM-DD-slug]] — <one line of why it matters now>

### ⚠ Feedback drift detected
- Feedback from YYYY-MM-DD (source: ...): "<quoted action>"
- This session: <what happened that violated it>
- → Worth re-noting in feedback-log.md as a repeat occurrence
```

### Step 3 promotion follow-through

When user replies `promote <N,N,...>` to the routing prompt:

1. For each selected item:
   - **`knowledge/<area>/<slug>.md`** — draft a full note (frontmatter with `date`, `status: draft`, `last_human_review`, `tags`). Include content expanded from the bullet, not just a stub. Leave `verified` unset.
   - **`memory/reference_*.md` or `memory/feedback_*.md`** — write the file + append index line in `MEMORY.md`. Reference memories go live immediately; feedback memories are durable so draft carefully.
   - **`_staging/skill-*/SKILL.md`** — draft with frontmatter `status: draft, origin: done-promote, observed_count: 1`. Do NOT move to `skills/` — user mv's it when two-strike fires.
2. After writing, report paths and remind: "Review before commit. Skills stay in `_staging/` until you `mv`."
3. If user replies `skip` or just next message: drop silently, no drafts written.

Promotion is **draft-and-ask for knowledge/ + feedback**, auto-resolve for reference + staging skill (both reversible, per auto-resolver policy).

---

## Safety

| Situation | Action |
|-----------|--------|
| No git repo | Use conversation topic as slug |
| MEMORY.md > 190 lines | Slim down first |
| qmd `ERR_DLOPEN_FAILED` / ABI mismatch | Auto-rebuild `better-sqlite3` in `~/site/cli/qmd/` (see Sync to daily note section), retry once |
| qmd unavailable for other reason | Skip 3b/3c silently, still run 3a/3d, surface as P1 follow-up |
| feedback-log.md missing | Skip 3d silently |
| Session < 5 substantive turns | Skip Step 3 entirely |

## When to skip Step 3 entirely

- Session was purely mechanical (rename files, run a command, single-purpose lookup)
- Session was a continuation of an active flow (Step 3 only fires at meaningful checkpoints)
- User explicitly says "/done quick" or "just save"
