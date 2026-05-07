---
name: research-flow
description: Lifecycle for structured exploration of unfamiliar territory, from scoping the question through verified knowledge note and connected graph.
type: lifecycle-flow
---

# Research Flow

> Triggered when facing an unfamiliar concept, entering a new domain, or needing prior art before a major decision. The flow is distinct from the knowledge flow: knowledge flow handles material that already exists as raw capture; research flow starts with a question and goes out to find the answer. It enforces brain-first lookup (vault before web), scope-lock before fetch (to prevent rabbit holes), and quality gates on the deep-research pass. The flow ends only when a verified note exists in `knowledge/` and is connected to the existing graph — raw material that stays in `Inbox/` is not a completed research cycle.

## Trigger

- "I don't understand X well enough to decide"
- Entering a new domain where no vault notes exist yet
- Major decision requires prior art or external validation
- `pandastack:grill` surfaces a knowledge gap that needs to be filled before proceeding

## Phases

### Phase 1 — Vault-first lookup

- **What happens**: Before fetching anything external, check whether the vault already has relevant material. This is the brain-first-lookup rule. A vault hit can save the entire research cycle or sharpen the question to a specific gap.
- **Skills used**: `rg -l "<question keywords>" knowledge/`; check `knowledge/<domain>/_index.md` MOCs if they exist for the relevant area
- **Output**: Either "vault has N relevant notes — starting from those" or "vault has no coverage — proceeding to fetch". The question may be refined by what the vault does know.

### Phase 2 — Scope lock

- **What happens**: Lock the research question before fetching. Adversarial questioning to surface the actual question (not the surface-level one). Prevents scope creep from turning a 30-minute lookup into a 3-day rabbit hole.
- **Skills used**: `pandastack:grill` (adversarial mode — default; surfaces hidden constraints and ambiguities in the research question)
- **Output**: A single precise research question or 3-5 sub-questions with explicit out-of-scope boundaries noted

### Phase 3 — Fetch

- **What happens**: Pull raw material from external sources. Use the right tool per source type. Apply the fallback chain (defuddle → agent-browser → WebFetch) only if primary tool fails.
- **Skills used**: `pandastack:curate-feeds` (for finding relevant feed sources and queued items); `defuddle parse <url> --md` for clean markdown from web pages (per `~/.claude/rules/url-routing.md`); `pandastack:summarize` (for YouTube, podcasts, long-form audio); `pandastack:bird` (for X/Twitter threads relevant to the question); `pandastack:deepwiki` (for GitHub repo documentation)
- **Output**: Raw materials accumulated in `Inbox/research/<slug>/` or a staging scratch note, with source URLs recorded

### Phase 4 — Deep research

- **What happens**: Run the two-layer autonomous research system: planner produces a research plan, researcher executes against quality gates. For overnight runs, set explicit auto-pause criteria to prevent runaway token spend. Quality gates: minimum 3 primary sources, at least one contrarian perspective, no single-source claims on core assertions.
- **Skills used**: `pandastack:deep-research` (planner + researcher layers)
- **Output**: Synthesized research document in `Inbox/research/<slug>/synthesis.md` — not yet in `knowledge/`, still raw

### Phase 5 — Distill

- **What happens**: Extract the durable core from the synthesis. Apply absorb-first rule (60%+ overlap with existing note → update existing, don't create new). Write to `knowledge/` root with minimum frontmatter.
- **Skills used**: Direct Edit/Write into `knowledge/<slug>.md`; `rg -l` for dedup check
- **Output**: New or updated note in `knowledge/` root with `date`, `type: knowledge`, `source`, `tags`. No `verified` field yet.

### Phase 6 — Ship

- **What happens**: Close the research cycle. Verify the note, record wiki-links to related notes, update source-quality signal, run backflow if the research surfaced a generalizable principle or work-relevant SOP.
- **Skills used**: `pandastack:ship knowledge <path>` (Close → Extract → Backflow)
- **Output**: `knowledge/` note with `verified: true`, wiki-links to at least one related existing note, ship log entry

## Exit criteria

- `knowledge/` has a new or updated verified note that answers the original scoped question
- At least one wiki-link connects the new note to prior knowledge (graph is not isolated)
- Raw research material in `Inbox/research/<slug>/` either archived or deleted — not left to rot
- If the research was motivated by a decision: a link from the relevant work-vault decision file to this knowledge note

## Anti-patterns

- **Skip vault-first lookup and go straight to web**: brain-first-lookup is the most frequently violated rule. The vault almost always has partial coverage. Skipping it produces duplicate notes and misses the compound effect of connected knowledge.
- **Skip scope lock and start fetching**: open-ended research without a locked question scope is how a 30-minute task becomes an overnight session. Grill produces the question; then fetch.
- **Run deep-research overnight without quality gates or auto-pause**: without gates, the researcher agent will keep fetching until token limit. Set explicit auto-pause thresholds before any overnight run.
- **Leave synthesis in `Inbox/research/` without distilling to `knowledge/`**: raw material that never gets distilled is pure waste. The research cycle is not complete until `knowledge/` has a verified note.
- **Write knowledge note without wiki-links**: an isolated node in the graph cannot be retrieved by relation traversal. Every new note should connect to at least one existing note.

## Skill choreography

```
rg / find  (vault-first lookup — brain-first rule)
  |
  v
pandastack:grill  (scope lock — adversarial mode)
  |
  v
pandastack:curate-feeds
  + defuddle parse <url> --md  (per url-routing rule)
  + pandastack:summarize
  + pandastack:bird
  + pandastack:deepwiki
  (fetch from appropriate sources in parallel)
  |
  v
pandastack:deep-research  (planner + researcher, quality gates)
  |
  v
[distill → knowledge/ root]
  (absorb-first: rg dedup check before creating new note)
  |
  v
pandastack:ship knowledge <path>
  |── Stage 1: Close (verified, wiki-links, source-quality.json)
  |── Stage 2: Extract (optional)
  └── Stage 3: Backflow (optional: rules/SOP/memory)
```
