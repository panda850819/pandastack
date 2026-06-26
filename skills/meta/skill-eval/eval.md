---
type: skill-eval
skill: skill-eval
bucket: meta
evaluated_skill_hash: 25e7ef05320a1a1ac1995961905ed25432e3110b
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — skill-eval

**Verdict: WEAK.** Leading virtue: a self-referential evaluator that binds writing-great-skills as its sole criteria source and closes on a machine-checkable completion criterion (eval.md exists + hash stamped + lint passes). But three axes land weak — a synonym-piled description (L4), an optional second-opinion step that pays load while changing little (L29), and a `lib/` ref that does not resolve relative to the skill dir (L13) — and the rubric rule (≥2 weak → WEAK) puts it below SOLID.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L19 — `## Steps` is a fixed ordered process (load criteria → score 8 axes → optional second opinion → write+stamp); every run takes the same path, output varies but process does not. |
| Description / invocation | weak | L4 — model-invoked is the right call, but the trigger list piles five near-synonyms ("eval this skill" / "score this skill" / "is this skill well-written" / "why is this skill good" / "(re)generate a skill's eval") that all name one branch "evaluate a skill"; synonym duplication WGS L30-31 says to collapse. |
| Completion criteria | pass | L35 — closes checkable and exhaustive: `eval.md` exists + every axis has a cited line + `lint-eval-fresh.sh` passes; no premature-completion bait. |
| Information hierarchy | pass | L11 — criteria pushed out to the writing-great-skills scorecard via a fired context pointer ("load its **scorecard** section"); the template kept inline where it is read every run. |
| Leading words | pass | L17 — "fans out" + "hot/cold rule — never score the whole corpus in one hot context" anchor dispatch behaviour in pretrained concepts rather than restating it. |
| Pruning | weak | L29 — Step 3 "Second opinion (optional, for first-class skills)" is the softest tier: "optional" + the fuzzy gate "heavily-used skill" lets the agent skip by default, so the numbered step pays hierarchy load while changing little (near no-op). |
| Granularity | pass | L17 — the `all` fan-out splits by sequence correctly: one sub-agent per skill, honouring the hot/cold rule rather than scoring every skill in one hot context. |
| pandastack conformance | weak | L2 — frontmatter name=folder (skill-eval) ✓, body 74 lines (<80) ✓, no >5K-token hot read ✓, sibling pointer `../writing-great-skills/SKILL.md` (L11) resolves ✓. But the one `lib/` ref the body carries — `lib/quality-rubric.md` (L13) — does NOT resolve relative to this skill's dir (the file lives at repo-root `lib/`, not `skills/meta/skill-eval/lib/`); WGS L81 conformance requires `lib/` refs resolve, so the relative-looking path is a real (if minor) miss. |

## Why it's good
The scope note (L13) and the SSOT pointer (L11) keep this skill from re-inventing axes — it judges construction only and defers all criteria to writing-great-skills, so the two stay in sync by reference, not by copy. The completion criterion (L35) is genuinely exhaustive (file + per-axis citation + lint that recomputes the SKILL.md hash), which structurally defeats the stale-eval failure mode the skill itself names (L81). The Anti-patterns block (L78-81) calls out the exact traps an evaluator is most prone to — rubber-stamping, scoring-the-artifact, uncited verdicts — a self-aware guard most skills lack.

## Top fixes
1. L4 — collapse the five synonym triggers to one branch phrase + the re-gen case (e.g. "eval/score a skill, or regenerate its eval after editing"); the renamed-synonym pile is description duplication that pays context load every turn.
2. L29 — either give Step 3 a hard gate (a named threshold for "first-class"/"heavily-used") or demote it from a numbered Step to an in-skill reference note; an "optional" numbered step invites skip-by-default and reads as a no-op.
3. L31 — "Disagreement on an axis → downgrade to weak" is a reconciliation rule buried inside the skippable Step 3; if that step is skipped the rule is lost. Surface it where scoring happens (L27), not only inside the optional tier.
4. L13 — the scope-note's `lib/quality-rubric.md` reads as a skill-relative path but resolves only at repo-root `lib/`. Either qualify it (`repo-root lib/quality-rubric.md`) or link it so the one `lib/` pointer this skill carries actually resolves, satisfying WGS L81 conformance.

## Behavioral cases
- trigger `/skill-eval ingest` -> expected process: read the writing-great-skills scorecard (8 axes), read `skills/<bucket>/ingest/SKILL.md` whole + its sibling refs, score each axis pass/weak/fail with one `L<n>`, write `skills/<bucket>/ingest/eval.md` from the template, stamp `git hash-object`, verify `lint-eval-fresh.sh ingest` passes (L19-35).
- trigger `/skill-eval all` -> expected process: fan out one sub-agent per skill under `skills/<bucket>/<skill>/`, never score the whole corpus in one hot context (L17).
- anti-trigger `score the brief this skill produced` -> should NOT fire (scoring the artifact, not the SKILL.md construction — routes to `lib/quality-rubric.md`, per the scope note at L13).
- anti-trigger `create a new skill / improve this skill` -> should NOT fire (routes to `skill-creator`, the builder counterpart, L11).
