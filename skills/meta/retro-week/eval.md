---
type: skill-eval
skill: retro-week
bucket: meta
evaluated_skill_hash: 26e93bd072b5dac5d19d0c84d6e30d77d20ad227
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — retro-week

**Verdict: SOLID.** A genuinely predictable multi-phase interview: a shared engine (Ln 23) hard-fixes Phase 1 data across runtimes and every phase ends on an explicit "wait for user" gate, but the body has grown to 488 lines of hot inline bash that violates the pandastack length + hot/cold discipline.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L20 — "raw-data gathering is done by the shared, runtime-agnostic engine so Claude / Codex / Hermes all produce the same brief" pins the process identically across runtimes. |
| Description / invocation | weak | L3 — three triggers ("/retro-week", "weekly retro", "weekly review") are one branch renamed; near-synonyms are the duplication the rubric says to collapse. |
| Completion criteria | pass | L332 — "**準備好聊嗎？**" — wait for user; each phase ends on a checkable user gate (also L68, L146, L364), no premature-completion bait. |
| Information hierarchy | weak | L164 — BSD-mtime / process-sub portability commentary sits hot in SKILL.md; that is in-skill reference that belongs in the engine script, not the step ladder. |
| Leading words | pass | L155 — "Garbage Collection Sweep" deliberately borrows Lopopolo's pretrained anchor (cited L157) to compact a whole sub-protocol. |
| Pruning | weak | L196 — the "Driver ledger distillation (PRO-40)" / PRO-42 / PRO-45 lineage comments are sediment: ticket-id provenance the runtime never obeys, paying load to say nothing. |
| Granularity | weak | L155 — Phase 1.6 (GC sweep, ~175 lines of its own bash + tables) is a distinct sub-protocol with its own leading word; it earns a split off the main retro flow rather than living inline. |
| pandastack conformance | weak | L23 — points at `~/site/skills/pandastack/scripts/retro-scan.sh`, which does not exist (live copy is the worktree's `scripts/retro-scan.sh`); plus the 488-line body blows the ~<80-line budget and the hot inline bash should dispatch under hot/cold. |

## Why it's good
The phase architecture is the load-bearing strength: a runtime-agnostic engine (Ln 20-27) removes the largest source of run-to-run variance, and the "propose only, never auto-write" discipline (Ln 159, 334-339) is restated at every surface where the agent might overstep. Completion is enforced by literal user-gate prompts at the end of each phase, so the agent cannot silently chain past a checkpoint. The recurrence gate (Ln 242, count >= 2) gives the GC sweep a real, checkable threshold instead of "be selective".

## Top fixes
1. L23 — fix or harden the engine path: it resolves to a non-existent file outside the worktree; reference it relative to the skillpack root or via a resolved variable so it doesn't silently break post-merge.
2. L164-214 — move the shell-portability commentary and PRO-40/42/45 lineage notes into the engine script (or a `lib/` ref); the SKILL.md body should read process, not carry the engine's debugging sediment.
3. L3 — collapse the three synonym triggers to one canonical leading phrase plus the slash command; renaming one branch three times is pure context-load duplication.

## Behavioral cases
- trigger `/retro-week` → expected process: run `retro-scan.sh week` engine → print compressed scan → Phase 1.5 brain synthesis → Phase 1.6 GC sweep → Phase 2 one-question-at-a-time interview → Phase 3 write `brain/reflections/weekly/$YEAR-W$WEEK.md`.
- anti-trigger `monthly review` → should NOT fire (routes to `retro-month`); a same-day "save this note" or "ship this" routes to `ingest` / `ship`, not retro-week.
