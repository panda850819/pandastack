---
name: wiki-lint
version: 0.2.0
description: |
  Vault hygiene audit. Surfaces orphans, duplicates, stale, verified-overdue, dead redirects, frontmatter gaps, and AI-authored signal in knowledge/. Report-only to Inbox/wiki-lint-YYYY-MM-DD.md for Panda to triage.

  Trigger on: /wiki-lint, "lint vault", "vault hygiene", scheduled weekly cron.
  Skip when: working on a single note (use /knowledge backfill / cross-ref instead).
tags: [vault, hygiene, weekly, quality]
related_skills: [retro-week, knowledge-ship]
source: manual
---

# Wiki Lint

Scan `knowledge/` for hygiene issues. Report, don't fix.

Run from the vault root (`<personal-vault>`).

## What this skill does NOT do

Active maintenance lives in `/knowledge` subcommands, not here:
- Backfill missing frontmatter → `/knowledge backfill`
- Propose wiki-links → `/knowledge cross-ref`
- Surface contradictions for triage → `/knowledge contradict`

This skill is **passive audit only**. Writes one report file, never edits notes.

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
2. For each, run `gbq "<title or first-line tldr>"`
3. If top hit is a different file with similarity >0.85, flag as candidate pair

```bash
# Recent notes (by git, not mtime — mtime is polluted)
git log --since="14 days ago" --name-only --pretty=format: knowledge/ | \
  grep -E "\.md$" | sort -u > /tmp/wiki-recent.txt
```

For each file in `/tmp/wiki-recent.txt`:
- Read first 30 lines to extract title or first paragraph
- Run `gbq "<query>"`
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

## Phase 8: Authorship Signal (AI-in-knowledge detection)

`knowledge/` is human-authored only (vault `AGENTS.md` § Authorship Model). This phase surfaces notes that LOOK AI-authored so Panda can triage (mv to `Inbox/legacy-knowledge/` or rewrite in own voice).

Heuristic flags (collect counts; don't auto-decide):

```bash
# A. Frontmatter signal: source: <URL> + body < 500 chars (likely AI summary)
# B. Body signal: bullet-heavy (>60% lines start with "-"), no first-person ("我", "I think", "Panda")
# C. Origin field: any explicit `origin: ai-fetched` or `origin: distilled` in knowledge/ → red flag
# D. feed-curator legacy: paths matching old auto-write patterns (knowledge/{ai,crypto,tech,macro,product-biz}/<feed-style-slug>.md)

for f in $(find knowledge -name "*.md" -type f -not -name "_index.md"); do
  flags=""
  body_chars=$(awk 'BEGIN{p=0} /^---$/{c++; if(c==2) p=1; next} p' "$f" | wc -c | tr -d ' ')
  has_url_source=$(grep -m1 '^source: http' "$f" | wc -l | tr -d ' ')
  has_first_person=$(awk 'BEGIN{p=0} /^---$/{c++; if(c==2) p=1; next} p' "$f" | grep -cE '(^|[ 。，])(我|Panda|I think|I believe|in my view)')
  bullet_lines=$(awk 'BEGIN{p=0} /^---$/{c++; if(c==2) p=1; next} p' "$f" | grep -cE '^- ')
  total_lines=$(awk 'BEGIN{p=0} /^---$/{c++; if(c==2) p=1; next} p' "$f" | grep -cE '\S')
  origin=$(grep -m1 '^origin:' "$f" | sed 's/origin: *//; s/"//g' | tr -d ' ')

  [ "$has_url_source" = "1" ] && [ "$body_chars" -lt 500 ] && flags="${flags}A"
  [ "$total_lines" -gt 0 ] && [ "$bullet_lines" -gt 0 ] && \
    awk -v b="$bullet_lines" -v t="$total_lines" -v fp="$has_first_person" \
    'BEGIN { exit !(b/t > 0.6 && fp == 0) }' && flags="${flags}B"
  case "$origin" in
    ai-fetched|distilled|ai-distilled) flags="${flags}C" ;;
  esac

  [ -n "$flags" ] && echo "$f|$flags"
done > /tmp/wiki-authorship.txt

wc -l < /tmp/wiki-authorship.txt
```

Report top 30 flagged notes. **Do not classify; just surface for Panda to look at.** Triage action options (Panda decides per-note):
- mv to `Inbox/legacy-knowledge/<original-path>` (most common for AI-distilled)
- Rewrite in own voice → set `origin: original`
- mv to `_archive/` if obsolete
- Mark `origin: original` if false positive (Panda did write it, just terse)

## Phase 9: Frontmatter Gaps

Surface knowledge/ notes missing required frontmatter (per vault `AGENTS.md` § Frontmatter Schema):

```bash
for f in $(find knowledge -name "*.md" -type f -not -name "_index.md"); do
  missing=""
  for field in date type source tags summary; do
    grep -qE "^${field}:" "$f" || missing="${missing}${field},"
  done
  [ -n "$missing" ] && echo "$f|${missing%,}"
done > /tmp/wiki-frontmatter-gaps.txt

wc -l < /tmp/wiki-frontmatter-gaps.txt
```

Report top 30. Action: `/knowledge backfill <path>` for each (auto-commit OK for `summary:` / `type:`).

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
- **Authorship-flagged (suspected AI in knowledge/)**: N
- **Frontmatter gaps (missing summary/type/etc)**: N

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

## Authorship-flagged (top 30)

`knowledge/` notes that look AI-authored. Flags: A = source URL + short body; B = bullet-heavy, no first-person; C = explicit `origin: ai-fetched|distilled` in knowledge/.

| File | Flags | Suggested action |
|------|-------|------------------|
| ... | A,B | mv to Inbox/legacy-knowledge/ for triage |

## Frontmatter gaps (top 30)

| File | Missing fields | Suggested action |
|------|---------------|------------------|
| ... | summary,type | `/knowledge backfill <path>` |

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
- **If `gbq` is unavailable or broken**, run `gbrain doctor --fast` and retry once. If still broken, do not fail the whole lint: fall back to a lightweight duplicate heuristic using filename/title similarity over recent notes, mark the duplicate section as lower-confidence, and surface the gbq failure in the report header.
- **Clean up temp files** (`/tmp/wiki-*.txt`) when done.
- **Do NOT run `gbrain sync`** from lint — separate concern, not lint's job.
