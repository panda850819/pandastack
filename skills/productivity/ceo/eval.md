---
type: skill-eval
skill: ceo
bucket: productivity
evaluated_skill_hash: f500916c09a0dfbbb4be49cc8b9d3cf2baded9b1
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — ceo

**Verdict: SOLID.** Leading virtue: a predictable strategic-lens process anchored in strong pretrained frameworks (Bezos doors, effort gate, framework tension) under a hard recommend-don't-act contract. Costing points: a no-op `reads: lib/escape-hatch.md` that is declared but never `@`-imported and is miscategorized (escape-hatch is an interrogation-skill lib, not a one-shot lens), plus a body reference to `lib/outside-voice-rule.md` (L63) that resolves on disk but is never `@`-imported, so its rule never loads into context at read time.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L45 — "## On Invoke" fixes the same 4-step process every run (pick frameworks → show tension → recommend → predict pushback), independent of the decision's content; this is process-not-output. |
| Description / invocation | pass | L4 — front-loads the leading word "Strategic lens", enumerates one trigger per branch (scope/priority/kill-pivot/door), and carries an explicit NOT-clause routing implementation/code-review/planning to plan/write/eng. |
| Completion criteria | pass | L50 — step 4 "Predict the top 3 pushback questions and draft responses" is bounded and checkable, and the Scope Review block terminates on a GO/ITERATE/KILL gate (L58); steps 1–3 lean on the persona contract rather than a bare checklist, but the run has a checkable terminal. |
| Information hierarchy | pass | L17 — shared structure is pushed behind an `@` context pointer (persona-frame), and the BAD/GOOD pairs likewise (L70), so the hot body stays the persona contract and shared rules load on demand. |
| Leading words | pass | L41 — "Two-way / one-way doors (Bezos)", "Effort gate (compression ratio)" (L42), and "Framework tension (multi-lens)" (L43) anchor whole regions of behaviour in pretrained concepts in minimal tokens. |
| Pruning | weak | L7 — `reads: lib/escape-hatch.md` is a no-op: never `@`-imported in the body, and escape-hatch's own header scopes it to ≥2-question interrogation skills (grill/office-hours/boardroom), not a single-turn lens; L63 separately name-drops `lib/outside-voice-rule.md` (which resolves on disk) without `@`-importing it, so the rule it points at never loads at read time. |
| Granularity | pass | L23 — the Routing Boundary hands implementation/code/debugging/planning/writing to eng-lead/plan/writing-plans/careful/write, so the ceo split earns its always-loaded description by owning a distinct strategic leading word rather than overlapping a sibling. |
| pandastack conformance | weak | L7 — `name: ceo` matches the folder, both `@` imports resolve to root `lib/`, and the two `@`-imported libs total ~3K tokens (under the 5K hot/cold dispatch threshold, so no sub-agent obligation); but the advisory `reads:` list declares escape-hatch.md, which the body never `@`-reads. Sibling single-turn lenses product/ops/design-lead declare only the two libs they consume (eng-lead, a heavier multi-section lens, also carries escape-hatch + others), so ceo's escape-hatch entry misdocuments intent for a single-turn lens. |

## Why it's good
The skill does one thing predictably: a 4-step On-Invoke loop (L45-50) backed by three named, pretrained frameworks the model already thinks with, so the process reproduces across decisions at almost no token cost. The READ-ONLY / user-sovereignty stance (L15, L33) is unambiguous, and the Routing Boundary (L21-23) plus the NOT-clause in the description (L4) keep it from becoming the default personality. Progressive disclosure is real — persona-frame and the BAD/GOOD pairs live behind `@` pointers, holding the body to 73 lines.

## Top fixes
1. L7 — Drop `- repo: lib/escape-hatch.md` from `reads:`. It is never `@`-imported and escape-hatch is scoped to multi-question interrogation skills, not a single-turn lens. Match the single-turn sibling lenses product/ops/design-lead, which declare only persona-frame + bad-good-calibration.
2. L63 — Either import `lib/outside-voice-rule.md` via an `@` pointer (if its rule is load-bearing for the "present, don't incorporate" anti-pattern) or inline the one-line rule and drop the dangling "(See ...)" citation, so the reference resolves at read time instead of pointing the agent at an unloaded file.
3. L52 — Add a one-line gate disambiguating "On Invoke" (general decision) vs "Scope Review" (scope is the topic) so the agent does not have to guess which output template terminates the run.

## Behavioral cases
- trigger `/ceo should we kill this feature or keep iterating?` -> expected process: load persona-frame, pick 2-3 tension-creating frameworks, show agree/disagree, recommend with reasoning, predict top-3 pushback; emit GO/ITERATE/KILL if scope is the frame — never executes the kill, asks first (L37).
- trigger `strategic frame: is this a one-way or two-way door?` -> expected process: reach for the Bezos doors model, classify reversibility, recommend decide-fast vs gather-data per Iron Law 4 (L36).
- anti-trigger `review my auth refactor diff` -> should NOT fire (routes to eng-lead / review per L23); implementation/code-review is explicitly disclaimed.
- anti-trigger `help me plan the sprint tasks` -> should NOT fire (routes to plan/generic planning per L4, L23).
