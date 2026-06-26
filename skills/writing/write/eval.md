---
type: skill-eval
skill: write
bucket: writing
evaluated_skill_hash: f32bd460ef4ce1d173711088137409cb24a2a607
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — write

**Verdict: SOLID.** A genuinely predictable multi-mode writing skill whose anti-ghostwriting and anti-slop discipline is enforced by checkable self-checks and a mandatory output-validation gate, but it is over its length budget and carries duplication between the description, the Routing Boundary, and repeated "failure mode this exists to prevent" prose.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L40 — mode-selection table maps each user signal to one route, so the same input drives the same process every run |
| Description / invocation | weak | L4 — front-loaded leading phrase is good, but the trigger list is long and its NOT-for clauses are re-stated almost verbatim in the body (L16-17), inflating HOT context |
| Completion criteria | pass | L382 — "If any check fails, fix BEFORE responding" makes output-validation a hard, checkable gate; reinforced by per-mode self-checks (L69, L94, L135, L177) |
| Information hierarchy | pass | L104 — conditional reference-loading table is textbook progressive disclosure: heavy slop refs pushed behind trigger-gated context pointers, loaded only when their signal fires |
| Leading words | weak | L26 — "sparring partner, structure coach, and slop detector" anchors roles, but most mode prose ("Cut filler", "Suggest stronger openings") restates default behaviour rather than collapsing to a pretrained anchor |
| Pruning | weak | L222 — "...exists to prevent" is a repeated justification template (also L230, L292) and the body re-derives the description's routing exclusions (L16-17); body runs 390 lines, far past pandastack's ~80 |
| Granularity | pass | L61 — the 8 modes are split by distinct leading word / subcommand (`/write spar` vs `/write edit` vs `/write postmortem`), each an independent reach, so each cut earns its keep |
| pandastack conformance | weak | L102 — `lib/quality-rubric.md` resolves only from repo root, not the skill dir; with the body well over 5K tokens of hot reference plus many hot ref-loads, the hot/cold dispatch rule is strained and length is unearned in places |

## Why it's good
The skill turns a stochastic "help me write" request into a deterministic router: a single signal-to-route table (L40) plus eight modes each ending on a checkable self-check (L69, L94, L135, L177, L284) and a mandatory pre-send output-validation gate (L380-382). Its anti-ghostwriting stance is not a slogan — it is enforced structurally with restart-on-violation rules (L52, L209) and "convert to annotations" self-checks. The conditional reference-loading tables (L104, L355) are a clean application of progressive disclosure, keeping the large slop-pattern corpus cold until a concrete trigger fires.

## Top fixes
1. L16-17 — the Routing Boundary's "Do not use it for" bullets duplicate the description's NOT-for clauses (L4). Keep the routing in one place; cut the body restatement or reduce the description to leading phrase + trigger list only.
2. L222 / L230 / L292 — collapse the repeated "...exists to prevent" justification passages into a single co-located note; they are sediment that pays load to restate the same kind of justification three times.
3. L102 — make the `lib/quality-rubric.md` pointer resolve unambiguously from the skill (relative path is repo-root-relative, not skill-relative); and given the body's hot weight, state the hot/cold dispatch posture explicitly so a >5K-token load dispatches a sub-agent.

## Behavioral cases
- trigger `should I write about this? here's originals/2026-06-01-x.md` → expected process: Idea Gate mode (L50, L226) — Stage-0 brain grep (L243), pick one of five routes, emit a writer context packet or 暫不寫, hand off to `/write spar`.
- anti-trigger `make this ChatGPT text sound human` → should NOT fire (routes to `humanizer` per L16); and final IC/investment memo cleanup routes to `avoid-ai-writing` (L17).
