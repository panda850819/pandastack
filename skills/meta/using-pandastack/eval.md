---
type: skill-eval
skill: using-pandastack
bucket: meta
evaluated_skill_hash: 28861f70b8d050edcd437b6474f288a373edd2c2
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — using-pandastack

**Verdict: SOLID** (low end — 5 of 8 axes weak; held up by one genuinely strong core). A purpose-built router/forcing-function skill: the 1%-threshold contract (L11) reliably pressures a skill-check before any response, which is exactly the predictability job this file exists to do. The body overreaches that core with ~61 lines of inlined on-demand reference (L47–131) that drag hierarchy and conformance down.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L11 — the "even a 1% chance … you MUST invoke the skill before responding" rule forces the same check-first process every run; that is the root virtue and it is concrete. |
| Description / invocation | weak | L3 — description front-loads "Use at the start of any session" well, but this is the canonical router skill and frontmatter omits `user-invocable`/`type`/`version`; the one-line description carries no trigger branches and no reach clause for the router role. |
| Completion criteria | weak | L11 — the core contract ("invoke … before responding") is a posture with no checkable done-state; only the session ritual (L59 "Healthy session = zero lines printed") is genuinely checkable, so the headline step invites premature completion. |
| Information hierarchy | weak | L47 — two real lib pointers (L70, L81) defer only a fraction; from the session-opener ritual (L47) to end (L131) ~61 content lines of on-demand reference sit hot — session ritual + code block (L47–66), loop guard (L68–77), harness-evolution rule (L79–88), overlay-extension resolution order + hook-logging contract (L116–131). The overlay block especially is reference a router contract rarely needs hot. Sibling `careful`/`handover` evals mark hierarchy weak for a single ~60-line inlined subsystem; this skill inlines four. |
| Leading words | pass | L16 — "cognitive contract" / "forcing function" (L18) are compact pretrained anchors that name the whole behaviour region in few tokens. |
| Pruning | weak | L18 — "26 skills (5 of them persona lenses) and 3 documented lifecycle compositions" hardcodes counts that drift the moment a skill is added (sediment); the Red-flags table (L94–107, 12 rows) restates one idea — "don't rationalize past the check" — many times. |
| Granularity | pass | L66 — explicitly argues the session ritual stays folded here rather than minting a `pandastack:cold-start` skill that would duplicate `gbrain:cold-start`; a cut consciously NOT spent. |
| pandastack conformance | weak | L1 — frontmatter is valid and lib/ refs resolve, but the body runs 132 lines (>2x the ~80-line budget) and a skill whose body cites v2.1/v2.2.0/v3 behavior (L40, L66) carries no `version` field. |

## Why it's good
The skill knows exactly what it is — a forcing function against the model's "I'll just answer directly" default (L18) — and spends its whole length serving that one job rather than sprawling into unrelated capability. The instruction-priority ladder (L24–28) and the explicit "When NOT to invoke" list (L109–114) keep the contract from becoming a tyrant, and the granularity reasoning at L66 shows rare self-awareness about not minting redundant skills. The two lib/ pointers (L70, L81) keep the two heaviest references cold — though the body still inlines four other subsystems that should follow them out (see hierarchy axis).

## Top fixes
1. L18 — replace the hardcoded "26 skills (5 … persona lenses) and 3 … compositions" with a count-free phrasing ("dozens of skills across several lifecycle compositions"); a number that drifts on every skill add is sediment by construction.
2. L94–107 — collapse the 12-row Red-flags table to the 3–4 distinct rationalization classes (small-change, answer-directly, already-know-it, not-real-work); the rest are synonyms renaming one branch and inflate the file past the length budget.
3. L1 — add `version:` and `type: skill` to frontmatter; the body gates behavior on versions (v2.1, v2.2.0) yet the skill declares no version of its own, so drift is unauditable.
4. L116 — drop the overlay-extension subsystem (resolution order + hook-logging contract, ~11 lines) behind a context pointer like the loop-guard/evolution refs already use; it is install-time reference, not hot contract, and removing it from the hot body is the single biggest hierarchy + length win.

## Behavioral cases
- trigger `"let me start coding the auth refactor"` → expected process: skill-check fires BEFORE any edit (L11), lifecycle map routes to `pandastack:careful` for the prod path then `grill`/`plan` for the 3+-file refactor (L36–37), announced as "Using `pandastack:<skill>` to …" (L45).
- anti-trigger `"just read me lines 40–60 of config.ts, no edits"` → should NOT fire a lifecycle skill; matches "Reading code or files for orientation only" (L111) and the one-line-factual carve-out (L112), so the contract stays silent and routes to a plain read.
