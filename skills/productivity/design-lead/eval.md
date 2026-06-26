---
type: skill-eval
skill: design-lead
bucket: productivity
evaluated_skill_hash: 366d6bd047bae4a6f980958f764450f69da54030
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — design-lead

**Verdict: WEAK.** Leading virtue is a clean, contract-conformant persona frame with strong pretrained leading words ("empty states are features", "if everything is bold, nothing is bold"); it loses points to a triple-stated NOT-list / slop meaning, a duplicated DESIGN.md instruction, soft completion criteria on the early On-Invoke steps, and a full-document hot `@import` of persona-frame that drags in boardroom/dispatch internals the running lens never needs.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L44 — `On Invoke` is a fixed 5-step process the agent walks identically every invocation; output varies, process does not. |
| Description / invocation | weak | L22 — the description's NOT-list (L4) is restated near-verbatim in the body Routing Boundary; axis 2 penalizes body-identity restatement even though the skill-name pointers add real disambiguation. |
| Completion criteria | weak | L46 — step 1 "Identify the user's actual UX problem" carries no done/not-done test; only step 5 (L50, "any axis < 3 → revise") is sharply checkable, the early steps read as postures. |
| Information hierarchy | weak | L16 — `@../../../lib/persona-frame.md` inlines the entire 151-line contract doc hot (dispatch mechanics L50-102, origin notes L147-151) when only the 6-section structure (L39) is relevant; the pointer fires but pulls irrelevant sediment. |
| Leading words | pass | L33 — "If everything is bold, nothing is bold" anchors hierarchy-through-restraint in a pretrained concept; reinforced by "Empty states are features" (L32) and "AI slop" (L35). |
| Pruning | weak | L68 — "Read DESIGN.md if it exists before suggesting new patterns" duplicates On-Invoke step 2 (L47, "Reference 2-3 existing patterns in the codebase / DESIGN.md"); separately the line `"I like it" is not feedback` is verbatim-duplicated at L26 (Soul) and L36 (Iron Law 5), and the slop meaning recurs across L35/L42. |
| Granularity | pass | L20 — the split off the other 4 leads earns its load: a distinct leading word ("Design lens") plus boardroom/sprint reach justify the always-loaded description. |
| pandastack conformance | pass | L2 — `name: design-lead` matches folder, body 59 lines < 80, all three `../../../lib/` refs resolve to repo-root `lib/`; the two hot `@import`s (persona-frame + bad-good-calibration, L16/L62) load ~3.0K tokens and the on-demand quality-rubric (L50) adds ~1.3K, so even all-three ~4.3K stays under the 5K hot/cold dispatch threshold. |

## Why it's good
The skill obeys the `lib/persona-frame.md` 6-section contract exactly (Soul / Iron Laws / Cognitive Models / On Invoke / Anti-patterns + BAD/GOOD), so boardroom can extract it programmatically and the persona stays consistent across edits. Its Iron Laws and Cognitive Models are written as compact, pretrained-anchored leading words rather than vague adjectives, which is the load-bearing predictability win. On-Invoke step 5 binds `lib/quality-rubric.md` at a real generation moment (self-score, any axis < 3 → revise), honouring the rubric's governance contract instead of a pointer-only link.

## Top fixes
1. Collapse the NOT-list duplication: L4 (description), L20-22 (Routing Boundary), and the slop/decisions restatements across L26/L35/L36/L42 carry overlapping boundaries — note `"I like it" is not feedback` is verbatim at L26 and L36. Keep the skill-name pointers in the body, cut the prose that re-says the HOT description and fold the duplicated slop/preferences lines down to one canonical statement.
2. De-duplicate DESIGN.md: L47 (On Invoke step 2) and L68 (Team protocol) both instruct reading DESIGN.md before new patterns. Keep one, delete the other.
3. Sharpen early completion criteria: L46-49 read as postures, not checks. Give step 1 a done-test (e.g. "restate the UX problem in one sentence the user confirms") so it cannot complete prematurely.
4. Scope the persona-frame import: L16 hot-inlines the whole 151-line contract doc. Point at only the 6-section structure block (L39) (or rely on the frontmatter `reads:` declaration plus an on-demand pointer) so dispatch (L50-102) and origin (L147-151) sediment stay cold. Also add `lib/quality-rubric.md` to the `reads:` list (L5-7) since L50 loads it — advisory only, but the audit metadata is currently incomplete.

## Behavioral cases
- trigger `/design-lead the empty and error states on this onboarding flow feel off` -> expected process: run On Invoke L44-50 — restate the real UX problem, cite 2-3 existing patterns / DESIGN.md, reject slop by name, specify a11y inline, then quality-rubric self-score on Originality + Craft before declaring ready.
- trigger `does this screen feel intentional or like AI slop?` -> expected process: fire the slop-detector cognitive model (L42), name the slop pattern, propose the principle-based alternative (L48).
- anti-trigger `which feature should we build first this quarter?` -> should NOT fire (routes to `product-lead` per L22).
- anti-trigger `how should we structure this React component tree?` -> should NOT fire (routes to `eng-lead` per L22).
