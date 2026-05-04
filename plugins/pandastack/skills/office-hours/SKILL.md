---
name: office-hours
mode: skill
description: |
  Bring a fuzzy idea to office hours. Model challenges, drills, surfaces unknowns, ends with a written brief. 5-stage internal flow: load context → adversarial grill → premise challenge → alternatives → write brief. 30 min scope.
  Triggers on /office-hours, "I have an idea", "let me think out loud", "stress test this", "office hours". Replaces deprecated `commands/brainstorm.md`.
  Skill metaphor: walk into a professor's office hours with a half-formed thought. Walk out with a brief.
reads:
  - repo: lib/capability-probe.md
  - repo: lib/push-once.md
  - repo: lib/escape-hatch.md
  - repo: lib/stop-rule.md
  - repo: lib/bad-good-calibration.md
  - repo: lib/goal-mapping.md
  - cli: gbq
  - vault: knowledge/**
  - vault: docs/sessions/**
writes:
  - vault: Inbox/office-hours-*.md
  - vault: docs/briefs/*.md
  - cli: stdout
forbids:
  - file: /Users/panda/site/knowledge/work-vault/**
domain: shared
classification: lifecycle-flow
capability_required:
  - agents.md
  - vault
  - gbq      # optional — degrade to rg
  - lib/push-once.md
  - lib/escape-hatch.md
  - lib/stop-rule.md
---

# Office Hours — bring a problem, leave with a brief

> 30-minute structured pressure cooker. You walk in with a fuzzy idea or a stuck decision. Model challenges premises, drills unknowns, forces alternatives, and writes the brief that captures what you actually decided.

## When to invoke

- Fuzzy idea you want to stress-test before committing
- Decision you've been circling — need pressure to ground it
- Pre-PRD scoping where structured grill would be too narrow
- "I think I want X but I'm not sure" → office-hours
- Replacement for `/brainstorm` (deprecated)

## When to skip

- Bug fix or typo (just do it)
- Decision already made and clear (use `/sprint` to execute)
- Pure technical execution question (use `/eng-lead` skill or `/grill`)
- Already wrote a brief, just want plan critique → use `/boardroom`

## Differs from `/grill`

- `/grill` is the atomic 5-10 min adversarial pressure tool used mid-session
- `/office-hours` is the 30 min structured flow: load context → grill → premise challenge → alternatives → brief output

`/grill` is a mid-flight weapon. `/office-hours` is a complete session.

## Stages

### Stage 1: Capability probe + load context

@../../lib/capability-probe.md

Then:
1. gbq the topic — surface 3-5 prior vault hits
2. Read `lib/goal-mapping.md` Step 1: identify L1 / L2 / L3 goals from memory
3. State: "Today's office hours topic is: {topic}. Prior context: {summary}. Active goals: {L1/L2/L3}."
4. Print: `Stage 1 done. Proceeding to Stage 2 — premise challenge. [press any key or write 'skip' to jump to Stage 3]`

### Stage 2: Premise challenge (adversarial)

The point is to surface **unknown unknowns** by interrogating one angle at a time. Inspired by gstack `/office-hours` rehearsed-answer pattern.

Drill across these axes (search space, not checklist):

1. **Existence** — does this already exist? what's the status quo?
2. **Premise** — what assumption are you making that you haven't tested?
3. **Counterfactual** — what happens if you don't do this?
4. **Stakeholders** — who's affected? do they know?
5. **Reversibility** — two-way door or one-way door?

Protocol:

- ONE question at a time. Wait for answer.
- @../../lib/push-once.md — when first reply is rehearsed, print 5-pattern menu, user picks, model uses literal prompt as next message.
- @../../lib/escape-hatch.md — if user signals enough, 2-strike protocol kicks in.
- After each answer, pick next question based on what answer revealed (not from checklist).
- Stop conditions: 7+ questions OR 3 consecutive non-revealing answers OR escape-hatch.

@../../lib/bad-good-calibration.md — apply 4 BAD/GOOD pairs to your pushback prompts.

### Stage 3: Alternatives (forced)

@../../lib/stop-rule.md

Generate **2-3 named approaches**:

- One **minimal viable** (fewest files, ships fastest)
- One **ideal architecture** (best long-term trajectory)
- Optional **creative / lateral** (unexpected framing)

```
APPROACH A: {name}
  Summary: {1-2 sentences}
  Effort: {S/M/L}
  Pros: {bullets}
  Cons: {bullets}

APPROACH B: {name}
  ...

APPROACH C: {name}  [optional]
  ...
```

**RECOMMENDATION**: {A/B/C} because {one-line reason mapped to dominant goal layer}.

**Per-approach gate** (do not batch):

```
APPROACH A: Apply to brief? [Add / Defer / Reject]
APPROACH B: Apply to brief? [Add / Defer / Reject]
APPROACH C: Apply to brief? [Add / Defer / Reject]
```

STOP. Wait for user response on each. No silent continuation.

### Stage 4: Premise refresh

After alternatives picked, refresh the premise:

```
Original premise: {what was assumed at Stage 1}
Surfaced premises (from Stage 2): {what got discovered}
Revised premise: {what holds after grilling}
Premise still load-bearing: [Y/N/partial]
```

If revised premise is significantly different from original, surface this — user may want to redo Stage 3 with the new framing.

### Stage 5: Output brief

Write to `docs/briefs/{YYYY-MM-DD}-{slug}.md`:

```markdown
---
date: {YYYY-MM-DD}
type: brief
source: office-hours
topic: {topic}
tags: [brief, office-hours]
---

# {Topic}

## Problem

{user problem, not feature description}

## Original premise

{what user walked in with}

## Revised premise (after grill)

{what holds after Stage 2}

## Alternatives considered

- A: {name} — {summary} — [Add / Defer / Reject]
- B: {name} — {summary} — [Add / Defer / Reject]
- C: {name} — {summary} — [Add / Defer / Reject]

## Chosen approach

{A/B/C} — {one-line rationale}

## Scope

In: {what's included}
Out: {what's explicitly excluded}

## Gotchas surfaced

{from Stage 1 past cases}

## Gate Log

- Stage 1 (load context): {summary}
- Stage 2 (premise challenge): {n questions, n pushes via push-once, escape-hatch fired? Y/N}
- Stage 3 (alternatives): chose {A/B/C}
- Stage 4 (premise refresh): {premise still load-bearing}
- Stage 5 (output): brief saved to {path}

## OPEN_QUESTIONS

{any axes not addressed due to escape-hatch or user defer}
```

Print path. Suggest next: `/sprint <topic>` to execute, `/boardroom <brief-path>` for cross-functional critique, or park as memo.

## Anti-patterns

- ❌ Skipping Stage 1 ("I know the context, let's drill") — past-case lookup catches duplicate work
- ❌ Generating alternatives in Stage 2 (mixed mode) — keep adversarial pure, alternatives in Stage 3
- ❌ Writing brief in Stage 3 — brief comes after alternatives chosen, not before
- ❌ Re-running office-hours on a topic just office-hours'd — user is procrastinating, push to /sprint
- ❌ Letting Stage 2 run beyond 7 questions — escape-hatch enforces breadth ceiling

## Origin

- gstack `/office-hours` (943 lines) — flagship inspiration
- pandastack 2026-05-04 — distilled to ~250 lines + 5 lib refs (push-once / escape-hatch / stop-rule / bad-good-calibration / goal-mapping)
- Replaces `commands/brainstorm.md` (deleted v1.1)
