---
name: ps-learn
description: |
  Search and manage project learnings. Use when asked "what have
  we learned", "show learnings", "search learnings", or
  "did we see this before?"
---

# Learn

## Detect Command

Parse the user's input:

- `/ps-learn` (no arguments) → **Show recent**
- `/ps-learn search <query>` → **Search**
- `/ps-learn stats` → **Stats**
- `/ps-learn prune` → **Prune**

Read pstack config from CLAUDE.md for the learnings directory.

## Show Recent (default)

List the 20 most recent learnings from `{learnings_dir}`, sorted by `last_seen` date.

For each, show: `[type] key (confidence N/10, source, date)`

If no learnings exist: "No learnings yet. As you use /ps-review and /ps-compound, pstack will capture patterns automatically."

## Search

Search `{learnings_dir}` by:
- Grep file content for the query term
- Match frontmatter fields: type, key, files

Present matching learnings with their full content.

## Stats

Count files in `{learnings_dir}` grouped by:

| Metric | Value |
|--------|-------|
| Total learnings | N |
| By type | pattern: N, pitfall: N, architecture: N, preference: N |
| By source | observed: N, inferred: N, user-stated: N |
| Average confidence | N.N |
| Oldest | YYYY-MM-DD |
| Newest | YYYY-MM-DD |
| Stale (confidence < 3) | N |

## Prune

For each learning in `{learnings_dir}`:

1. **Confidence decay**: Calculate effective confidence per `lib/confidence.md`.
2. **Staleness check**: If `files` field exists, check if those files still exist. Flag if deleted.
3. **Low confidence**: If effective confidence < 3, present to user via AskUserQuestion:
   - A) Keep (reset confidence)
   - B) Update (tell me what changed)
   - C) Delete

Never auto-delete. Always ask.
