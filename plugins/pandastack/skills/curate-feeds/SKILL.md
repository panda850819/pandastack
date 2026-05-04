---
name: curate-feeds
aliases: [feed-curator]
description: |
  Fetch raw feed items from feed-server to Inbox/feeds/raw/ with dedupe and noise filter.
  Does NOT summarize, classify P0-P3, write knowledge notes, or update daily note — those steps are removed (2026-05-01 redesign: AI no longer authors substance into knowledge/).

  Trigger on: /curate-feeds, /feed-curator (alias), "fetch feeds", "pull feeds", scheduled cron.
  Skip when: user wants summaries or analysis (use /knowledge after triage instead).
---

# Feed Curator (raw-fetch only)

Pull unprocessed items from feed-server, write raw markdown to `Inbox/feeds/raw/`, mark processed. **No AI summarization.** Panda triages himself.

## Why this skill is thin

Earlier versions scored items P0-P3, deep-read articles, wrote knowledge notes, and appended digests to the daily note. That generated AI-authored substance into `knowledge/` and polluted Panda's brain layer.

New scope: **fetch-only**. The skill is the pipe; Panda is the editor.

If you want summaries, after fetch run `/knowledge backfill` (structural) or read items individually and use `/knowledge promote` to graduate worthwhile items.

## Prerequisites

- Feed server running at `localhost:3456`
- Personal vault at `<personal-vault>` (resolved from session env)

## Step 1: Fetch unprocessed items

```bash
curl -s http://localhost:3456/items?unprocessed=1
```

Returns JSON array: `id`, `title`, `url`, `description`, `source_type`, `source_name`, `pub_date`, `first_seen_at`.

If empty → report "nothing to process" and stop.
If >100 items → process oldest 100, note remainder for next run.

## Step 2: Filter noise

Skip items matching:
- coupon / promo code / discount code / `% off` / "deal" patterns
- single-word titles
- already-exists path (filename collision in `Inbox/feeds/raw/<date>/`)

No P0-P3 scoring. No "trusted source" promotion. Filter is binary: noise or not.

## Step 3: Write raw items

For each non-noise item:

**Path**: `<personal-vault>/Inbox/feeds/raw/YYYY-MM-DD/{slug}.md`

**Slug**: lowercase, non-alphanumeric → hyphens, max 60 chars.

**Template**:
```markdown
---
date: YYYY-MM-DD
type: feed-raw
source: {url}
source_name: {source_name}
pub_date: {pub_date}
fetched_at: {ISO8601}
origin: ai-fetched
---

# {title}

{description}

[Source]({url})
```

Create date directory if missing. Skip if file already exists (dedup).

**Do NOT**:
- Run `bird read` / `defuddle parse` / `summarize` for full content (Panda triggers per-item if interested)
- Write to `knowledge/`
- Append to daily note
- Write `source-quality.json` signals (knowledge-ship handles signal generation now)

## Step 4: Mark processed

```bash
curl -s -X POST http://localhost:3456/items/processed \
  -H "Content-Type: application/json" \
  -d '{"ids": ["id1", "id2", ...]}'
```

Include all fetched IDs (raw-written and noise-skipped).

## Step 5: Report

```
[feed-curator] fetched N items, wrote M raw, skipped N-M as noise
[feed-curator] Inbox/feeds/raw/YYYY-MM-DD/ now has M new items
[feed-curator] next: Panda triages → /knowledge promote <path> for keepers
```

## Anti-scope-creep notes

If you find yourself wanting to:
- Score items by priority → STOP. Panda scores at triage time.
- Deep-read articles → STOP. Panda triggers per-item.
- Write digest to daily note → STOP. Daily note is Panda's capture, not AI's report.
- Update `knowledge/` notes → STOP. AI never writes substance to `knowledge/`.

If any of these feels needed, the request belongs in a different skill (`/knowledge`, `daily-distill` — which is paused), not here.
