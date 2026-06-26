---
type: skill-eval
skill: skill-creator
bucket: meta
evaluated_skill_hash: 74521fb8f5b89dd6612702b262499fd996398d07
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — skill-creator

**Verdict: WEAK.** Leading virtue is a fully checkable 7-phase pipeline anchored on a refuse-to-build gate and a mandatory hot/cold binary; but three axes land weak (description, pruning, conformance), and the band rule (≥2 weak → WEAK) governs over the strong spine: a ~188-line body at 2x the discipline it itself enforces, a 3x-repeated broken evidence pointer for its own "non-negotiable" rule, and a description that re-pays body identity as context load.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L14-160 — same 7-phase process every run (gap → MECE → hot/cold → inline-vs-extract → write → resolver → verify → self-check); each phase is an ordered action, not output-shaped. |
| Description / invocation | weak | L4 — `user-invocable: true` is right and "Create new pandastack skills" front-loads the leading word, but the "(RESOLVER.md at the repo root — … NOT the brain filing-tree)" aside and the Q0/MECE gloss restate body identity (L30-37) instead of staying triggers + reach clause. |
| Completion criteria | pass | L160 — done-gate is closed and checkable: score every axis, revise any weak one, run `/skill-eval`, `lint-eval-fresh.sh` enforces; L112-128 also ends Phase 6 on a linter that exits non-zero. |
| Information hierarchy | pass | L18 / L30 / L66 — the heavy decision logic is pushed to `lib/` context pointers (decision-tree, trigger-first) loaded on demand, while the hot/cold ASCII tree (L41-60) is co-located inline because every branch needs it. |
| Leading words | pass | L62 "non-negotiable", L26 "smallest durable change", L177 "MECE violation" — each anchors a region of behaviour in a pretrained/repo-shared concept in few tokens. |
| Pruning | weak | L62, L179, L188 — the same `learnings/patterns/long-session-evals` evidence pointer is repeated three times AND does not resolve (no `learnings/` dir; the real evidence is `evals/2026-06-26-skill-quality-baseline.md`); a non-resolving citation triplicated is sediment, not single-source-of-truth. |
| Granularity | pass | L64 (3.5 inline-vs-extract) and L136 (6.5 near-neighbor route check) — each `.5` half-step earns its split as an anti-premature-completion guard wedged between the steps that tempt rushing, not gratuitous fragmentation. |
| pandastack conformance | weak | L91/L182 — the skill polices the ~<80-line and one-off-pruning discipline on others while its own body runs 188 lines (L9-188); frontmatter is valid (name=folder=skill-creator) and every other cited `lib/`/`../` ref resolves, but the body is 2x the budget it enforces and the lone broken pointer is the long-session-evals evidence path (L62/L179/L188). |

## Why it's good
The load-bearing strength is sequencing: Q0 refuse-to-build (L30-33) runs upstream of the overlap walk so the cheapest non-skill outcome is decided first, the hot/cold dispatch is a mandatory diagrammed binary branch (L41-60), and Phase 7 binds the skill back to the writing-great-skills scorecard at the generation moment (L158-160) so the author steers toward the axes before declaring done. Verification is real, not aspirational — an inline frontmatter linter that exits non-zero (L112-128) plus named lint scripts (L173). The near-neighbor route check (L136-156) is a genuinely considered anti-route-confusion guard, sized correctly for a solo repo.

## Top fixes
1. L62/L179/L188 — fix the broken `learnings/patterns/long-session-evals` pointer (repoint to the actual evidence at `evals/2026-06-26-skill-quality-baseline.md` or `docs/learnings/`) and cite it once, not three times. A skill citing missing evidence for its single "non-negotiable" rule erodes that rule each time the pointer is followed.
2. L9-188 — the body runs 188 lines against the ~<80-line discipline the skill itself enforces (L91, L182); push the Phase 6 verification block (L103-134) and Phase 6.5 procedure (L136-156) behind a `lib/`/`references/` context pointer to bring the hot body under budget. This is the weak axis most directly in the skill's own control and the cheapest WEAK→SOLID lever.
3. L4 — prune the description to triggers + the "NOT the brain filing-tree RESOLVER.md" reach clause; the RESOLVER aside and the Q0/MECE/hot-cold glosses are body identity (L30-37) re-paid as context load every turn.

## Behavioral cases
- trigger `create a new pandastack skill for X` -> expected process: Phase 1 gap → Phase 2 Q0 refuse-to-build + RESOLVER MECE walk → Phase 3 hot/cold branch → write SKILL.md to the frontmatter contract → RESOLVER row + manifest → verify → scorecard self-check + `/skill-eval`.
- trigger `improve this skill` -> expected process: same pipeline re-entered at the MECE/hot-cold re-check, ending on Phase 6.5 near-neighbor route check + Phase 7 self-check.
- anti-trigger `score this skill / is this skill well-written` -> should NOT fire (routes to `skill-eval`, the evaluator counterpart that writes `eval.md`).
- anti-trigger `should this be a brain page instead` with no build intent -> Q0 may answer "not a skill"; pure knowledge-filing routes to a brain/repo-architecture decision, not skill-creator construction.
