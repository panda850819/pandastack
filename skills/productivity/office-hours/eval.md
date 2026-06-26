---
type: skill-eval
skill: office-hours
bucket: productivity
evaluated_skill_hash: 660182648217ca1a8503701c44591f13dbb1cd5e
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — office-hours

**Verdict: WEAK.** Leading virtue is gate-enforced predictability — every stage ends on a printed STOP/gate so the same gated process runs each time; but three axes are weak (no fail), which the verdict rule (≥2 weak → WEAK) puts below SOLID. It loses points on a 252-line body vs the ~80 discipline with a borderline-hot lib load (5 `@`-imports ≈ 4.8K tokens, just under the 5K sub-agent threshold), a Stage-2 skip-guard that re-argues itself three ways, and a description trigger-list that renames one branch several ways.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L93 — "ONE question at a time. Wait for answer." plus named stop conditions (L97) and STOP-and-wait gates (L135) lock the same process every run, not the same output |
| Description / invocation | weak | L5 — leading phrase "Bring a fuzzy idea" front-loads well, but the trigger list packs near-synonyms ("I have an idea" / "let me think out loud" / "office hours" / "structured intake") that rename one branch; one-trigger-per-branch is violated |
| Completion criteria | pass | L266 — `acceptance:` MUST be a concrete grep/test/file-exists check, "write checks, not vibes" — every emitted task is done-checkable, defeating premature-completion bait |
| Information hierarchy | pass | L69 — steps stay in SKILL.md; the brief (L154) and plan (L234) templates are output specs co-located with the stage that emits them, and the 5 reusable rules live behind `@`-pointers; co-location held |
| Leading words | pass | L32 — "30-minute structured pressure cooker" anchors the whole behaviour in one pretrained concept; reinforced by "mid-flight weapon" (L61) and one-way/two-way door (L89) |
| Pruning | weak | L79 — the Stage 2 skip-guard is one ~180-word paragraph that re-argues "don't skip a fuzzy scope" three ways ("self-confirming", "evidence print is what exposes", "do NOT skip") and ends with a redundant Chinese gloss; tighten to the four-condition gate + one why-line |
| Granularity | pass | L228 — splitting Stage 5b (executable plan) off Stage 5 (brief) is earned: it is reached only when the brief routes to /sprint or /team-orchestrate, an independent-reach branch that also defends WHY/WHAT separation |
| pandastack conformance | weak | L69/L94/L95/L99/L103 — frontmatter valid (name=folder=office-hours) and all 7 lib refs resolve; the 5 `@`-imports (capability-probe/push-once/escape-hatch/stop-rule/bad-good-calibration) load hot ≈4.8K tokens, just under the 5K sub-agent threshold (goal-mapping L73 and skill-decision-tree L194 are cold "read/apply" pointers, not hot), so the real conformance miss is the 252-line body vs the ~80 discipline, ~3x over with no clear earn |

## Why it's good

The gate discipline is the load-bearing strength: adversarial drilling is gated to one question at a time with named stop conditions (L93, L97), alternatives are gated per-approach with an explicit non-batching STOP (L130-135), and the run only ends on a brief whose every emitted task carries a greppable acceptance check (L266). The Stage 2 skip-guard (L79) is a strong defence against the self-confirming "no unknowns" judgment — it forces printed evidence for all four concreteness conditions before declining to grill. The brief/plan WHY-vs-WHAT separation (L232) keeps each fact in exactly one file, a clean single-source-of-truth move.

## Top fixes

1. L30-281 — cut the 252-line body toward the ~80 discipline (it is ~3x over). The hot lib load is already only ≈4.8K tokens (5 `@`-imports, L69/L94/L95/L99/L103), just under the 5K sub-agent threshold, so the dispatch rule is not yet tripped; but every line of body trimmed buys headroom before it is. Convert the stage-1-only `@../../../lib/capability-probe.md` (L69) to an on-demand "read when you reach Stage 1" cold pointer so `--quick` runs never pay its tokens.
2. L5 — collapse the trigger list to one phrase per branch ("office hours" / "stress test this" / "draft a brief"); drop "I have an idea" and "let me think out loud" as synonyms that inflate context load every turn.
3. L79 — compress the Stage 2 skip-guard to the four-condition checklist + a single why-line; it currently restates "don't skip a fuzzy scope" three times and ends with a redundant Chinese gloss.

## Behavioral cases

- trigger `I think I want to build a brief-router but I'm not sure` -> expected process: Stage 1 capability-probe + vault scan + goal-mapping, Stage 2 one-question-at-a-time premise drill (push-once menu on rehearsed replies), Stage 3 2-3 named alternatives with per-approach Apply gate, Stage 4 premise refresh, Stage 5 brief to `docs/briefs/`, Stage 5b plan to `docs/plans/` if it routes to /sprint.
- trigger `draft a brief, context is already loaded` -> expected process: `/office-hours --quick`, Stage 1 skipped with the one-line context-summary print (L67), straight to Stage 2.
- anti-trigger `grill me on this scope for 5 min, no brief needed` -> should NOT fire (routes to `/grill` — atomic mid-session pressure, confirmed/open log, no brief output per L58).
- anti-trigger `I already wrote the brief, critique the plan` -> should NOT fire (routes to `/boardroom` per L47).
