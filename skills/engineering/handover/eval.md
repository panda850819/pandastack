---
type: skill-eval
skill: handover
bucket: engineering
evaluated_skill_hash: 0e2490858a426a445ac476f6c3b80fd0e3f85e98
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — handover

**Verdict: WEAK.** Leading virtue: a fail-closed 5-gate precondition block plus exemplary hot/cold split — the SKILL.md stays a pure orchestration layer while every brittle `codex exec` mechanic lives behind one shared pointer. Banded WEAK by the three independent weak axes (≥2 weak → WEAK): duplicated identity prose (HOT description restated in body), an uncheckable silent-skip on state emission, and repeated negative-scope clauses. None is a fail, and the four pass axes are real, so the fixes are cheap — collapsing the duplication alone clears two of the three.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L60 — the five-check "Gate (both modes)", each ending in a hard `stop`, plus the numbered sync Flow (L72) fix the delegate-poll-classify process every run; state is derived from git/acceptance (L74), not model whim. |
| Description / invocation | weak | L4 — the full `/ship`-vs-`/handover` distinction sits in the HOT description and is restated almost verbatim in the body at L40; HOT fields should carry triggers + the reach clause, not body-identity prose that pays context load every turn. |
| Completion criteria | weak | L94 — "Best-effort: skip silently if the binary is absent" is an uncheckable done-condition for the state-emission step; a silent skip is indistinguishable from a forgotten step. |
| Information hierarchy | pass | L70 — the XML payload, result schema, sandbox-escape gate, and classification table are all pushed to `references/codex-invocation.md` and pulled only on demand; SKILL.md keeps only the orchestration sequence. |
| Leading words | pass | L58 — "session occupancy, not cost" anchors the async/sync axis in one concept; L62 "this skill is a no-op (delegation would recurse)" anchors the platform gate; L89 "loop-in-agent" anchors the state event. |
| Pruning | weak | L42 — the economics paragraph re-explains the L40 ship-vs-delegate distinction at length, and the negative-scope clause lands three times (L7 description, L32 routing list, L49 skip line); the single-source rule should collapse these. |
| Granularity | pass | L70 — the split to `references/codex-invocation.md` earns its load: the file is independently reached by `/sprint --delegate codex` (its own header, ref L3), so the cut serves independent reach, not a single-use push. |
| pandastack conformance | pass | L2 — `name: handover` equals the folder; `reads`/`writes`/`forbids` are spec-sanctioned advisory metadata; body is 59 non-blank lines (<80); the ~800-token ref loads hot, correctly under the 5K dispatch threshold; both pointers resolve. |

## Why it's good
The skill nails the hardest part of a delegation verb: Claude stays the git/review/ship owner and the brittle `codex exec` mechanics live behind one context pointer (L70), so the body reads as pure orchestration. The Gate (L60–66) is genuinely exhaustive — platform, sandbox-escape, availability, repo-root, plan-precondition — and each check fails closed with a named stop reason, so the skill cannot half-run. The mode table (L53–56) plus "session occupancy, not cost" (L58) kills the most likely confusion (that async is cheaper) in one line.

## Top fixes
1. L4 / L40 — collapse the duplicated `/ship`-vs-`/handover` distinction: keep the trigger + reach clause in the HOT description, state the distinction once in the body, cut the verbatim restatement (single source of truth, and the costliest duplication because the description is HOT).
2. L94 — give the state-emission step a checkable criterion (e.g. "event appended OR binary confirmed absent"), not a silent best-effort skip that hides partial failure.
3. L42 / L32 / L49 — the economics paragraph and the two negative-scope restatements all repeat the description's L7 NOT-clause; keep the Routing Boundary table, trim the overlapping prose.

## Behavioral cases
- trigger `/handover pro-31` with a plan holding ≥3 rote build units -> expected process: run the L60 gate, derive non-passing U-IDs from acceptance checks (L74), build the XML payload, spawn `codex exec` in background, poll in foreground, classify the single result per the reference table, Claude commits a `completed` batch and keeps review/ship.
- trigger `/handover --async pro-31` -> expected process: gates pass, write ONE self-contained handoff to `docs/handoffs/{date}-{slug}-codex.md` (L82), print the path + dispatch one-liner, never spawn codex, never touch git (L87).
- anti-trigger `ship this finished work / open the PR` -> should NOT fire; routes to `ship` (L37 excludes closing finished work, PR, publishing). Handover only delegates already-planned, unfinished mechanical units.
- anti-trigger `write the plan for the refactor` -> should NOT fire; routes to `plan` / `writing-plans` (L33).
- anti-trigger (on Codex / Gemini runtime) -> no-op by the platform gate (L62); delegation would recurse.
