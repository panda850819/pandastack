---
type: skill-eval
skill: eng-lead
bucket: engineering
evaluated_skill_hash: 9b2e2724666e7f407a5f8e707115fe3f33102cec
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — eng-lead

**Verdict: WEAK.** Dense, well-anchored engineering lens with a stable process, dragged below the line by five weak axes: the same root-cause / 3-strike / minimal-diff concepts restated across Iron Laws + Cognitive Models + Anti-patterns; a full-doc hot `@`-inline of persona-frame that drags in dispatch/boardroom/origin sediment the running lens never needs; a declared-but-unused `escape-hatch` ref; a 94-line over-budget body; and a soft completion gate.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L61 — "On Invoke" fixes the same 4-step process (read learnings → understand → verify → write-learning) every run, reinforced by stable Iron Laws + Cognitive Models. |
| Description / invocation | pass | L4 — front-loads "Engineering lens", lists branches, carries an explicit `/eng-lead` trigger and a NOT-clause routing anti-triggers to ceo/product-lead/design-lead/ops-lead. |
| Completion criteria | weak | L66 — step 4 "If non-obvious pattern discovered: write learning" is a soft conditional gate (what counts as non-obvious is undefined), inviting premature completion vs the checkable steps 1-3; the lens output itself has no done-condition. |
| Information hierarchy | weak | L19 — `@../../../lib/persona-frame.md` hot-inlines the whole 152-line contract doc when only its 6-section structure block (L7-39) is relevant to a running lens; dispatch mechanics (L50-103), boardroom integration (L104-114), and origin notes (L147-152) load as sediment. Pointer fires but pulls irrelevant context (same defect the design-lead eval flagged); only learning-format (L66) uses a clean on-demand pointer. |
| Leading words | weak | L41 — the leading words themselves are strong ("Boil the lake", L17 "Ship fast, break nothing", L50 "Substrate before data", L51 "Harden the harness first"), but root-cause (L37/L47/L72), 3-strike (L38/L49/L73-74), and minimal-diff (L40/L48/L71) are each restated across Iron Laws + Cognitive Models + Anti-patterns instead of collapsed — the SSOT "restatements collapsed" test fails. |
| Pruning | weak | L7 — `reads: lib/escape-hatch.md` is declared but never used in the body (no `@`, no inline pointer) — a no-op/sediment declaration the product/design/ops siblings already dropped; compounded by the root-cause / 3-strike / minimal-diff concepts each living in three sections (L37/L47/L72, L38/L49/L73, L40/L48/L71) rather than one source. |
| Granularity | pass | L55 — "Known bug classes" is downgraded from AGENTS.md to co-locate code-specific lore with this skill only, an independent-reach split that earns its load. |
| pandastack conformance | weak | L19/L82/L86 — body is 94 lines, over the ~80 guideline. The three `@`-inlines (persona-frame 7.2K + bad-good 4.7K + verify-loop 5.1K = 17039 bytes ≈ 4.3K tokens) stay UNDER the 5K-token hot/cold threshold, so no sub-agent dispatch is owed (same call the design-lead/ops-lead/product-lead evals made at ~3K tokens); the real conformance miss is the over-budget body plus the L7 escape-hatch sediment in `reads:`. `name: eng-lead` = folder; all five lib refs resolve. |

## Why it's good
The skill is a high-signal engineering lens: leading words ("boil the lake", "trace the data flow", "substrate before data") anchor a precise behavioral region in few tokens, and the On-Invoke protocol plus seven Iron Laws give the same process every run. The routing boundary (L21-25) is sharp — a positive trigger list plus a same-altitude NOT-list naming the four sibling personas — and the verify-the-test-loop integration (L38-39, L50-51) ports hard-won debugging discipline directly into the persona rather than restating it.

## Top fixes
1. L37/L47/L72 (and L38/L49/L73-74, L40/L48/L71) — collapse the root-cause, 3-strike, and minimal-diff restatements: keep each concept in one section (Iron Laws), and let Cognitive Models / Anti-patterns add only what is genuinely new (e.g. the "4th variant called an escalation" failure mode), not re-paraphrase the law. This also trims the 94-line body toward the ~80 guideline.
2. L7 — drop `lib/escape-hatch.md` from `reads:` (it is never used in the body); align with the product/design/ops siblings that already removed it.
3. L19 — scope the persona-frame hot inline: point at only the 6-section structure block (L7-39) rather than `@`-inlining the whole 152-line doc, so dispatch mechanics, boardroom integration, and origin notes stay cold sediment. (Total reference load ~4.3K tokens is under the 5K hot/cold threshold, so no sub-agent dispatch is required — the fix is scoping, not dispatch.)
4. L66 — sharpen the step-4 completion gate: define "non-obvious pattern" with a checkable test (e.g. "a bug class not already in `docs/learnings/` or this skill's Known bug classes") so it cannot be skipped by judgment.

## Behavioral cases
- trigger `/eng-lead this watcher lifetime has a race` -> expected process: load On-Invoke, read docs/learnings, trace the data flow before any change (Law #1 L37), match "Listener owns lifetime" bug class (L57), verify by a real `--once` smoke run.
- trigger `engineering-review: is this fix verified?` -> expected process: invoke verify-the-test-loop Rule 1 deploy-proof gate, refuse "BUILD SUCCEEDED" as evidence (L39/L75).
- anti-trigger `should we even build this feature this quarter?` -> should NOT fire (routes to ceo for strategy-only scope, L25).
- anti-trigger `the onboarding flow feels clunky` -> should NOT fire (routes to design-lead for interaction shape, L25/L92).
