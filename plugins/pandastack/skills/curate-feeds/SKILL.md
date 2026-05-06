---
name: curate-feeds
aliases: [feed-curator]
description: |
  Pull unprocessed items from feed-server, enrich web articles via defuddle, write obsidian-clipper-style markdown to Inbox/feeds/raw/.
  Implementation ships with this skill at `scripts/curate-feeds.ts` (resolved via `${PANDASTACK_HOME}/skills/curate-feeds/scripts/curate-feeds.ts`). AI does NOT summarize, score P0-P3, or author substance — defuddle extracts, the script writes, Panda triages.

  Trigger on: /curate-feeds, /feed-curator (alias), "fetch feeds", "pull feeds", scheduled cron.
  Skip when: user wants summaries or analysis (use /knowledge after triage instead).
---

# Feed Curator (defuddle-enriched fetch)

Pull unprocessed items from feed-server, run defuddle on each web article URL to extract title / author / published / description / contentMarkdown, write obsidian-clipper-compatible markdown to `Inbox/feeds/raw/<date>/`. Mark processed in feed-server.

## Why thin

The skill body is now a wrapper around `scripts/curate-feeds.ts` shipped inside this skill folder. The script handles JSON parsing, defuddle subprocess, frontmatter rendering, dedup, error fallback. AI is not asked to do any of those steps per item — that produced fragile instruction-following.

If the script breaks or behavior needs to change, edit the script. The skill stays thin.

## Prerequisites

- Feed server daemon (the `feed-server` bun project) running at `${PANDASTACK_FEED_SERVER:-http://localhost:3456}`. Clone separately from the public feed-server repo if you want this skill operational; without the daemon, the script exits early with `0 items`.
- `defuddle` CLI on PATH (`which defuddle`) — `npm install -g defuddle`
- `bun` on PATH (`which bun`) — `curl -fsSL https://bun.sh/install | bash`
- `PANDASTACK_VAULT` env var pointing at your personal vault (script aborts if unset)
- Optional: `PANDASTACK_FEED_SERVER` to override the default daemon URL

## Run

```bash
bun run "${PANDASTACK_HOME}/skills/curate-feeds/scripts/curate-feeds.ts"
```

Default: process up to 100 unprocessed items per run.

Flags:

| Flag | What |
|---|---|
| `--limit N` | Cap items per run (default 100) |
| `--dry` | Don't write files / don't mark processed |
| `--no-defuddle` | Skip defuddle, fall back to RSS description for everything |

## What gets written

For each non-noise, non-duplicate item, one file at `Inbox/feeds/raw/<date>/<slug>.md`:

```markdown
---
title: "..."
source: "<url>"
source_name: "<name from sources.yml>"
source_type: rss | website | twitter | reddit | hackernews | github_releases | youtube | telegram | threads
created: "YYYY-MM-DD"
fetched_at: "ISO8601"
type: feed-raw
origin: ai-fetched
author: "..."          # if defuddle found one
published: "YYYY-MM-DD" # from defuddle or RSS pub_date
site: "..."             # if defuddle's site name differs from source_name
description: "..."      # ≤500 chars
image: "..."            # cover URL if present
word_count: N
language: en | zh | ...
tags: [clippings, <source_type>, <tags from sources.yml>]
---

# <title>

<contentMarkdown from defuddle, or RSS description as fallback>

[Source](<url>)
```

Format intentionally matches obsidian-clipper's default template so files browse the same as Panda's manual web-clipper output.

## Source-type behavior

| source_type | Defuddle? | Body source |
|---|---|---|
| `rss`, `website`, `threads` | yes | defuddle's `contentMarkdown`, fallback to RSS `description` |
| `twitter`, `reddit`, `hackernews`, `github_releases`, `youtube`, `telegram` | no | feed-server's `description` (these aren't articles) |

Defuddle failures (~30% on non-Substack RSS sources, mostly TLDR / aggregator feeds with anti-scraping or SPA pages) silently fall back to RSS description. The summary at end of run reports `defuddle fail: N`.

## Noise filter

Skipped without writing or marking processed:
- Single-word title (length < 20)
- Title or description matching `coupon | promo code | discount code | NN% off | deal`

## Dedup

Slug collision check against existing files in today's `Inbox/feeds/raw/<date>/` directory. feed-server's `processed` flag is the primary cross-day dedup.

## Anti-scope-creep notes

The script intentionally does NOT:
- Score items P0-P3 → Panda scores at triage time
- Summarize content → defuddle preserves original; summary is Panda's job
- Append to daily note → daily note is Panda's capture, not AI's report
- Write to `knowledge/` → AI never authors substance to `knowledge/`
- Download images locally → CDN URLs are stable; saves disk + bandwidth

If any of these feels needed, the request belongs in a different skill (`/knowledge`, `daily-distill` — paused), not here.

## Failure modes

- **All items 0**: feed-server returned empty array. Check `curl http://localhost:3456/items?unprocessed=1 | head`. May mean curate is up to date.
- **Defuddle 30%+ fail rate**: ok for now, fallback covers it. Low priority to investigate per-source.
- **Defuddle 100% fail**: defuddle binary or network broken. Run `defuddle parse https://example.com --md` to check.
- **JSON parse error**: feed-server returned malformed item (rare). Re-run after a few minutes.
