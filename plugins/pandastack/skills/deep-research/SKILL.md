---
name: deep-research
description: |
  Two-layer autonomous research system: planner analyzes vault knowledge gaps,
  researcher executes deep exploration with quality gates.
  Triggers on /deep-research, "overnight research", "deep explore",
  "research loop", "help me explore".
  Args: optional topic focus, "auto" for gap-driven, or "overnight" for
  self-managed loop with stricter quality gates and auto-pause.
user-invocable: true
---

# Deep Research

A vault-aware, quality-gated research system. Two layers:
- **Planner**: scans vault, identifies gaps, produces prioritized research queue
- **Researcher**: executes one topic at a time, with verifier gate (keep/rewrite/discard)

## Stage Contracts

This skill is a multi-phase pipeline. Each phase has an explicit input contract — later phases don't inherit prior context automatically, so each spawn/continuation states what it reads.

### Model routing per phase

| Phase | Model | Why |
|---|---|---|
| 1. Planner (gap analysis) | opus | Vault-wide strategic reasoning |
| 2. Researchers (batch execution) | sonnet | Parallel execution, cost-sensitive; avoid burning Opus on N concurrent tasks |
| 3. Synthesizer (quality gate) | opus | Cross-reference + bridge-note synthesis |
| 4. Planner Review (outer loop) | opus | Strategic rebalancing, domain rotation decisions |
| 5. Report | sonnet | Mechanical aggregation |

Pass `model: <name>` when spawning Agents for each phase.

### Inputs per phase

- **Phase 1 (Planner)**: vault state, daily note, recent git activity (no prior-phase inputs)
- **Phase 2 (Researcher)**: one queue entry from Phase 1c — topic, domain, gap type, search seeds, related notes. Also: prior batch's bridge notes if any (Phase 3e), so researcher can avoid re-discovering the same connection
- **Phase 3 (Synthesizer)**: researcher reports (Phase 2) + their original queue entries (Phase 1c, to check against stated gap type)
- **Phase 4 (Planner Review)**: accumulated batch reports (Phase 3) + remaining queue (Phase 1c)
- **Phase 5 (Report)**: all kept/discarded decisions across Phase 3 runs + synthesizer bridge notes

### User gates

Two user-facing gates use the four-option contract (**approve / edit / reject / skip**):
- **Phase 1c**: queue approval before execution
- **Phase 4 (interactive mode only)**: continue / adjust queue after each review round

Overnight mode skips gates; stricter quality bars (score ≥ 7.5) + pass-rate thresholds serve as the safeguard instead.

## Phase 1: Planner — Vault Gap Analysis

### 1a. Survey current coverage

Run in parallel:

```bash
# File counts per knowledge subdirectory
for dir in tech crypto product-biz us-stock tw-stock Marketing Naval; do
  echo "$dir: $(find knowledge/$dir -name '*.md' -not -name '_index.md' | wc -l | tr -d ' ')"
done
```

```bash
# Recent activity (last 7 days)
git log --since="7 days ago" --name-only --diff-filter=A --pretty=format: -- 'knowledge/' | grep -v '^$' | sed 's|knowledge/||' | cut -d/ -f1 | sort | uniq -c | sort -rn
```

```bash
# Today's daily note — extract mentioned but unexplored topics
cat "Blog/_daily/$(date +%Y-%m-%d).md" 2>/dev/null | head -100
```

### 1b. Identify gaps

For each domain, use `gbq` to assess coverage depth:

```bash
# Example: find what's thin in a domain
gbq "what topics in {domain} have shallow coverage?"
```

Gap signals (check all):
1. **Coverage imbalance** — domains with significantly fewer notes relative to user interest
2. **Stale domains** — no new notes in 7+ days despite active interest
3. **Broken links** — wiki-links in MOCs pointing to non-existent files
4. **Daily note breadcrumbs** — topics mentioned in daily notes but never distilled into knowledge/
5. **Depth vs breadth** — domains with many surface-level notes but no deep-dive analysis

### 1c. Produce research queue

Output a prioritized list of 6-12 research tasks. Each task must specify:

```markdown
## Research Queue

### Task 1: [topic title]
- **Domain**: tech | crypto | product-biz | us-stock | tw-stock | Marketing | Naval
- **Gap type**: coverage | depth | staleness | breadcrumb
- **Why**: [1 sentence — what's missing and why it matters to the user]
- **Search seeds**: [2-3 specific search queries to start with]
- **Quality bar**: [domain-specific — see Phase 3 verifier criteria]
- **Related vault notes**: [[note-1]], [[note-2]]
```

**Prioritization rules:**
- P0: topics the user mentioned today or this week but hasn't explored
- P1: domains with coverage imbalance (tw-stock 45 notes vs tech 551)
- P2: depth gaps in well-covered domains (surface note exists, deep analysis doesn't)
- P3: adjacent topics that connect multiple existing notes

**Present the queue to the user for approval before proceeding.**
If running overnight (user sleeping), proceed autonomously but apply stricter quality bar.

## Phase 2: Parallel Research — Batch Execution

Group the research queue into **batches of 2-3 tasks from different domains**. Each batch runs in parallel using the Agent tool. Same-domain tasks go in different batches to avoid source overlap.

### Batch construction

```
Round 1: [crypto task, tech task, product-biz task]  ← 3 parallel
Round 2: [us-stock task, crypto task, Naval task]     ← 3 parallel
...
```

### Spawn parallel researchers

For each batch, spawn 2-3 researcher agents **in a single message** so they run concurrently:

```
Agent({
  description: "Research: {topic title}",
  prompt: "You are a vault-aware researcher. Your task:

TOPIC: {topic title}
DOMAIN: {domain}
GAP TYPE: {gap type}
SEARCH SEEDS: {search seeds}
RELATED VAULT NOTES: {list}

## Instructions

1. SOURCE ACQUISITION — find 3-5 high-quality sources:
   - WebSearch for recent (2026) substantive articles
   - bird search '{topic}' for X/Twitter threads with real data
   - defuddle parse '<url>' --md for full content extraction
   - SKIP: listicles, news summaries, paywalled, >6 months old, overlapping with vault

2. NOVELTY CHECK — run: gbq '{topic keywords}'
   Read top 3 results. If >70% overlap:
   - Merge: enhance existing note instead
   - Angle shift: find genuinely different angle
   - Skip: report 'SKIP: {reason}' and stop

3. WRITE THE NOTE to: knowledge/{subdirectory}/{kebab-case-title}.md
   - Frontmatter: date, tags (3-5), sources (URLs)
   - Length: 800-1500 words substantive analysis
   - Wiki-links: 2+ connections to existing vault notes
   - Style: structured, data-rich, opinionated with specific numbers
   - Language: Chinese content, English technical terms
   - HV structure (if topic has evolution history AND comparables):
     纵向 (origin → inflection → current) → 横向 (position among alternatives) → 交汇 (new insight neither axis alone reveals)
   - Skip HV for how-to guides, mental models, data-point notes

4. UPDATE MOC — read knowledge/{subdirectory}/_index.md, add note in semantically closest section

5. MECHANICAL EVAL — run: bash scripts/eval-distill.sh knowledge/{subdirectory}/{filename}.md
   Fix any failures before returning.

6. REPORT BACK — return exactly:
   - FILE: {path}
   - SCORE_SELF: {your honest 1-10 estimate}
   - SOURCES: {urls used}
   - KEY_INSIGHT: {one sentence}
   - STATUS: WRITTEN | MERGED | SKIPPED
   - SKIP_REASON: {if skipped}"
})
```

**All researchers in one batch launch in the same message.** Wait for all to complete before proceeding to Phase 3.

## Phase 3: Synthesizer — Cross-Reference Quality Gate

After each batch completes, the main session acts as **Synthesizer**. This is the quality layer that was missing in sequential mode.

### 3a. Collect batch results

Gather all researcher reports. For each note with STATUS: WRITTEN or MERGED:

### 3b. Cross-reference check

```bash
# Check if two notes in the same batch overlap
gbq "{note A title}"
gbq "{note B title}"
```

If two notes in the same batch cover >50% similar ground:
- Keep the higher-quality one
- Merge unique insights from the other into it
- Discard the weaker one

### 3c. Scoring rubric

| Criterion | Weight | 7+ (keep) | 4-6 (rewrite) | 1-3 (discard) |
|-----------|--------|-----------|----------------|----------------|
| **Data density** | 30% | 5+ specific numbers, named sources | 2-4 numbers | Vague claims, no data |
| **Novelty** | 25% | <30% overlap with vault | 30-60% overlap | >60% overlap |
| **Source quality** | 20% | Primary research, official data | Industry analysis | News summary, listicle |
| **Actionability** | 15% | Clear frameworks, tickers, decisions | Some implications | Pure description |
| **Connectivity** | 10% | 3+ meaningful wiki-links | 2 wiki-links | Forced/weak links |

### Domain-specific modifiers

- **us-stock / tw-stock**: must have specific tickers, price levels, or catalyst dates
- **crypto / quant**: must have protocol-level mechanics or quantitative data
- **product-biz**: must have named company cases with revenue/growth numbers
- **tech**: must have architecture details, benchmarks, or adoption metrics
- **Naval / Marketing**: must connect to user's existing mental model framework

### 3d. Gate decisions

- **Score >= 7.0** (interactive) / **>= 7.5** (overnight): Keep.
- **Score 4.0-6.9**: Rewrite once with specific feedback. Re-evaluate. If still below threshold, discard.
- **Score < 4.0**: Discard immediately. Delete the file. Log reason.

### 3e. Synthesizer insight (the value-add)

After scoring all notes in the batch, ask:

> "Do these notes, combined with existing vault content, reveal a connection that no single note captures?"

If yes, write a **bridge note** — a short (300-500 word) note that connects the dots across the batch. This is the compound knowledge that sequential research misses.

### 3f. Verification

```bash
gbq "{note title keywords}"
```
Confirm each kept note adds genuine value beyond existing coverage.

## Phase 4: Outer Loop — Planner Review

After every 2 batches (6-9 tasks attempted), the planner reviews:

1. **Batch success rate**: how many notes kept vs discarded? If < 50%, adjust search strategy.
2. **Domain balance**: are all domains getting coverage, or is one dominating?
3. **Source quality trend**: are later batches using worse sources? (fatigue signal)
4. **Bridge notes produced**: are synthesizer insights connecting to existing vault? If 0 bridges in 2 batches, the topics may be too isolated.
5. **Remaining queue**: reprioritize or add new tasks based on what was learned.

### Interactive mode
- Present review summary to user, ask whether to continue or adjust queue.

### Overnight mode (self-managed loop)
- **Continue**: pass rate >= 40% → generate next batch of 2-3 tasks
- **Rotate**: single domain > 50% of output → deprioritize that domain, boost others
- **Pivot**: pass rate < 40% for 2 consecutive reviews → diagnose why (source quality? domain saturation? search strategy?), switch domains or angles, try a fresh batch
- **Pivot**: 3 consecutive discards → rotate to a different domain, shift from breadth to depth (or vice versa), try merging/enhancing existing notes instead of creating new ones
- **Time-bound**: if user specifies "until {time}", keep running until that time. No fixed round cap. Quality gates are the safeguard.
- **Default cap** (no time specified): max 6 reviews (18-27 tasks, vs old sequential 48). Fewer tasks but higher quality per task.
- Between reviews, re-run Phase 1b gap analysis to catch shifted priorities

## Phase 5: Report

At the end of the session (or when user returns), produce a summary:

```markdown
## Deep Research Report — {date}

### Stats
- Tasks attempted: N | Kept: N | Rewritten: N | Discarded: N
- Pass rate: X%
- Domains covered: {list with counts}

### Notes Added
| Note | Domain | Score | Key Insight |
|------|--------|-------|-------------|
| [[note-name]] | tech | 8.2 | one-line |

### Discarded (with reasons)
- {topic} — {reason: low novelty / weak sources / failed rewrite}

### Gaps Remaining
- {topics that were queued but not reached, or new gaps discovered}
```

Write this to the daily note under `## Deep Research Report`.

### Sync vault index

After writing the report, sync the vault so new notes are searchable:

```bash
gbrain sync
```

This must run after every deep-research session, interactive or overnight. Forgetting this step makes new notes invisible to `gbq` search.

**Discipline (mirrors `/done` skill — see `Inbox/proposal-pandastack-done-skill-sync-discipline-2026-05-03.md`):** Run `gbrain sync` in the foreground. Never background it. Never SIGKILL a running gbrain process — under PGLite this corrupts `~/.gbrain/brain.pglite/`; under Postgres it is less catastrophic but still unsafe. If sync hangs, send SIGTERM and wait at least 30s for graceful exit before escalating.

## Usage Modes

### Interactive (user present)
```
/deep-research              # auto gap analysis + queue approval
/deep-research crypto       # focus on crypto domain
/deep-research "restaking"  # focus on specific topic
```

### Overnight (user sleeping)
```
/deep-research overnight
/deep-research overnight crypto   # overnight with domain focus
```

Overnight mode runs autonomously with self-managed looping. No `/loop` dependency.

#### Overnight behavior

1. **Planner** generates full queue (12-18 tasks, larger than interactive)
2. **Execute in batches** — each batch = 2-3 parallel researchers
3. After each batch, **Synthesizer** (Phase 3) scores and cross-references
4. After every 2 batches, **Planner Review** (Phase 4) runs automatically:
   - Pass rate >= 40% → continue to next batch
   - Pass rate < 40% for 2 consecutive reviews → diagnose and pivot, don't stop
   - Single domain > 50% of output → force rotate domains in next batch
5. **Stricter quality bar**: score >= 7.5 to keep (vs 7.0 interactive)
6. Between reviews, re-run gap analysis to reprioritize remaining queue
7. On completion, write full report (Phase 5) to daily note

#### Overnight safeguards

- If user specifies "until {time}", keep running until that time — no round cap. Quality gates are the safeguard.
- Default (no time): max 6 reviews (18-27 tasks). Fewer than old sequential (48) but higher quality per task.
- If 3 consecutive tasks are discarded → pivot strategy (switch domain, shift depth/breadth, try merge mode), don't stop
- Log every keep/discard decision to `Blog/_daily/{date}.md` under `## Deep Research Log`
- On unexpected error, stop gracefully — never leave partial notes without frontmatter
- Parallel researchers must not share the same domain in one batch — prevents source collision
