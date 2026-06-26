---
type: skill-eval
skill: using-pandastack
bucket: meta
evaluated_skill_hash: 28861f70b8d050edcd437b6474f288a373edd2c2
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — using-pandastack

**Verdict: WEAK** (mechanically — 5 axes weak triggers the two-or-more rule; the core is genuinely strong). Leading virtue: the 1%-threshold contract (L11) is a real forcing function that pressures a skill-check before every response, which is exactly the predictability job this router exists to do. What costs it: the body has accreted four semi-independent subsystems (session ritual L47, loop-guard L68, harness-evolution L79, overlay-extension L116) that push it to 131 lines, hardcode an already-stale count (L18 says "26 skills"; the repo now ships 28), and leave the headline "check" with no checkable done-state (L34).

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L11 — "even a 1% chance … you MUST invoke the skill before responding" fixes one invariant process (check-before-act) that runs identically every turn regardless of task; that is the root virtue and it is concrete. |
| Description / invocation | pass | L3 — front-loads the positional leading phrase "Use at the start of any session"; model-invoked (no `user-invocable`) is correct for a SessionStart contract; no body identity restated. One trigger, no duplication, no body-identity restated — clean on every invocation sub-criterion. |
| Completion criteria | weak | L34 — the lifecycle map's "First skills to check" ends on a soft criterion: "check" is not a done/not-done state, so the agent can declare "I checked, decided no" and call the contract satisfied — the exact premature-completion bait the file exists to prevent. Only the session ritual (L59 "Healthy session = zero lines printed") is genuinely checkable. |
| Information hierarchy | weak | L47 — two lib pointers (L70, L81) defer only the two heaviest refs; from the session-opener ritual (L47) to end (L131) ~61 lines of on-demand reference sit hot — ritual + code block (L47-66), loop guard (L68-77), evolution rule (L79-88), overlay resolution-order + hook-logging contract (L116-131). The overlay block especially is install-time reference a router contract never needs hot. |
| Leading words | pass | L18 — "cognitive contract" / "forcing function" are compact pretrained anchors that name the whole behaviour region in few tokens; the red-flags table collapses a dozen rationalizations into one reusable STOP-on-this-thought pattern rather than restating the rule each time. |
| Pruning | weak | L18 — "26 skills (5 of them persona lenses) and 3 documented lifecycle compositions" hardcodes counts that have already drifted (the repo now ships 28 SKILL.md files; 15 carry a `classification:`), so the number is live-wrong sediment, not just future-fragile; L66 ("This ritual does NOT live in its own skill…") and L88 ("This keeps pandastack as a skill library that evolves…") are maintainer-facing design rationale, not behavior the running agent obeys — no-ops. |
| Granularity | weak | L68 — the loop-guard (fires on repeated-failure) and L79 harness-evolution rule (fires only when editing skills) are independently-triggered concerns folded into a SessionStart contract; each is reached by a condition unrelated to session-start and could earn its own pointer/skill. Bundling them dilutes the file's one job. (The session ritual at L66 is a defensible NON-split; these two are not.) |
| pandastack conformance | weak | L1 — frontmatter valid (name=folder, description present) and both lib/ refs resolve at repo root, and hot/cold dispatch is not triggered (own refs pushed cold via L70/L81 pointers, <5K hot). The weak is purely length: the body runs 131 lines (>1.5x the ~80-line guideline per writing-great-skills L81), driven by the four embedded subsystems rather than the contract itself. (`version`/`type` are optional per SKILL-FRONTMATTER.md — `type` defaults to `skill` and most sibling skills omit both — so their absence is not a violation.) |

## Why it's good
The skill knows exactly what it is — a forcing function against the model's "I'll just answer directly" default (L18) — and arms that function with a rationalization table (L94-107) that pre-empts the exact escape hatches the model reaches for. The instruction-priority ladder (L24-28) and explicit "When NOT to invoke" list (L109-114) keep the contract from becoming a tyrant, which is what makes it survivable as an always-on SessionStart load. The two lib/ pointers (L70, L81) keep the heaviest refs cold.

## Top fixes
1. L34 — sharpen the lifecycle-map criterion: "First skills to check" → "invoke (or record an explicit skip-reason this turn)", so "I checked" cannot silently mean "I skipped". This is the headline step and it is the only one without a done-state.
2. L18 — replace hardcoded "26 skills (5 … persona lenses) and 3 … compositions" with count-free phrasing; the number has already drifted (repo ships 28) and breaks on every skill add. Same no-op test flags the design-rationale paragraphs at L66 and L88 — move them to a commit message or sibling design note.
3. L116 — push the overlay-extension subsystem (resolution order + hook-logging contract, ~16 lines) behind a context pointer like the loop-guard/evolution refs already use; it is install-time reference, not hot contract, and is the single biggest hierarchy + length win. The same cold-pointer move on the loop-guard (L68) and harness-evolution (L79) blocks would also clear the granularity weak and pull the body back under ~80 lines.

## Behavioral cases
- trigger `"let me start coding the auth refactor"` → expected process: skill-check fires BEFORE any edit (L11); lifecycle map routes to `pandastack:careful` for the prod path, then `grill`/`plan` for the 3+-file refactor (L36-37), announced "Using `pandastack:<skill>` to …" (L45).
- trigger `same refactor attempt failed 3 times` → expected process: loop-guard fires, STOP before a 4th try, re-grill the premise, consider `pandastack:checkpoint` (L68-76).
- anti-trigger `dispatched as a subagent to run one task` → should NOT fire; `<SUBAGENT-STOP>` short-circuits the whole contract (L6-8).
- anti-trigger `"just read me lines 40-60 of config.ts, no edits"` → should NOT fire a lifecycle skill; matches "Reading code or files for orientation only" (L111), so the contract stays silent.
