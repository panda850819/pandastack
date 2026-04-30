---
name: wiki-lint
version: 0.1.0
description: |
  Weekly hygiene scan of knowledge/. Detects orphans (no inbound wiki-links),
  duplicates (similar content under different names), stale notes (old source,
  no recent human review), verified-overdue notes (both flagged-false stale and
  verified-drift), and superseded_by integrity issues (dead redirects, chains).
  Also tracks a ratcheted quality-floor metric (verified:true ratio on notes
  older than 6 months) as a number over time, not a gate.
  Writes a report to Inbox/wiki-lint-YYYY-MM-DD.md for Panda to triage.
  Does NOT auto-edit or delete. Trigger: /wiki-lint, "lint knowledge", "vault hygiene".
tags: [vault, hygiene, weekly, quality]
related_skills: [retro-week]
source: manual
---

# Wiki Lint

Scan `knowledge/` for hygiene issues. Report, don't fix.

Run from the vault root (`<personal-vault>`).

## Phase 1: Inventory

```bash
TOTAL=$(find knowledge -name "*.md" -type f | wc -l | tr -d ' ')
echo "knowledge/ notes: $TOTAL"
echo "subdirs: $(ls -d knowledge/*/ | wc -l | tr -d ' ')"
echo "today: $(date +%Y-%m-%d)"
```

Sanity: if `$TOTAL` is wildly different from last run (stored in last report), flag it.

## Phase 1b: Quality Floor Ratios

Track `verified: true` coverage on notes that have been in the vault ≥6 months. Report as numbers, not blockers. The ratchet is cultural, not enforced — wiki-lint just keeps score.

**Age source: git first-commit date**, not `date:` frontmatter. Rationale: the vault's `date:` field is often set by distill/feed pipelines to the note's creation day or the source's publish date, neither of which reliably answers "how long has this note lived in my vault?" Git first-commit does.

```bash
# Threshold: 6 months ago (macOS `date -v`)
THRESHOLD=$(date -v-6m +%Y-%m-%d)

OLD_TOTAL=0
OLD_VERIFIED=0      # verified: true
OLD_FLAGGED=0       # verified: false
OLD_UNSET=0         # no verified field

for f in $(find knowledge -name "*.md" -type f -not -name "_index.md"); do
  # Primary age signal: git first-commit date (when note entered the vault)
  first_commit=$(git log --reverse --format="%ci" -- "$f" 2>/dev/null | head -1 | cut -d' ' -f1)
  [ -z "$first_commit" ] && continue  # untracked, skip
  # Skip if newer than threshold (string compare is safe for ISO YYYY-MM-DD)
  [[ "$first_commit" > "$THRESHOLD" ]] && continue
  OLD_TOTAL=$((OLD_TOTAL + 1))
  verified=$(grep -m1 '^verified:' "$f" | sed 's/verified: *//; s/"//g' | tr -d ' ')
  case "$verified" in
    true)  OLD_VERIFIED=$((OLD_VERIFIED + 1)) ;;
    false) OLD_FLAGGED=$((OLD_FLAGGED + 1)) ;;
    *)     OLD_UNSET=$((OLD_UNSET + 1)) ;;
  esac
done

# Ratio (guard divide-by-zero)
if [ "$OLD_TOTAL" -gt 0 ]; then
  VERIFIED_RATIO=$(awk -v v="$OLD_VERIFIED" -v t="$OLD_TOTAL" 'BEGIN { printf "%.1f", (v / t) * 100 }')
else
  VERIFIED_RATIO="0.0"
fi

echo "old_total=$OLD_TOTAL old_verified=$OLD_VERIFIED old_flagged=$OLD_FLAGGED old_unset=$OLD_UNSET ratio=${VERIFIED_RATIO}%"
```

**Interpretation:**

- `OLD_TOTAL` = notes with source date older than 6 months (the ones that should have been read at least once).
- `VERIFIED_RATIO` = fraction of those that have `verified: true`.
- Tracked over time in the report. A healthy vault ratchet goes up, not down.
- Do NOT block on this number. It's a score, not a gate. If it drops, surface it; Panda decides whether to invest a review session.

**Delta tracking:** read the last `Inbox/wiki-lint-*.md` summary (by filename date) and diff the Quality Floor block. Include `Δ` in this run's summary.

## Phase 2: Orphan Scan

A note is an orphan if nothing (no MOC `_index.md`, no other note) wiki-links to it by filename stem.

```bash
# Build filename stem list
find knowledge -name "*.md" -type f -not -name "_index.md" | \
  while read f; do basename "$f" .md; done > /tmp/wiki-stems.txt

# For each stem, check if anything references it
while read stem; do
  # Match [[stem]] or [[stem|alias]] or [[stem#heading]]
  count=$(grep -rlE "\[\[${stem}(\||\#|\]\])" knowledge/ --include="*.md" 2>/dev/null | \
    grep -v "/${stem}.md$" | wc -l | tr -d ' ')
  if [ "$count" = "0" ]; then
    echo "$stem"
  fi
done < /tmp/wiki-stems.txt > /tmp/wiki-orphans.txt

wc -l < /tmp/wiki-orphans.txt
```

**Interpretation guide**:
- Orphans are candidates, not verdicts. Some notes are deliberately standalone (agent-only reference, private SOPs).
- Cluster orphans by subdir: a whole subdir of orphans usually means missing MOC entries, not dead notes.
- Top signal: orphan + `verified: false` + age > 60 days → strongest candidate for deletion or merging.

## Phase 3: Duplicate Scan

Full-pairwise vsearch is too expensive for 3000+ notes. Sample strategy:

1. Target: notes modified or created in the last 14 days (likely new, highest chance of dup)
2. For each, run `qmd vsearch "<title or first-line tldr>" -n 5`
3. If top hit is a different file with similarity >0.85, flag as candidate pair

```bash
# Recent notes (by git, not mtime — mtime is polluted)
git log --since="14 days ago" --name-only --pretty=format: knowledge/ | \
  grep -E "\.md$" | sort -u > /tmp/wiki-recent.txt
```

For each file in `/tmp/wiki-recent.txt`:
- Read first 30 lines to extract title or first paragraph
- Run `qmd vsearch "<query>" -n 5`
- Parse output: if any non-self result is >0.85 similar, record as `(file, match, similarity)` tuple
- Cap at 30 samples to keep runtime bounded

## Phase 4: Stale Source

A note is stale if source predates today by >365 days AND no recent human review.

```bash
# Extract frontmatter date + last_human_review per file
for f in $(find knowledge -name "*.md" -type f); do
  date=$(grep -m1 '^date:' "$f" | sed 's/date: *//; s/"//g')
  review=$(grep -m1 '^last_human_review:' "$f" | sed 's/last_human_review: *//; s/"//g')
  echo "$f|$date|$review"
done > /tmp/wiki-dates.txt
```

Filter in agent: today - date > 365 AND (review is "null"/empty OR today - review > 180).

## Phase 5: Verified Overdue

Two sub-checks, both written to `/tmp/wiki-unverified.txt`:

**5a. Flagged-false, stale**: `verified: false` + git last-commit > 30 days → you probably forgot to review.

```bash
for f in $(grep -l '^verified: false' $(find knowledge -name "*.md" -type f) 2>/dev/null); do
  last_commit=$(git log -1 --format="%ci" -- "$f" 2>/dev/null | cut -d' ' -f1)
  echo "5a|$f|$last_commit"
done >> /tmp/wiki-unverified.txt
```

Filter: last_commit older than 30 days.

**5b. Verified but drifting**: `verified: true` + `last_human_review` older than 6 months → the stamp is aging, fact may have drifted.

```bash
for f in $(grep -l '^verified: true' $(find knowledge -name "*.md" -type f) 2>/dev/null); do
  review=$(grep -m1 '^last_human_review:' "$f" | sed 's/last_human_review: *//; s/"//g')
  [ -z "$review" ] && continue
  echo "5b|$f|$review"
done >> /tmp/wiki-unverified.txt
```

Filter in agent: today - review > 180 days.

## Phase 7: Superseded Integrity

`superseded_by: [[target]]` means the note is dormant, replaced by `target`. Check redirects are valid.

```bash
grep -rEn '^superseded_by:\s*\[\[([^]|#]+)' knowledge/ --include="*.md" 2>/dev/null | \
  sed -E 's/^([^:]+):([0-9]+):.*\[\[([^]|#]+).*/\1|\3/' > /tmp/wiki-redirects.txt
```

For each `(source|target)`:
- Missing target file (`knowledge/**/target.md` does not exist) → **dead redirect**
- Target itself has `superseded_by` → **redirect chain** (should be resolved or flagged as such)
- Target is in `_archive/` → **redirects to archive** (acceptable but worth surfacing once)

## Phase 6: Report

Write to `Inbox/wiki-lint-$(date +%Y-%m-%d).md`:

```markdown
---
date: YYYY-MM-DD
type: lint-report
tags: [wiki-lint, hygiene]
---

# Wiki Lint YYYY-MM-DD

## Summary
- Total notes: N (Δ from last run: +X / -Y)
- Orphans: N
- Duplicate candidates: N
- Stale sources: N
- Verified overdue (5a flagged-false stale): N
- Verified overdue (5b verified drift): N
- Superseded integrity issues: N

## Quality Floor (tracked, not gated)
- Notes older than 6 months: N
  - `verified: true`: V  (**X.X%**, Δ from last run: +/-Y.Y pp)
  - `verified: false`: F
  - unset: U
- A healthy ratchet goes up over time. If the ratio drops, surface it but do not block.

## Orphans (top 20)
| File | Age (days) | verified | Subdir | Suggested action |
|------|-----------|----------|--------|------------------|
| ... | ... | false | crypto/ | Link from _index or delete |

## Duplicate candidates (top 10)
| File A | File B | Similarity | Note |
|--------|--------|------------|------|
| ... | ... | 0.91 | Possible merge |

## Stale sources (top 20)
| File | Source date | Last review | Action |
|------|------------|-------------|--------|
| ... | 2024-05-03 | null | Re-check or archive |

## Verified overdue — 5a (top 20)
Flagged `verified: false` but no recent edit.

| File | Last commit | Subdir | Action |
|------|-------------|--------|--------|
| ... | 2026-02-10 | crypto/ | Review and flip verified |

## Verified overdue — 5b (top 20)
`verified: true` but `last_human_review` > 6 months old.

| File | last_human_review | Subdir | Action |
|------|-------------------|--------|--------|
| ... | 2025-08-10 | tech/ | Re-read and refresh last_human_review or demote to false |

## Superseded integrity (top 20)
Dead redirects, redirect chains, and redirects into `_archive/`.

| Source | Target | Issue | Action |
|--------|--------|-------|--------|
| ... | ... | dead target | Fix target or clear `superseded_by` |

## Notes
- Action items are candidates. Panda decides. Lint does not auto-modify.
- Re-run next week.
```

## Rules

- **Report only**. Never edit or delete knowledge notes.
- **Absolute paths** in the report so Panda can Cmd+Click open.
- **Cap each section at 20-30 rows** — long lists don't get read. If more exist, note total count.
- **Report in Traditional Chinese** for the narrative sections (summary, notes); keep tables' file paths as-is.
- **Skip `_index.md`** in orphan scan (MOC files aren't expected to be linked-to).
- **Also skip `_index.md` in duplicate scan / fallback heuristics** — MOC files often look identical by title and create false positives.
- **If `qmd vsearch` is unavailable or broken** (for example Node / `better-sqlite3` ABI mismatch with `ERR_DLOPEN_FAILED` / `NODE_MODULE_VERSION X !== Y`), first try the self-heal in `~/.claude/rules/cli-doctor.md` (rebuild better-sqlite3 in the qmd dev directory if `bun link`-ed) and retry once. If still broken, do not fail the whole lint: fall back to a lightweight duplicate heuristic using filename/title similarity over recent notes, mark the duplicate section as lower-confidence, and surface the qmd failure in the report header.
- **Clean up temp files** (`/tmp/wiki-*.txt`) when done.
- **Do NOT run `qmd update` or `qmd embed`** — separate concern, not lint's job.
