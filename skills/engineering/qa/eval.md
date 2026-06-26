---
type: skill-eval
skill: qa
bucket: engineering
evaluated_skill_hash: ce845dfa5c91c52bff57bcd52239b28bbebe993d
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — qa

**Verdict: WEAK.** Leading virtue is a genuinely repeatable test-planning loop — the three-round functional → adversarial → coverage pass forces the same disciplined path every run. But six axes come in weak: an unbound `{learnings_dir}` that makes Step 1 run differently per project, a description with no NOT-clause (trigger collision), a conditional Step 5 with no done-state, the same dangling `{learnings_dir}` pointer at the hierarchy level, one no-op narration line, and a 117-line body over budget.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | weak | L25 — the forced "Re-read Round 1. What did you miss?" adversarial pass makes the *planning* process reproducible. But L14's `{learnings_dir}` is used as a search path with no step binding it (Step 1 reads the pstack config at L13 yet never states "resolve `{learnings_dir}` from it"), so Step 1's context-load runs differently or stalls per project — the same unbound-variable defect the sibling `review` eval scores as a predictability hole. Process is not the same every run |
| Description / invocation | weak | L4 — front-loads "Browser-based QA" well, but the line restates body identity and carries no NOT-clause, so it collides with `verify` / `review` / `testing` on overlapping triggers |
| Completion criteria | weak | L113 — "If a UI pattern... was discovered, write a learning" is conditional with no checkable done-state; premature-completion bait at the final step |
| Information hierarchy | weak | L14 — `{learnings_dir}` / `type: pitfall` is a dangling context pointer; the format the Step 1 search depends on is never linked or inlined |
| Leading words | pass | L25 — "Adversarial" anchors a whole pretrained region of QA behaviour in one word; "fan out" (L43) and "rigor" (L69) do the same elsewhere |
| Pruning | weak | L45 — process narration on per-group model selection ("a trivial smoke check and a group combining... are not the same load"; "don't pin a fixed mapping") restates a no-op the agent already does by default |
| Granularity | pass | L41-54 — the parallel-sub-agent split earns its load via independent reach (isolated `--session` browser per group) and anti-premature-completion (step budget + STEP_SKIP on cutoff) |
| pandastack conformance | weak | L117 — body is 117 lines, past the ~<80-line budget with no length-earning reason. Frontmatter itself is valid: SKILL-FRONTMATTER.md requires only `name`+`description` (both present, `name`=folder); hot/cold dispatch does not apply (no large reference is read hot). Length is the conformance miss |

## Why it's good
The skill's spine is its verification ladder (L69-74): four checks ranked by rigor with screenshot-on-failure ranked weakest, which structurally pushes the agent toward deterministic `eval` evidence over screenshots. The structured markers (`STEP_PASS|STEP_FAIL|STEP_SKIP`, L60-64) and the bug-report format (L86-94) make every test outcome machine-checkable and greppable, so completion of Step 3 is unambiguous. The three-round plan (functional → adversarial → coverage-gaps) is the load-bearing predictability lever.

## Top fixes
1. L14 / L113 — bind `{learnings_dir}` once at Step 1 ("resolve from the pstack config read above; default `docs/learnings`") so Step 1's search is reproducible, then point it at the existing `lib/learning-format.md` for the `type: pitfall` shape. AND give Step 5 a checkable criterion (learning written to `{learnings_dir}` with `type: pitfall`, or an explicit "no learning warranted"). The unbound variable is one dead-end hit at intake (predictability) and at close (completion).
2. L4 — trim the body-identity sentence and add a NOT-clause to the description ("NOT for non-UI verification — use `verify`; NOT for code-diff review — use `review`") to stop trigger collision with `verify` / `review` / `testing`.
3. L45 / overall length — delete the per-group model-selection no-op narration and push the screenshot/bug-report mechanics behind a pointer to pull the 117-line body toward the ~<80 budget. Frontmatter is already spec-valid; no `version`/`reads:` change is needed for conformance.

## Behavioral cases
- trigger `QA the new checkout page` -> expected process: Step 1 load config + UI pitfalls + brief, Step 2 three-round plan, Step 3 browser flows emitting STEP_PASS/FAIL markers with deterministic-eval evidence (parallel sub-agents if 3+ groups), Step 4 auto-fix mechanical bugs / ASK on design, Step 5 learning.
- trigger `test this` after a UI change -> expected process: same loop; a small change (1-2 groups) runs tests directly without sub-agents (L54).
- anti-trigger `verify my refactor didn't break the API` -> should NOT fire (no UI surface; routes to `verify`).
- anti-trigger `review my PR before I push` -> should NOT fire (static correctness/security/architecture; routes to `review`, not a live browser flow).
