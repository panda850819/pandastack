---
type: skill-eval
skill: writing-great-skills
bucket: meta
evaluated_skill_hash: 7d5875f5591979e9cef8c88a0066b3867741c5f9
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — writing-great-skills

**Verdict: STRONG.** A self-applying SSOT: it states the root virtue (predictability) once, then every section is a lever that demonstrably serves it, and the scorecard is a faithful checkable condensation of the prose above it.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L12 — root virtue named once ("Predictability … is the root virtue; every lever below serves it"), and the doc itself is structured as that chain of levers, so a reader runs the same diagnostic process every time |
| Description / invocation | weak | L6 — `user-invocable: true` is set, yet L4 keeps a full model-facing description with trigger branches and the L14 binders (`skill-eval` / `skill-creator`) rely on model-reachability; the flag and the description pull opposite ways per the doc's own L20–23 rule |
| Completion criteria | weak | L37 — defines the completion-criterion concept ("checkable … exhaustive") but this is a reference doc with no ordered steps, so it has no completion criterion of its own to check against; correct for the type, but the axis has no positive evidence here |
| Information hierarchy | pass | L41 — progressive disclosure and co-location stated and practiced: bold terms pushed to GLOSSARY.md via a context pointer (L14), keeping the top legible |
| Leading words | pass | L58 — defines leading word then immediately models it ("fast, deterministic, low-overhead" → _tight_), the section enacting its own rule |
| Pruning | pass | L54 — states the no-op test and the ~<80-line discipline, and the body honours it (48 non-blank body lines); each section maps to exactly one scorecard axis with no restated meaning |
| Granularity | pass | L47 — "Granularity spends one of the two loads per cut, so split only when the cut earns it" gives the exact two earn-conditions (independent reach / anti-premature-completion) the granularity axis scores |
| pandastack conformance | pass | L43 — hot/cold dispatch rule stated and bound; frontmatter (L1–8) valid, body under 80 lines, GLOSSARY pointer resolves |

## Why it's good
The doc is the rare reference that obeys the discipline it teaches: it names predictability once (L12) and never restates it, collapses its own restatements into leading words (L58), and pushes every defined term to a single-source GLOSSARY (the context pointer at L14) instead of redefining inline. The scorecard (L70–83) is a true condensation — each of the 8 axes traces back to a named section above it, so skill-eval scores against the same vocabulary the prose builds, and the two never drift.

## Top fixes
1. L6 — resolve the invocation contradiction: this is a reference bound by skill-eval and skill-creator (both at L14), so it must be model-reachable; either drop `user-invocable: true` and keep the model description, or by its own L20–23 rule collapse the description to a human-facing one-liner. It currently claims both modes at once.
2. L37 — the completion-criterion principle is stated but the doc gives no worked checkable/not-checkable example pair; one concrete contrast would make the axis self-demonstrating like the leading-words section (L58) already is.
3. L14 — the artifact-vs-skill boundary ("scores the SKILL.md itself, not the artifact … `lib/quality-rubric.md`") is stated in the body at L14 and again in the description at L4. The description copy is justified (it must be model-facing per L20), so this is acceptable rather than a hard duplication; if pruned, the L4 description clause is the one to trim, not the L14 body anchor.

## Behavioral cases
- trigger `is this skill well-written? / why is this SKILL.md predictable?` → expected process: load the scorecard section (L70–83), score the 8 axes each with one cited line, default-to-weak on uncertainty; pairs with skill-eval as the criteria SSOT.
- anti-trigger `is this PR/report any good?` → should NOT fire; that judges an artifact, routes to `lib/quality-rubric.md` (the SKILL.md draws this boundary explicitly at L14).
