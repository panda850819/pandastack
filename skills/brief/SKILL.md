---
name: ps-brief
description: |
  Structured requirement gathering. Clarifies what to build before
  building. Use when starting a new feature, or when the user says
  "I want to build...", "let's plan", or "new feature".
  Skip for tasks under 1 hour, bug fixes, or clear scope.
---

# Brief

## When to Skip

- Task is under 1 hour of work
- Scope is already clear (bug fix, typo, config change)
- User says "just do it"

When skipped, the eng agent still searches learnings at review time.

## Gate Points

Steps 3 (Premise Challenge), 3.5 (Assumption Dump), and 4 (Alternatives) are user-facing gates. Use the four-option contract: **approve / edit / reject / skip**. See `lib/gate-contract.md`.

Record gate outcomes in the brief's `## Gate Log` section so `/ps-review` and downstream skills can see what was decided and any edits applied.

## Step 1: Load Context

Read the pstack config from CLAUDE.md to find the learnings directory.

Search `{learnings_dir}` for patterns related to the user's request.
Note any relevant learnings for the product agent.

## Step 2: Clarify

Use the product agent's forcing questions to clarify the request.
Ask ONE AT A TIME. Push until specific. Smart-skip questions
whose answers are already obvious from context.

1. **Demand Reality**: Who needs this? (skip if obvious)
2. **Status Quo**: How is this solved now? (skip if greenfield)
3. **Narrowest Wedge**: What's the smallest useful version?

If the user expresses impatience: ask one more question, then proceed.
If the user pushes back a second time: proceed immediately.

## Step 3: Premise Challenge

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

## Step 3.5: Assumption Dump

After premises are confirmed, brain-dump everything the agent found
and believes. User must confirm before moving to alternatives.

```
PATTERNS FOUND:
- [relevant code patterns, conventions, or prior art discovered]

ASSUMPTIONS:
- [things I'm assuming to be true but haven't verified]

OPEN QUESTIONS:
- [things I don't know and need your input on]
```

This is the checkpoint for human-agent alignment. Surface everything
so the user can do "brain surgery" before implementation direction
is chosen.

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

## Step 4.5: Scope Completeness Check

Before writing the brief, self-check each dimension. Flag any as `NEEDS CLARIFICATION` and return to Step 2 for one more round:

- **Users** — who's affected? any segment missed?
- **Data** — schema changes, migrations, backfill
- **Edge cases** — empty states, failures, concurrency, partial rollouts
- **Deploy & rollback** — how to ship, how to revert if wrong
- **Observability** — logs/metrics/alerts to verify success
- **Docs & handoff** — who else needs to know

Do not proceed until all dimensions are `addressed` or `N/A`. This catches "narrow decomposition" — the failure where the brief scopes too tightly and misses a dimension the implementer then has to guess at.

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
{any relevant past learnings that informed this brief}

## Gate Log
- Premises (Step 3): approve | edit: {what changed} | reject | skip
- Assumption Dump (Step 3.5): approve | edit: {what changed} | reject | skip
- Alternatives (Step 4): chose {A|B|C} — approve | edit: {what changed} | reject | skip
```
