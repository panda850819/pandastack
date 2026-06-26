---
type: skill-eval
skill: grill
bucket: productivity
evaluated_skill_hash: 67249cbbdc6d7f54b2d3f7775d30173064244288
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — grill

**Verdict: WEAK.** Leading virtue is a genuinely predictable adversarial process (ONE-question loop + named push menu + hard stopping rule), but four axes leak points: the office-hours disambiguation and "atomic, no-brief" identity are restated across description and body, the push-once menu is pushed to lib then re-inlined verbatim, and the body carries changelog/deprecation sediment plus a dead `reads:` glob at 147 lines.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L48 — "ONE question at a time. Wait for the answer. Then pick the next question based on what the answer revealed" pins one invariant process every run, not a fixed output |
| Description / invocation | weak | L5 — "Atomic 5-10 min tool, no brief output" restates body identity (L26, L139) and the office-hours steer is carried twice (L8-9 + L139) |
| Completion criteria | pass | L85 — stopping rule is checkable and exhaustive (3 dry answers / 7+ Qs / escape hatch), with a hard-cap escape at L101 against premature continuation |
| Information hierarchy | weak | L52 — push-once is pushed to `lib/push-once.md` (L13) yet the 5-pattern menu is re-inlined at L54-63, breaking progressive disclosure and co-location for that concept |
| Leading words | pass | L26 — "unknown unknowns" anchors the whole skill in a pretrained concept; "rehearsed first answers" (L50) and "bike-shedding" (L87) carry behaviour cheaply |
| Pruning | weak | L147 — Origin changelog (`--mode structured` add/remove archaeology) is sediment that changes no behaviour; also `reads: docs/learnings/**` (L11) is a no-op glob the body never consumes |
| Granularity | pass | L52 — the push-once split earns its load: `lib/push-once.md` is reached by office-hours and boardroom too, so the cut buys cross-skill reach, not just length |
| pandastack conformance | weak | L11 — frontmatter `name=grill` matches folder and lib refs resolve (`lib/goal-mapping.md`, `lib/push-once.md` exist at repo root, ~2K tokens combined so no hot/cold dispatch trip), but body is 147 lines (>~80) without the length earning itself, and `reads: docs/learnings/**` points at a near-empty dir (only an unrelated shell-guard pitfall) the skill ignores |

## Why it's good
The core engine is hard to misrun: L48 forces one question at a time with the next picked from the last answer, L50 codifies "push once before switching axes," and L85-101 give a checkable stopping rule with a two-strike escape hatch that defends against both bike-shedding and over-grilling. The axis list (L69-76) is framed explicitly as a search space, not a checklist (L67), which keeps the skill adversarial rather than a questionnaire — the exact thing that distinguishes it from office-hours.

## Top fixes
1. L54-63 — collapse the re-inlined 5-pattern menu to a context pointer ("print the menu from `lib/push-once.md`"); the SKILL.md menu (L54-63) is byte-identical to the lib's Output-protocol menu (`lib/push-once.md` L49-60), so it is a true SSOT violation: two copies that must be hand-synced and will silently drift on the next edit to either file.
2. L143-147 — delete the Origin changelog; `--mode structured` add-then-remove archaeology is sediment that changes no run behaviour. Keep at most the one-line Matt Pocock attribution (already at L24).
3. L11 — drop or fix `reads: docs/learnings/**`; the body never consumes it and the dir holds only an unrelated pitfall, so it is a no-op declaration that fails the relevance check.

## Behavioral cases
- trigger `grill me on the points-system scope` -> expected process: optional goal-map (L30), then ONE question (L48), push-once menu on rehearsed reply (L52), drill axes as search space (L69), stop per L85, emit grill log to `Inbox/grill-*.md` (L126)
- anti-trigger `draft me a brief / structured intake on X` -> should NOT fire; routes to `/office-hours` (default full or `--quick`) per L8-9, L139
- anti-trigger `fix this typo` / `P0 incident, just ship` -> should NOT fire; explicit skip per L41-44
