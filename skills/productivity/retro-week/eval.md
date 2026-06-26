---
type: skill-eval
skill: retro-week
bucket: productivity
evaluated_skill_hash: d08d94db646e25785175db9fc49b7646d6f8cbd2
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — retro-week

**Verdict: WEAK.** Leading virtue is the gate-and-discipline architecture — every phase ends on a literal "wait for user" gate and the GC sweep holds a strict propose-only / recurrence-gate discipline. It loses points to these weaknesses: the phase overview contradicts the actual write target (plus an orphan `feedback-log.md` the agent is told to Edit but is never defined), the three triggers are one branch renamed, the recurrence-gate rule is restated across five surfaces, and the 473-line body overruns the pandastack length budget with hot inline bash.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | weak | L18 — overview says "write final retro to docs/retros/" but the real Phase 3 step (L400) writes `brain/reflections/weekly/$YEAR-W$WEEK_NUM.md`, and L20 declares the vault retired; an agent trusting the summary writes to the wrong (retired) directory. Second crack: L368-370 + L460 command the agent to read/increment/Edit a singular `feedback-log.md` whose path is never defined and which no phase produces — the GC rewrite replaced it with `memory/feedback_*.md` scanning (L173-181) but left the old references; an agent cannot deterministically find a file it is told to Edit. The cross-runtime engine itself (L20) is a sound determinism move and resolves on disk. |
| Description / invocation | weak | L3 — the three triggers ("/retro-week", "weekly retro", "weekly review") are one branch renamed; the rubric says collapse near-synonyms — only the slash command plus one phrase earn their hot context load. |
| Completion criteria | pass | L317 — "**GC sweep 完了 … 準備好聊嗎？**" — wait for user; every phase boundary ends on a literal user gate (also L68, L146, L349), no premature-completion bait. |
| Information hierarchy | weak | L33 — the 1a–1c subsections "document what the engine gathers (for transparency / manual fallback)", restating work the same line says the engine "already covers"; that fallback prose sits hot in the body instead of behind a pointer. |
| Leading words | pass | L157 — "Garbage Collection Day" borrows Lopopolo's pretrained anchor (cited inline) to compact the whole convert-slop-to-mechanism sub-protocol into two words. |
| Pruning | fail | L322 — the recurrence-gate rule (count>=2) is restated at L230, L260, L266, L285 and L322 (five surfaces, not one source); combined with the PRO-40/PRO-42 ticket lineage (L196) and inlined multi-line bash, the same meaning lives in many places and the body runs 473 lines against the ~<80 guidance. Add the orphan `feedback-log.md` references (L368-370, L460) — sediment from the pre-GC design that the brain-data rewrite never cleaned up. |
| Granularity | pass | L17 — each phase split is a user-gated checkpoint that blocks premature completion (scan → synthesis → GC → interview → write), and 1.5/1.6 carry their own skip conditions, so each cut earns its load. |
| pandastack conformance | weak | L2 — frontmatter valid (name=retro-week matches folder) and `~/site/skills/pandastack/scripts/retro-scan.sh` resolves on disk; but the 473-line body far exceeds ~<80 lines, the extra length does not clearly earn itself given the duplication, and the synthesis/GC bash is hot inline rather than dispatched. |

## Why it's good
The load-bearing strength is the gate-and-discipline architecture. The "propose only, never auto-write" rule is restated at every surface where the agent might overstep (L159, L321-324, L379), and completion is enforced by literal user-gate prompts at each phase boundary (L68, L146, L317, L349) so the agent cannot silently chain past a checkpoint. The recurrence gate (L230, count>=2) gives the GC sweep a checkable threshold instead of "be selective", and the shared `retro-scan.sh` engine (L20-27) is the right design to remove run-to-run variance and resolves cleanly on disk.

## Top fixes
1. L18 vs L400 — reconcile the Phase 3 write target. The overview says `docs/retros/`; the actual step writes `brain/reflections/weekly/`, and L20 itself declares the brain the source and the vault retired. `docs/retros/` on L18 is stale sediment that mis-routes any agent reading the summary; make both say `brain/reflections/weekly/`. This is the predictability defect.
2. L230 / L285 / L322 — collapse the recurrence-gate rule to a single source of truth. Define count>=2 once (the 1h step-5 definition), then reference it; delete the restatements in the GC-table caption and the "what NOT to do" block.
3. L33-45 + L164-201 — drop or pointer-out the 1a–1c manual-fallback subsections (they duplicate what L33 says the engine already covers) and move the shell-portability commentary plus the PRO-40/PRO-42 ticket lineage into the engine script or a `lib/` ref; this is the bulk of the 473-line overrun.
4. L3 — collapse the three synonym triggers to the slash command plus one canonical phrase; renaming one branch three times is pure context-load duplication.
5. L368-370 / L460 — remove the orphan `feedback-log.md` references. The GC rewrite (Phase 1.6) replaced this singular file with `memory/feedback_*.md` scanning, but the interview and Phase-3 update steps still tell the agent to read, increment a counter in, and Edit a `feedback-log.md` whose path is never defined and which no phase produces. Either point them at the actual `memory/feedback_*.md` data or delete the steps; as written they are an un-actionable dead reference (predictability + sediment, same rewrite-debris class as the `docs/retros/` defect in fix 1).

## Behavioral cases
- trigger `/retro-week` -> expected process: run `retro-scan.sh week` engine → print compressed scan + Phase 1.5 brain synthesis + Phase 1.6 GC sweep, each ending on a user gate → Phase 2 one-question-at-a-time interview → Phase 3 write `brain/reflections/weekly/$YEAR-W$WEEK.md`.
- trigger `weekly review` -> expected process: same flow; if a Hermes cron already pre-generated the prep brief, read it from brain/inbox/retros/ instead of re-scanning (L27, L337).
- anti-trigger `monthly retro` -> should NOT fire (routes to retro-month).
- anti-trigger `ship this note` -> should NOT fire (routes to ship; retro-week only writes the retro page and never git-commits, L462).
