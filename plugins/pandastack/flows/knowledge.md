---
name: knowledge-flow
description: Lifecycle for absorbing, verifying, and shipping a knowledge note from raw capture to durable verified state.
type: lifecycle-flow
---

# Knowledge Flow

> Triggered when a new note lands in `Inbox/` or `Blog/_daily/`, or when an existing `knowledge/` note needs to be verified and closed out. The flow enforces absorb-first discipline (update existing if 60%+ overlap), enforces the temporal layering rule (raw capture never goes straight to `knowledge/`), and ends with a verified, ship-logged note that feed-curator and retro signals can read. The goal is not to accumulate notes — it is to have fewer, better notes that the system can actually rely on.

## Trigger

- New note captured to `Inbox/` or appended to `Blog/_daily/`
- Daily distill cron completes and surfaces candidates for `knowledge/`
- User runs `/ship knowledge <note-path>` on an existing draft
- A vault scan surfaces a note as stale, orphan, or superseded

## Phases

### Phase 1 — Capture (raw)

- **What happens**: Raw material lands in `Inbox/` as a new file, or in `Blog/_daily/` as an inline section. No classification, no wiki-links, no forced taxonomy. Write fast, write loose.
- **Skills used**: `pandastack:daily` (for same-day daily note capture); direct file creation in `Inbox/` for longer pieces
- **Output**: Raw file in `Inbox/` or section in today's daily note with no `verified` field

### Phase 2 — Vault dedup check

- **What happens**: Before promoting raw material to `knowledge/`, check whether a matching note already exists. If 60%+ overlap, absorb into the existing note rather than creating a new one.
- **Skills used**: `rg -l "<topic>" knowledge/` and direct file inspection
- **Output**: Either a confirmed "no match, create new" decision, or a target note path to absorb into

### Phase 3 — Distill

- **What happens**: Daily cron (`daily-distill` agent) pulls candidates from `Inbox/` and recent daily notes, strips noise, extracts the durable core, and writes or appends to `knowledge/` root. Manual trigger is allowed but cron handles the default. New notes go to `knowledge/` root — no pre-classification into subdirectories.
- **Skills used**: `pandastack:deep-research` (for complex research-origin notes that need synthesis before landing); otherwise cron handles directly
- **Output**: New or updated note in `knowledge/` root with minimum frontmatter (`date`, `type`, `source`, `tags`). No `verified` field yet.

### Phase 4 — Human verify

- **What happens**: Panda reads the distilled note, confirms the core claims hold, updates any stale data, and stamps `verified: true` + `last_human_review: <today>`. This is a human action — never automated.
- **Skills used**: None (human read + Edit tool)
- **Output**: Note frontmatter updated with `verified: true` and `last_human_review`

### Phase 5 — Ship

- **What happens**: Close the note's lifecycle. Record where it was used, update source-quality signal, run backflow if triggered (generalizable principle, citation count, work-problem pattern).
- **Skills used**: `pandastack:ship knowledge <path>` (Close → Extract → Backflow)
- **Output**: `Inbox/ship-log/YYYY-MM-DD.md` entry; optional `docs/learnings/` entry; optional feed-curator `source-quality.json` update

### Phase 6 — Lint (on-demand hygiene)

- **What happens**: When you want to clean the vault, run direct file scans for stale notes (verified=true but `last_human_review` older than 6 months — `rg "last_human_review:" knowledge/`), orphan notes (no inbound links — wiki-link grep), and dead `superseded_by` targets (frontmatter check). No dedicated skill or cron.
- **Skills used**: `rg`, `find`, frontmatter parsers (yq / direct grep)
- **Output**: Console output of flagged notes; act on each manually via Edit

## Exit criteria

- Note exists in `knowledge/` root with `verified: true`, `last_human_review` set to today
- Ship log entry written to `Inbox/ship-log/`
- The vault stale-check will not flag this note for at least 6 months

## Anti-patterns

- **Create new note instead of absorbing (60%+ overlap)**: vault sprawl is the primary cause of retrieval noise. Always run `rg` / `find` for the topic before creating.
- **Write directly to `knowledge/` during capture**: raw material needs one distill pass before landing as a durable note. Skipping the temporal layer produces half-formed notes that look verified but aren't.
- **Add wiki-links without verifying backlinks**: `[[slug]]` that points to a renamed or deleted note produces silent dead links. Check backlinks before writing links manually.
- **Set `verified: true` via automation**: verification is a human judgment call. A cron script cannot know if a note's core claims still hold. Automate the flag, lose the signal.
- **Leave raw material in `Inbox/` indefinitely**: `Inbox/` is a capture buffer, not a storage layer. Anything older than 2 distill cycles without a decision (distill or discard) is noise.

## Skill choreography

```
pandastack:daily  (capture to _daily/)
  or
direct file → Inbox/
  |
  v
rg / find  (vault dedup check)
  |
  v
daily-distill cron  (Phase 3, async)
  |
  v
[human verify — Edit frontmatter]
  |
  v
pandastack:ship knowledge <path>
  |── Stage 1: Close (verified, source-quality.json)
  |── Stage 2: Extract (semantic, optional)
  └── Stage 3: Backflow (rules/learnings/memory, optional)
  |
  v
rg / find  (on-demand: stale / orphan / superseded scans)
```
