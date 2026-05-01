---
name: feed-curator
description: Triage unprocessed feed items from feed-server, deep-read high-signal content, write knowledge notes to the Obsidian vault. Triggers on "/feed-curator", "curate feeds", "process feeds", "triage feeds", scheduled curation runs (every 4 hours or on-demand).
---

# Feed Curator

Triage unprocessed feed items from feed-server, deep-read high-signal content, write knowledge notes to the Obsidian vault.

## When to Use

- Scheduled curation run (every 4 hours or on-demand)
- User invokes `/feed-curator` or asks to "curate feeds", "process feeds", "triage feeds"

## Prerequisites

- Feed server running at `localhost:3456`
- CLI tools available: `bird`, `defuddle` (at `~/.bun/bin/defuddle`), `summarize`
- Obsidian vault at `<personal-vault>`

## Step 1: Fetch Unprocessed Items

```bash
curl -s http://localhost:3456/items?unprocessed=1
```

Returns JSON array of items with: `id`, `title`, `url`, `description`, `source_type`, `source_name`, `pub_date`, `first_seen_at`.

If empty, report "nothing to process" and stop.

If more than 100 items, process the first 100 (oldest first). Note remaining count for next run.

## Step 2: Score Each Item P0-P3

Score every item against the active topics below. Be selective.

### Scoring Rules

| Level | Meaning | Criteria |
|-------|---------|----------|
| P0 | Urgent/risk | Security alerts, protocol risk, breaking changes affecting user's work |
| P1 | Important | Genuinely affects positions, workflow, or active projects |
| P2 | Learning | Solid insight, worth reading and noting |
| P3 | Eye-opening | Interesting but not actionable now |
| SKIP | Noise | Low-value, duplicate, promotional, casual remarks |

### Active Topics

**High priority (always deep-read when matched):**
- AI agent infrastructure (MCP, tool use, agent SDK, Claude Code)
- LLM application patterns (RAG, fine-tuning, prompt engineering, eval)
- DeFi protocol security, risk, and audits
- AI semiconductor supply chain (TSMC, NVIDIA, AMD, custom silicon)

**Medium priority:**
- AI safety, alignment, and regulation
- DeFi yield strategies and protocol mechanics
- Crypto market structure (MEV, orderflow, market making)
- Developer tooling (editors, CLI, automation, observability)
- Geopolitics, trade policy, and macro trends
- AI-native product design, PLG, and PMF

**Low priority:**
- Open source and infrastructure trends
- Prediction markets and forecasting

### Trusted Sources (auto-promote to at least P2)

- evilcos (SlowMist, crypto security)
- AmandaAskell (Anthropic prompt engineering)
- karpathy (AI fundamentals)
- a16z Crypto (crypto industry signal)
- Simon Willison Blog (AI tooling deep dives)

### SKIP Aggressively

Skip these patterns:
- Casual tweets: remarks, tool mentions without substance, personal updates, retweet bait
- Single-sentence takes with no insight
- Bare stats/odds with a link but no analysis
- Coupon/promo/discount content
- Duplicate coverage of the same event (keep the best source only)

### User Context

COO at Yei Finance (DeFi lending protocol). Heavy Claude Code user. Trades stocks and crypto systematically. Interests: AI agents, crypto/DeFi, product/growth, US stocks/semiconductors.

## Step 3: Write Raw Items to Vault

For ALL items (P0-P3, not SKIP), write a raw file to the vault:

**Path**: `<personal-vault>/Inbox/feeds/raw/YYYY-MM-DD/{slug}.md`

**Slug**: lowercase, non-alphanumeric replaced with hyphens, max 60 chars.

**Template**:
```markdown
---
date: YYYY-MM-DD
source: {source_name}
url: {url}
type: feed-raw
---

# {title}

{description or full text if already fetched}

[Source]({url})
```

Create the date directory if it doesn't exist.
Skip if the file already exists (dedup).
Filter out noise items matching: coupon, promo code, discount code, % off, deal patterns.

## Step 4: Deep-Read P1-P3 Items

For each P1, P2, and P3 item, read the full content using CLI tools:

| Source type | Command |
|-------------|---------|
| Twitter/X | `bird read {url}` |
| Articles/blogs | `~/.bun/bin/defuddle parse "{url}" --md` |
| YouTube | `summarize --extract-only "{url}"` |

Do NOT use browser/Playwright tools. CLI only.

If a tool fails, skip that item's deep-read (still write the raw note with description only).

## Step 5: Write Knowledge Notes

For each P1-P3 item after deep-read, write a knowledge note:

**Path**: `<personal-vault>/knowledge/{area}/{slug}.md`

Area mapping from matched topic:
- AI topics -> `ai/`
- Crypto/DeFi topics -> `crypto/`
- Tech/developer topics -> `tech/`
- Macro/geopolitics -> `macro/`
- Product/design topics -> `product-biz/`

**Before writing**: check for existing notes with similar titles (glob the area directory). If a note already covers this content, skip or append to existing.

**Note template**:
```markdown
---
date: YYYY-MM-DD
source: {url}
area: {area}
tags:
  - {tag1}
  - {tag2}
status: raw
---

# {title}

## Key Insights

- {insight 1 - one sentence, actionable or opinionated}
- {insight 2}

## Summary

{P1: 2-3 paragraphs, P2: 1 paragraph, P3: 2-3 sentences}

## Source

- [{author or publication}]({url})
```

**Depth by priority**:
- P1: 2-3 key insights, 2-3 paragraph summary
- P2: 1-2 key insights, 1 paragraph summary
- P3: 1 key insight, 2-3 sentence summary

Write summaries in Traditional Chinese.

## Step 6: Update Daily Note

Append a digest section to today's daily note at `<personal-vault>/Blog/_daily/YYYY-MM-DD.md`.

If the daily note doesn't exist, create it with frontmatter:
```markdown
---
date: YYYY-MM-DD
status: draft
---

# YYYY-MM-DD Daily Log
```

Append this digest format (insert before `## 想法` section if it exists):

```markdown
## Feed Digest HH:MM

### P1
- [[{slug}|{title}]] -- {author} -- {summary}

### P2
- [[{slug}|{title}]] -- {author} -- {summary}

### P3
- [[{slug}|{title}]] -- {author} -- {summary}
```

## Step 7: Mark Items as Processed

After all items are written, mark them as processed:

```bash
curl -s -X POST http://localhost:3456/items/processed \
  -H "Content-Type: application/json" \
  -d '{"ids": ["id1", "id2", ...]}'
```

Include all item IDs that were scored (P0-P3 and SKIP), not just the ones with notes.

## Step 8: Report

Output a summary:

```
[feed-curator] done — {P1_count} P1, {P2_count} P2, {P3_count} P3, {skip_count} SKIP
[feed-curator] {notes_written} knowledge notes written
[feed-curator] {raw_written} raw items saved to Inbox/feeds/raw/
```
