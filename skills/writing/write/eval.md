---
type: skill-eval
skill: write
bucket: writing
evaluated_skill_hash: f32bd460ef4ce1d173711088137409cb24a2a607
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — write

**Verdict: WEAK.** Leading virtue is airtight anti-ghostwriting predictability — every mode pins a checkable self-check that aborts on drift — but it is bought with a ~383-line body (5x the discipline), a hot/cold dispatch violation (Edit loads the ~8K-token article-patterns.md hot, no sub-agent), and the slop conditional-ref list duplicated in two places.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L42 — mode-selection table maps each user signal to a fixed route, and every mode runs the same numbered process every invocation. |
| Description / invocation | weak | L13 — Routing Boundary restates the L4 description's identity (canonical writing assistant + the same NOT-clauses at L16-17), body-identity the description rule says to cut. |
| Completion criteria | pass | L135 — "if you've written more than 3 consecutive sentences of new prose outside a `→` annotation… Stop and convert" is checkable and anti-premature-completion; mirrored per mode (L94, L177, L195, L284). |
| Information hierarchy | pass | L104 — conditional-reference trigger table pushes zh-slop bodies behind context pointers, loaded only when a signal fires (progressive disclosure). |
| Leading words | pass | L26 — "sparring partner, structure coach, and slop detector" anchors the whole skill in three pretrained roles; "ghostwriter" (L52), "idea gate" (L226) reused as behavior anchors. |
| Pruning | weak | L355 — the conditional zh-ref list (slop-zh-translation / report-tone / residue / prose-zh-structure) is a second copy of the L108-111 Edit-mode trigger table; same meaning in two places (duplication). Plus two inline origin tails (L224, L301 "Source: Shann Holmberg… Adapted for Panda: (1)…(2)…(3)…") — provenance + adaptation-derivation log carried in the body, sediment that feeds the 383-line sprawl. |
| Granularity | pass | L226 — Idea Gate earns its split: distinct `/write idea-gate` leading word, upstream-gate reach no other mode covers, independent invocation. |
| pandastack conformance | fail | L116 — Edit mode loads `references/article-patterns.md` (~8K tokens, >5K) hot with no sub-agent dispatch anywhere in the file; body is ~383 lines vs the ~<80 discipline. (Frontmatter name=write matches folder; lib/ + references/ refs resolve.) |

## Why it's good
The anti-ghostwriting contract is enforced structurally, not by exhortation: every generative mode (Spar L69, Structure L94, Edit L135, Distill L177, Idea Gate L284) ends on a hard self-check that names the drift and the abort action, and the L380 Output Validation reference makes the per-mode checks exhaustive. The mode-selection table (L42) plus subcommand routing gives the skill genuine same-process-every-run predictability across eight distinct uses. Progressive disclosure is real: the heavy slop dictionaries, voice profile, and structural checks all live behind context pointers that resolve.

## Top fixes
1. L116 — honour the hot/cold dispatch rule: Edit mode pulls ~8K tokens (article-patterns.md alone) hot. Either dispatch a sub-agent for the pattern-match step, or load only the matched pattern entry, not the full 32KB library.
2. L355 — delete the duplicated conditional zh-ref list; it is already the L108-111 Edit trigger table. Keep one source of truth and point Layer-1 at it. While pruning, move the two inline origin tails (L224, L301 "Source: Shann Holmberg… Adapted for Panda…") to a single provenance pointer or the source page — the per-mode derivation log is sediment in the skill body.
3. L13 — collapse the Routing Boundary into the NOT-clauses only; the "canonical Panda writing assistant" identity already lives in the L4 description and is body-identity the description rule says to cut. This also starts paying down the 383-line body toward the ~80-line discipline.

## Behavioral cases
- trigger `/write postmortem on this draft` -> expected process: Postmortem mode (L189) — quote exact lines per category, banned generic-praise words enforced (L209), run AFTER `/write edit` for long posts.
- trigger `should I write about this originals/2026-06-26-thought.md` -> expected process: Idea Gate (L226) — Stage-0 brain grep (L243), pick 1 of 5 routes, emit writer-context-packet or 暫不寫.
- anti-trigger `just make this text sound human, de-AI it` -> should NOT fire (routes to `humanizer`, per L16).
- anti-trigger `final voice cleanup on this IC memo` -> should NOT fire (routes to `avoid-ai-writing`, per L17).
