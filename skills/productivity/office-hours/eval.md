---
type: skill-eval
skill: office-hours
bucket: productivity
evaluated_skill_hash: 8b8f98f69586d422ca0e1e30c90a0fdcc19f925c
evaluated_at: 2026-06-29
rubric: writing-great-skills@1.0.0
---

# Eval — office-hours

**Verdict: SOLID.** Gate-enforced predictability — every stage closes on a printed STOP/gate so the same gated process runs each time — is the leading virtue; the only soft spots are the verbose Stage-2 skip-guard and an over-~80 body.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L99 — "ONE question at a time. Wait for answer." plus named stop conditions (L103) and a hard per-approach STOP (L141) lock the same *process* every run, not the same output. |
| Description / invocation | pass | L5 — leads with "Bring a fuzzy idea to office hours" and lists distinct branches (/office-hours, "stress test this", "draft a brief"→`--quick`); identity sits in the body, not the description. |
| Completion criteria | pass | L168 — "`acceptance:` MUST be a concrete check (a grep, a test/lint command, a file-exists assertion) … write checks, not vibes" makes every emitted task done-checkable, defeating premature completion. |
| Information hierarchy | pass | L68 — capability-probe is an explicit cold pointer ("not a hot import — `--quick` runs never pay its tokens"); push-once/escape-hatch/stop-rule/bad-good are `@`-pointers and the brief+plan scaffolds live in `lib/output-templates.md` (L156, L166). |
| Leading words | pass | L32 — "30-minute structured pressure cooker" anchors the whole behaviour in one pretrained concept; reinforced by "mid-flight weapon" (L60) and one-way/two-way door (L95). |
| Pruning | weak | L85 — the Stage-2 skip-guard re-argues the four-condition print (L80-83) in prose ("self-confirming … the evidence print is the guard … do NOT skip"); also L58 restates the mode-timing already given at L50-51. Untouched by the #106 fold. |
| Granularity | pass | L160 — splitting Stage 5b (executable plan) off Stage 5 (brief) is earned: reached only when the brief routes to /sprint or /team-orchestrate, and it guards the WHY/WHAT separation (L164). |
| pandastack conformance | weak | L177 — frontmatter is valid (`type: skill`, L3) and all `lib/` refs resolve, but the body runs ~149 content lines, well past the ~80 discipline, and not all of it is clearly earned (the L85 skip-guard prose + the duplicated Differs-from-grill block). |

## Why it's good

The gate discipline is load-bearing: adversarial drilling is one question at a time with named stop conditions (L99, L103), alternatives are gated per-approach with an explicit non-batching STOP (L141), and the run only ends on a brief whose plan tasks carry greppable `acceptance:` checks (L168). Information hierarchy is exemplary — the heavy capability probe is a cold pointer (L68) and both output scaffolds are extracted to `lib/output-templates.md`, so the body stays gates-only. The brief/plan WHY-vs-WHAT split (L164) keeps each fact in exactly one file.

## Top fixes

1. L85 — compress the Stage-2 skip-guard: the four-condition print (L80-83) already *is* the guard; the trailing "self-confirming → do NOT skip" prose says it three ways. Cut to one why-line.
2. L57-58 — the "Differs from `/grill`" block duplicates the mode-timing from Modes (L50-51) and the brief/no-brief distinction; collapse to the single load-bearing line (`/grill` = mid-flight, no brief; `/office-hours` = ends with a brief).
3. Stage numbering — the #106 fold left the flow as Stage 1/2/3/5/5b with no Stage 4 (L107 jumps to L143); renumber 5→4 or add a one-word note so a reader does not hunt for the missing stage. Same pass should normalize the `lib/` path style (L68 `../../../lib/`, L72 `lib/`, L156 full `skills/.../lib/`).

## Behavioral cases

- trigger `I think I want to build a brief-router but I'm not sure` → expected process: full mode — Stage 1 capability-probe + vault scan + goal-mapping, Stage 2 one-question-at-a-time premise drill (push-once menu on rehearsed replies), Stage 3 2-3 named alternatives with per-approach Apply gate, Stage 5 premise refresh + brief to `docs/briefs/`, Stage 5b plan to `docs/plans/` if it routes to /sprint.
- trigger `draft a brief, context is already loaded` → expected process: `/office-hours --quick`, Stage 1 skipped with the one-line context-summary print (L66), straight to Stage 2 premise challenge.
- anti-trigger `critique this prepared plan / red-team this` → should NOT fire (routes to `/boardroom` — a prepared plan, not a fuzzy idea).
- anti-trigger `grill me on this scope for 5 min, no brief needed` → should NOT fire (routes to `/grill` — atomic mid-session pressure, confirmed/open log, no brief output per L57).
