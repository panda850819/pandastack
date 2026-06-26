---
type: skill-eval
skill: sprint
bucket: doing
evaluated_skill_hash: aa147aa6db544cbc1c217e5357c66a948a82a84a
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — sprint

**Verdict: SOLID.** A genuinely well-engineered lifecycle engine: the four-state terminal contract (SHIPPED/PAUSED/FAILED/ABORTED) gives a hard checkable finish line and stops "didn't ship" from collapsing into "broke" — but it carries real sprawl (346 lines vs the ~80 guideline), a thrice-stated `--delegate codex` gate, a no-op-marked conversational execute path with no done-condition, and a non-standard `mode:` frontmatter key.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L44 — every run resolves to one of four named terminal states with one-way routing (only SHIPPED triggers backflow); Stages 0→6 are an ordered, re-derivable-from-git spine, so the *process* repeats every run |
| Description / invocation | pass | L5 — front-loads "Focused execution session", lists distinct trigger branches (/sprint, "sprint on this", "let's ship X", "focused session") with no synonym padding and a real reach clause (auto-routes to design-lead) |
| Completion criteria | weak | L102 — "execute conversationally as before (this block is a no-op)" leaves the no-plan execute path with no checkable done-condition; conversational Stage 3 never states what "execute is complete" means, inviting premature completion before the review gate |
| Information hierarchy | weak | L151 — the project-specific "Multi-source aggregator dispatch-branch test" checklist (companyos sprints 3/5/6, named handler functions like `createCallToolHandler`) is inlined hot into Stage 3; narrow-applicability reference material sitting on the step ladder instead of behind a context pointer |
| Leading words | pass | L44 — "A sprint has a whistle and a finish line" anchors the whole skill on a pretrained concept; "the main session is the ARCHITECT, not the typist" (L104) carries the execution model cheaply |
| Pruning | weak | L314 — the 13-row "Common Rationalizations" table largely restates the Anti-patterns list (L330) and the deploy-proof rules already at L183/L325; same meaning in 2+ places (duplication + sprawl), and the `--delegate codex` off-by-default/plan-required/≥3-advisory gate is fully re-explained at L67, L117, and references/codex-delegation.md. Body is 346 lines vs the ~80-line guideline |
| Granularity | pass | L62 — modes (--quick/--design/--plan/--continue/--delegate) are branches *within* one skill, and the heavy sub-phases (dojo/grill/review/ship/design-lead) are split into separately-invoked skills; each cut earns one of the two loads |
| pandastack conformance | weak | L3 — `mode: skill` is a non-standard key; SKILL-FRONTMATTER.md names `type:` (not `mode:`) as the optional type field, so the declared type drifts from the spec. Lib refs (L73, L91) and capability_required paths (L36-39) all resolve, but the 346-line body also overshoots the scorecard's ~<80-line budget without clearly earning it |

## Why it's good
The terminal-state contract is the load-bearing virtue: every sprint ends on a checkable state and only SHIPPED triggers backflow (L44, L259), which kills the "is it done?" ambiguity that sinks execution skills. Plan-driven execution derives task status from git rather than a mutable progress field (L97), so a fresh session or Codex handoff re-derives state instead of trusting stale prose. The architect-plus-subagent execution default (L104) and the bounded 3-loop review gate (L177) both encode hard-won discipline as checkable rules, not exhortations.

## Top fixes
1. **L314 (pruning, weak):** fold or cut the 13-row Common Rationalizations table — it duplicates the deploy-proof (L183/L325) and terminal-contract (L259) rules and the Anti-patterns list (L330), and is the single biggest contributor to the 346-line sprawl. Keep the few rows with a non-obvious "Reality" payload; delete the restatements.
2. **L67 / L117 (pruning, weak):** collapse the duplicated `--delegate codex` explanation — the off-by-default / plan-required / ≥3-advisory gate is stated three times (Modes line, Stage 3 block, and references/codex-delegation.md). State the gate once inline, leave a single context pointer to the reference for the batch loop.
3. **L102 (completion, weak):** give the no-plan conversational execute path an explicit checkable done-condition (e.g. "each build unit's `acceptance:` re-verified by the architect — subagent-reported green never trusted") so Stage 3 cannot self-declare complete without a check, matching the rigor of the plan-driven path.
4. **L3 (conformance, weak):** rename `mode: skill` to `type: skill` to match SKILL-FRONTMATTER.md, and re-examine whether the 346-line body earns its length against the ~<80-line budget after fixes 1-2 land.

## Behavioral cases
- trigger `let's ship the rate-limiter fix today` → expected process: open sprint default mode → Stage 0 capability probe → dojo → grill (3-question lite) → architect/subagent execute under eng-lead lens → review gate (≤3 iterations) → Stage 5 deploy-proof + ship-gate computes terminal state → only SHIPPED runs ship/extract/backflow.
- anti-trigger `let me think out loud about whether to build a rate limiter at all` → should NOT fire; pure scoping/ideation with no single concrete topic routes to `/office-hours` (or `/boardroom`), per the When-to-skip clause (L58).
