---
title: Pandastack skill-quality baseline (corpus-wide)
date: 2026-06-26
scope: 28 skills across doing/ meta/ thinking/ writing/
criteria: writing-great-skills 8-axis scorecard
---

# Pandastack skill-quality baseline — 2026-06-26

## Method

Every skill was scored against the **writing-great-skills 8-axis scorecard**: Predictability, Description/invocation, Completion criteria, Information hierarchy, Leading words, Pruning, Granularity, pandastack conformance. Each axis verdict (pass / weak / fail) is **line-cited** to the exact `SKILL.md` line that backs it — no verdict rests on paraphrase. Every eval was then **adversarially re-verified** by a second pass that tried to refute each call: it confirmed the cited line exists and supports its verdict, probed every `pass` axis for a hidden no-op / duplication / vague criterion the first pass missed, and probed every `weak`/`fail` for an invented requirement (faulting `version`/`type`/`reads:` as missing when SKILL-FRONTMATTER.md makes them optional or advisory). Each eval's frontmatter carries an `evaluated_skill_hash` = `git hash-object` of the scored SKILL.md, so `scripts/lint-eval-fresh.sh` fails the moment a skill is edited without its eval being re-run. The baseline cannot silently drift.

**Corpus health: 28 skills. 2 STRONG, 26 SOLID, 0 WEAK, 0 FAIL.** Every skill clears the bar on its load-bearing virtue (a deterministic process anchored by a pretrained leading word). No skill carries an overall WEAK or FAIL verdict; the entire quality story is in the per-axis weaknesses, which cluster on three axes (Pruning, Conformance, Completion) and almost never touch the core (Predictability, Granularity).

## Scorecard (per skill)

Weak/fail axes use short labels: Pred, Desc, Compl, Hier, Lead, Prune, Gran, Conf.

| Skill | Bucket | Verdict | Weak / fail axes |
|---|---|---|---|
| freeze | doing | **STRONG** | Lead |
| writing-great-skills | meta | **STRONG** | Desc, Compl |
| handover | doing | SOLID | Compl, Prune |
| skill-eval | meta | SOLID | Desc, Prune |
| design-lead | thinking | SOLID | Compl, Prune |
| grill | thinking | SOLID | Prune, Conf |
| ops-lead | thinking | SOLID | Compl, Prune |
| product-lead | thinking | SOLID | Compl, Prune |
| gatekeeper | meta | SOLID | Compl, Prune, Conf |
| ceo | thinking | SOLID | Compl, Prune, Conf |
| eng-lead | thinking | SOLID | Compl, Hier, Prune |
| review | doing | SOLID | Pred, Hier, Prune, Conf |
| ship | doing | SOLID | Compl, Lead, Prune, Conf |
| sprint | doing | SOLID | Compl, Hier, Prune, Conf |
| team-orchestrate | doing | SOLID | Desc, Hier, Prune, Conf |
| checkpoint | meta | SOLID | Desc, Compl, Lead, Prune |
| retro-month | meta | SOLID | Desc, Hier, Prune, Conf |
| dojo | thinking | SOLID | Desc, Compl, Prune, Conf |
| office-hours | thinking | SOLID | Desc, Hier, Prune, Conf |
| write | writing | SOLID | Desc, Lead, Prune, Conf |
| init | meta | SOLID | Desc, Lead, Prune, Conf + **FAIL: Compl** |
| qa | doing | SOLID | Desc, Compl, Hier, Prune, Conf |
| deepwiki | meta | SOLID | Compl, Hier, Lead, Prune, Conf |
| retro-week | meta | SOLID | Desc, Hier, Prune, Gran, Conf |
| skill-creator | meta | SOLID | Desc, Hier, Prune, Gran, Conf |
| using-pandastack | meta | SOLID | Desc, Compl, Hier, Prune, Conf |
| boardroom | thinking | SOLID | Pred, Desc, Compl, Prune, Conf |
| careful | doing | SOLID | Desc, Compl, Hier, Prune, Gran, Conf |

## Corpus patterns

Axis-level weakness counts across all 28 skills (a skill contributes once per weak/fail axis):

| Axis | weak | fail | total dings | % of corpus |
|---|---|---|---|---|
| **Pruning** | 26 | 0 | **26** | 93% |
| **pandastack conformance** | 19 | 0 | **19** | 68% |
| **Completion criteria** | 17 | 1 | **18** | 64% |
| Description / invocation | 15 | 0 | 15 | 54% |
| Information hierarchy | 12 | 0 | 12 | 43% |
| Leading words | 6 | 0 | 6 | 21% |
| Granularity | 3 | 0 | 3 | 11% |
| **Predictability** | 2 | 0 | **2** | 7% |

**Weakest axes (the systemic debt):**

1. **Pruning — 26/28 (93%).** Near-universal. The dominant failure shape is the **"Common Rationalizations" table** (sprint, ship, review, careful, using-pandastack) — motivational prose the model already obeys, a no-op that pays hot-context load to change no behavior. The second shape is **changelog sediment** (`## Origin` sections in dojo, grill, team-orchestrate; PRO-id lineage comments in retro-week) — provenance that belongs in commit history, not a hot SKILL.md. The third is **single-fact-stated-N-times** (routing boundaries restated in description + body + Team-protocol across every persona lens). Pruning weakness is what drives most of the length overruns.
2. **pandastack conformance — 19/28 (68%).** Almost entirely the **~80-line body budget**, not broken refs. The big bodies: retro-week (488), sprint (346), deepwiki (316), review (286), boardroom (231), office-hours (~280). Lib/path refs resolve in the large majority of cases; the genuine *broken* refs are narrow and fixable — retro-month and retro-week both point at `~/site/skills/pandastack/scripts/retro-scan.sh` (canonical is `plugins/pandastack/scripts/...`), and skill-creator cites a dead `learnings/patterns/long-session-evals` path 3×. Frontmatter drift (`mode:` instead of `type:` in sprint/boardroom; missing `version`) is real but cosmetic and lint-tolerated.
3. **Completion criteria — 18/28 (64%), incl. the lone FAIL.** The pattern is **soft middle steps** — "do a quick sanity check", "if it revealed something useful", "predict the failure mode", "ground in team reality" — directives with no checkable done-state that invite premature completion. Persona lenses (ceo/product/design/ops/eng) all share this: their On-Invoke steps end on actions, not done-conditions. **init is the only axis-level FAIL in the corpus:** its final step *prints* "pandastack initialized" without verifying the config block was appended or the dirs created — it asserts done instead of checking it.

**Strongest axes (what the corpus does right):**

1. **Predictability — only 2/28 weak (7%).** This is the corpus's spine and it holds. Almost every skill fixes a deterministic ordered process (numbered stages, fixed gather-state blocks, per-phase wait-gates, terminal-state contracts) so the *process* repeats even when the output varies. The two misses are routing non-determinism (boardroom's fuzzy `ops_dominant` keyword match, review's unresolved `{learnings_dir}` path), not a vague core.
2. **Granularity — only 3/28 weak (11%).** Splits are disciplined: persona lenses share `lib/persona-frame.md` rather than copy it; heavy sub-phases (dojo/grill/review/ship) are split off `/sprint` by independent reach; modes stay as branches within one skill. The 3 misses are accretion (`.5` sub-phases in skill-creator) or an un-split heavy sub-protocol (retro-week's GC sweep), not fragmentation.
3. **Leading words — only 6/28 weak (21%).** The corpus leans hard on pretrained anchors that collapse a behavior region into a few tokens: "conductor", "STRIDE", "boil the lake", "leaky bucket", "pressure cooker", "whistle and a finish line", "every continue is a harness failure". These do real invocation+execution work, not decoration.

## Skills needing work

No skill earned an overall WEAK or FAIL verdict, so "needing work" here means the heaviest axis-debt, ranked by severity. The one structural defect (init's Completion FAIL) leads; the rest are the 5–6-weak-axis cluster.

1. **init** (meta, axis-FAIL) — **top fix: replace the print-only finish with a real completion check.** Step 5 must assert the `## pandastack` block exists in the target config and the `docs/learnings/*` + `docs/checkpoints` dirs were created, *then* print success. As written, a failed Step 3/4 still reports "initialized". This is the only correctness-class defect in the corpus.
2. **careful** (doing, 6 weak) — **top fix: split the stopping-discipline + continue-failure logging subsystem (L77–137) out of the destructive-action gate.** Two skills are welded into one; the second has its own leading word and trigger and is unreachable by the L3 description. Then cut the "Common Rationalizations" table.
3. **qa** (doing, 5 weak) — **top fix: resolve the dangling `{learnings_dir}` / `type: pitfall` pointer** (L14) — link `lib/learning-format.md` (which exists) or inline the one rule. As written Step 5 dead-ends. Add a NOT-clause to the description to stop collision with verify/review/testing.
4. **deepwiki** (meta, 5 weak) — **top fix: wire the existing-but-unreferenced `agents/system.md` / `agents/wiki-gen.md` / `agents/mermaid.md` via context pointers** and move the hot Phase-3 grounding essay + Phase-5 detail behind them. This is the single lever that pulls 316 lines toward budget and ends the duplication.
5. **retro-week** (meta, 5 weak) — **top fix: fix the broken engine path** (`~/site/skills/pandastack/scripts/retro-scan.sh` → `plugins/pandastack/scripts/...` or a resolved variable) so it doesn't silently break post-merge; then move the 175-line GC-sweep sub-protocol and shell-portability sediment out of the 488-line hot body.
6. **skill-creator** (meta, 5 weak) — **top fix: repoint or drop the dead `learnings/patterns/long-session-evals` reference** (cited 3×) that backs its non-negotiable hot/cold rule — a rule that cites missing evidence erodes its own authority. Fold the `.5` accretion phases.
7. **using-pandastack** (meta, 5 weak) — **top fix: drop the four inlined on-demand subsystems (session-ritual, loop-guard, harness-evolution, overlay-extension, L47–131) behind context pointers**, matching the two pointers it already uses; the overlay block especially is install-time reference a router contract rarely needs hot. Replace the hardcoded "26 skills" count with count-free phrasing (it drifts on every skill add).
8. **boardroom** (thinking, 5 weak) — **top fix: make `ops_dominant` routing deterministic** (keyword-count threshold, or "if ambiguous, do NOT add ops-lead") — it is the one place same-process determinism breaks. Collapse the sequential-vs-panel distinction (restated 6×) to the single mode table.

**Corpus-wide quick win (hits ~half the skills at once):** delete every "Common Rationalizations" table and `## Origin` changelog block. That single sweep clears the bulk of the Pruning debt (the 93%-weak axis) and pulls most over-budget bodies back toward the ~80-line guideline without touching any load-bearing step.

## What good looks like

Two skills earned **STRONG**, and they are the right two exemplars because they hit the discipline from opposite ends of the size scale:

- **freeze** (doing, 39-line body) — *the minimal exemplar.* It does exactly one thing and says so in seven body lines: parse an edit allowlist, announce, then refuse out-of-scope edits with a fixed, greppable message and an explicit "never silently skip". The ordered On-Invoke sequence is deterministic, unfreeze is co-located as the obvious paired branch (no over-split), and there is zero sediment — no rationalizations table, no Origin block, nothing over-pushed. Its single soft spot (a leading word that restates the description) is the smallest weakness in the entire corpus. **This is the shape every guard/verb skill should converge toward: one job, one ordered process, one exact refusal string, nothing else.**

- **writing-great-skills** (meta, 48 non-blank lines) — *the self-applying exemplar.* It is the SSOT for the very scorecard everything else is judged by, and it obeys the discipline it teaches: it names the root virtue (predictability) **once** and never restates it, collapses its own restatements into leading words, and pushes every defined term to a single-source GLOSSARY via a context pointer instead of redefining inline. The scorecard is a faithful condensation — each of the 8 axes traces back to a named section above it, so skill-eval scores against the same vocabulary the prose builds and the two cannot drift. **It proves the rules are livable: a reference doc that practices its own pruning and progressive-disclosure rules under the same budget it imposes on others.**

The lesson the two share: STRONG is not earned by adding more, it is earned by cutting until only the load-bearing process remains. Every SOLID-but-debt-heavy skill above is one Pruning sweep and one Completion-check away from the same standard.
