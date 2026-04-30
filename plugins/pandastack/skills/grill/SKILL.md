---
name: grill
description: |
  Requirement discovery — two modes. Default mode is adversarial: ask ONE question
  at a time, hunting for hidden requirements / unknown unknowns. Structured mode
  (--mode structured) replaces the deprecated /ps-brief: load context, clarify,
  premise-challenge, alternatives, write a brief. Use before drafting a PRD or
  when the user says "grill me on X", "interrogate this idea", "stress test this
  scope", "draft a brief", "structured intake". Skip for tasks where scope is
  already concrete.
---

# Grill

Requirement discovery in two modes. Default is adversarial. Pass `--mode structured` to run the structured-brief flow (replaces the deprecated `/ps-brief`).

## Mode selection

- **Default (adversarial)** — surface unknown unknowns by drilling one angle at a time. Outputs a `Inbox/grill-<slug>-<date>.md` log of confirmed / open / contradictions.
- **`--mode structured`** — run the 5-step structured brief (Load Context → Clarify → Premise Challenge → Alternatives → Write Brief). Outputs `docs/briefs/YYYY-MM-DD-<slug>.md`. Use when scope is fuzzy AND you intend to produce a written brief, not just surface unknowns.

The two modes can chain: start adversarial to discover unknowns, then switch to structured once the unknowns are reduced enough to write a real brief. State the switch out loud so the user knows mode changed.

---

# Default mode (adversarial)

Adversarial intake. Inspired by Matt Pocock's "grill me" prompt — see [[matt-pocock-agent-coding-workflow]].

The point is NOT to fill a structured questionnaire (that's `--mode structured`). The point is to surface **unknown unknowns** by interrogating one angle at a time until the answer surprises you.

## When to use

- Feature scope is fuzzy ("I want a points system" → backfill? retroactive? UI placement? streak rules?)
- Before writing a PRD or feeding `/ps-brief`
- When you suspect hidden constraints (compliance, migration, downstream consumers)
- User explicitly says "grill me", "stress test this", "what am I missing"

## When to skip

- Bug fix or typo
- Scope already documented (existing PRD, ticket with AC)
- User has given clear acceptance criteria
- Time-sensitive (P0 incident — just do it)

## Protocol

**ONE question at a time.** Wait for the answer. Then pick the next question based on what the answer revealed, not from a pre-baked list.

Drill across these axes (not as a checklist — as a search space):

1. **Existence** — does this already exist partially? What's the status quo?
2. **Boundaries** — what's IN scope vs OUT? Where's the line?
3. **Retroactivity** — does this apply to existing data / users / state? Backfill?
4. **Edge cases** — what happens at zero / max / null / concurrent / offline?
5. **Stakeholders** — who else's workflow does this touch? Do they know?
6. **Failure modes** — what's the worst that can happen if this is wrong?
7. **Reversal** — how do we undo this if it turns out bad?
8. **Success signal** — how do you know it worked? What metric / observation?

For each answer:
- If the answer reveals a NEW unknown, drill into that next.
- If the answer is "I haven't thought about that", flag it and move on (don't force decisions in real time).
- If the user gives a confident answer that contradicts something earlier, surface the contradiction explicitly.

## Stopping rule

Stop when one of:
- 3 consecutive answers reveal no new unknowns
- User says "enough", "ship it", or expresses impatience
- 7+ questions answered (avoid bike-shedding)

Do NOT keep asking after the user has signaled "enough" — Pocock's grill is meant to surface hidden requirements, not exhaust the user.

## Output

After grilling ends, produce:

```markdown
## Grill log — <topic> — <date>

### Confirmed
- [point with answer]

### Open / deferred
- [question with "haven't thought" or "decide later" tag]

### Surfaced contradictions
- [if any]

### Recommended next step
- Feed into /ps-brief (if implementation track)
- Feed into PRD draft (if planning track)
- Park as memo (if not ready to act)
```

Save to:
- `Inbox/grill-<slug>-<date>.md` if topic is fresh
- Append to existing brief / PRD if drilling on a known feature

## Anti-patterns

- ❌ Asking 5 questions in one message ("also, and what about, also")
- ❌ Reading off a checklist regardless of context
- ❌ Forcing the user to decide on the spot when they say "I haven't thought about that"
- ❌ Continuing after the user signals enough
- ❌ Pretending to grill when scope is already concrete (just acknowledge and proceed)

## Relationship to other skills

- **`--mode structured` replaces `/ps-brief`** — the structured 5-step brief is now a grill mode, not a separate skill
- **Before `/work-ship` Close stage** — if you're closing a topic and realize scope was never grilled
- **Not a replacement for `/persona-pipeline`** — that's multi-lens review of a complete proposal; grill is upstream

---

# `--mode structured` (was /ps-brief)

Use when the user says "draft a brief", "structured intake", or you need a written brief in `docs/briefs/`.

## When to skip structured mode

- Task is under 1 hour of work
- Scope is already clear (bug fix, typo, config change)
- User says "just do it"

When skipped, downstream skills (e.g. `pandastack:review`) still search learnings at review time.

## Gate Points

Steps 3 (Premise Challenge), 3.5 (Assumption Dump), and 4 (Alternatives) are user-facing gates. Use the four-option contract: **approve / edit / reject / skip**. Record gate outcomes in the brief's `## Gate Log` section.

## Step 1: Load context

Search `docs/learnings/` (or whatever learnings dir is configured in the project's CLAUDE.md) for patterns related to the user's request. Note relevant learnings to inform later steps.

## Step 2: Clarify

Ask ONE AT A TIME. Push until specific. Smart-skip questions whose answers are obvious from context.

1. **Demand reality**: who needs this? (skip if obvious)
2. **Status quo**: how is this solved now? (skip if greenfield)
3. **Narrowest wedge**: what's the smallest useful version?

If user expresses impatience: ask one more question, then proceed. If pushed back a second time: proceed immediately.

## Step 3: Premise challenge

Before solutioning, challenge the premises:

1. Is this the right problem? Could a different framing be simpler?
2. What happens if we do nothing?
3. What existing code already partially solves this?

Present premises for user agreement:

```
PREMISES:
1. [statement] — agree/disagree?
2. [statement] — agree/disagree?
```

## Step 3.5: Assumption dump

After premises are confirmed, brain-dump everything you found and believe. User must confirm before moving to alternatives.

```
PATTERNS FOUND:
- [relevant code patterns, conventions, or prior art discovered]

ASSUMPTIONS:
- [things assumed true but not verified]

OPEN QUESTIONS:
- [things you don't know and need user input on]
```

This is the human-agent alignment checkpoint. Surface everything so the user can correct before implementation direction is chosen.

## Step 4: Alternatives

Generate 2-3 implementation approaches:

- One **minimal viable** (fewest files, ships fastest)
- One **ideal** (best long-term architecture)
- One **creative** (unexpected framing — optional)

```
APPROACH A: {name}
  Summary: {1-2 sentences}
  Effort: {S/M/L}
  Pros: {bullets}
  Cons: {bullets}

APPROACH B: {name}
  ...

RECOMMENDATION: {which and why}
```

Ask user to choose before proceeding.

## Step 4.5: Scope completeness check

Before writing, self-check each dimension. Flag any as `NEEDS CLARIFICATION` and return to Step 2 for one more round:

- **Users** — who's affected? any segment missed?
- **Data** — schema changes, migrations, backfill
- **Edge cases** — empty states, failures, concurrency, partial rollouts
- **Deploy & rollback** — how to ship, how to revert if wrong
- **Observability** — logs/metrics/alerts to verify success
- **Docs & handoff** — who else needs to know

Do not proceed until all dimensions are `addressed` or `N/A`. Catches the "narrow decomposition" failure where the brief scopes too tightly.

## Step 5: Output

Write a brief to `docs/briefs/YYYY-MM-DD-{slug}.md`:

```markdown
## Problem
{user problem, not feature description}

## Success Metric
{one measurable outcome}

## Scope
In: {what's included}
Out: {what's explicitly excluded}

## Approach
{chosen approach with rationale}

## Learnings Applied
{relevant past learnings that informed this brief}

## Gate Log
- Premises (Step 3): approve | edit: {what changed} | reject | skip
- Assumption Dump (Step 3.5): approve | edit: {what changed} | reject | skip
- Alternatives (Step 4): chose {A|B|C} — approve | edit: {what changed} | reject | skip
```
