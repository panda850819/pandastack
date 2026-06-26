---
type: skill-eval
skill: retro-month
bucket: productivity
evaluated_skill_hash: 44e705a2f44a811e6b088b8c2c772f10c55829c7
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — retro-month

**Verdict: WEAK.** Three axes land weak with no fail (completion, pruning, conformance), and the consistency rule is ≥2 weak → WEAK. Leading virtue is a hard-anchored interview process (one-question-at-a-time, verbatim capture, no-invent rule) that makes the strategic conversation reproducible; it loses the SOLID grade because the Phase 2 prep-summary fields (L100-105) name sections the resolved engine never emits, the body is 239 lines (~3x the ~80-line guideline), the 1a-1d sub-sections re-describe engine output (pruning sediment), and "scan-only month" leaves a soft completion edge with no checkable interview floor.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L113 — "Walk through layers ONE QUESTION AT A TIME" plus the fixed 3-phase spine (L14-16) pins the same process every run regardless of output. |
| Description / invocation | pass | L3 — front-loads "Interactive monthly retro", user-invocable, one trigger per branch ("/retro-month", "monthly retro", "monthly review"), no body-identity restated. |
| Completion criteria | weak | L63 — "scan-only month" and L107 "use Phase 1 raw scan" let the run continue with no checkable floor for how much interview must happen; only 2b-i is named load-bearing (L238), the rest is fuzzy on done-vs-not. |
| Information hierarchy | pass | L31 — engine call is hoisted, sub-sections "document what it gathers", and the Phase-3 template is co-located under one heading; steps and reference are placed by need. |
| Leading words | pass | L122 "Drift candidates" / L141 "commodity check" / L236 "append + supersede over delete + rewrite" anchor behaviour in compact reusable concepts. |
| Pruning | weak | L31 — "The sub-sections below document what it gathers" then 1a-1d re-describe git/learnings/weekly that the engine already produces; partial duplication of the engine's own output spec (sediment risk). |
| Granularity | pass | L238 — the 2b-i-through-2b-v split is justified by anti-premature-completion (short-version still forces goal-alignment), each layer earns its load. |
| pandastack conformance | weak | L100-105 — Phase 2 tells the agent to print "me.md goals (verbatim)", "Drift candidates (top 3)", "Strategic questions", "Active feedback patterns", but the resolved engine (retro-scan.sh) emits none of those (it states "semantic synthesis happens in the interview layer"), so the instructed summary references non-existent prep sections; body is also 239 lines (>~80 guideline). |

## Why it's good
The interview engine is the load-bearing strength: one-question-at-a-time (L113), verbatim capture including "想不到/沒有" (L146), and a hard never-invent rule (L237) make a genuinely stochastic strategic conversation reproducible. The runtime-agnostic scan engine (L18-23) guarantees Claude/Codex/Hermes produce the same brief, and the append+supersede memory discipline (L236) protects project memory from lossy rewrites.

## Top fixes
1. L100-105: reconcile the Phase 2 prep-summary fields with what retro-scan.sh actually emits. Either teach the engine to produce me.md-goals / drift-candidates / feedback-patterns, or rewrite the summary to the engine's real sections (git activity, learnings health, recent brain pages, GC sweep, inbox drain) so the agent is not told to print sections that do not exist.
2. L63 / L107 / L238: give "scan-only month" and "短版/skip" a checkable interview floor — name the minimum questions (2b-i at least) as the completion criterion in every branch, not just the skip branch, so no run can silently finish on scan alone.
3. L31-64: collapse the 1a-1d re-description of engine output; the engine is the single source of truth for what it gathers, so the sub-sections should reference its sections, not restate them — trimming this also pulls the body back toward the ~80-line guideline.

## Behavioral cases
- trigger `/retro-month` -> expected process: run retro-scan.sh month, print compressed scan block, ask "掃完了。要開始月度 interview 嗎？", then one-question-at-a-time interview, then write brain/reflections/monthly/$YEAR-$MONTH.md.
- trigger `monthly review` -> expected process: same 3-phase flow; if a Hermes cron already wrote the prep, locate it via ls -t inbox/retros and read instead of re-scanning.
- anti-trigger `weekly retro` -> should NOT fire (routes to retro-week; 30-day vs 7-day window and monthly output dir differ).
- anti-trigger `stress test this idea` -> should NOT fire (routes to grill/office-hours; that is fuzzy-idea intake, not a periodic retro).
