---
type: skill-eval
skill: handover
bucket: doing
evaluated_skill_hash: 91bd03c344d6a7785ab686a83d7c1eb2ee7168f7
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — handover

**Verdict: SOLID.** Exemplary progressive disclosure: the SKILL.md stays a tight orchestration layer while every `codex exec` mechanic, payload schema, and classification table lives behind one shared pointer to `references/codex-invocation.md`.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L60 — the 5-check "Gate (both modes)", each ending in a hard `stop`, plus the numbered sync Flow (L72) fix the delegate-poll-classify process every run |
| Description / invocation | pass | L4 — front-loads "Explicit Codex handover workflow", lists the sync/async branches, carries a reach-disambiguating NOT clause |
| Completion criteria | weak | L94 — "Best-effort: skip silently if the binary is absent" is an uncheckable done-condition for the state-emission step; a silent skip is indistinguishable from a forgotten step |
| Information hierarchy | pass | L70 — XML payload, result schema, sandbox-escape gate, and classification table are all pushed to `references/codex-invocation.md` and pulled only on demand; SKILL.md keeps only the orchestration sequence |
| Leading words | pass | L62 — "this skill is a no-op (delegation would recurse)" anchors the platform gate in one pretrained concept; "session occupancy" (L58) anchors the sync/async axis |
| Pruning | weak | L40/L42 — the economics paragraph restates the L40 ship-vs-delegate distinction at length, and the negative-scope clause is stated three times (L7 description, L32 routing list, L49 skip line). Real duplication, not length: the skill is only 59 non-blank body lines, so this is a tidy-up, not sprawl |
| Granularity | pass | L70 — the split to `references/codex-invocation.md` earns its load: it is independently reached by `/sprint --delegate codex` (per that file's own header), not a single-use cut |
| pandastack conformance | pass | L1-23 — `name` matches folder, `forbids` lists the three push variants, `classification: exec`, and every `reads:` path resolves. On length it is the leanest skill in the batch: 111 total / 59 non-blank body lines, at or under the ~80 budget that its siblings (ship 183, team-orchestrate 218, review 286, sprint 346) blow past. The verbosity nit lives on the Pruning axis; conformance itself is clean |

## Why it's good
The skill nails the hardest part of a delegation verb: it keeps Claude as the git/review/ship owner and shoves the brittle `codex exec` mechanics behind a context pointer, so the SKILL.md reads as pure orchestration. The Gate (L60-66) is genuinely exhaustive and each check fails closed with a named stop reason. The mode table (L53-56) plus the "session occupancy, not cost" framing (L58) kills the most likely confusion — that async is cheaper — in one line.

## Top fixes
1. L94 — give the state-emission step a checkable criterion (e.g. "event appended OR binary confirmed absent"), not a silent best-effort skip that hides partial failure.
2. L42 — cut the economics paragraph to one sentence; the quota point and the ship-vs-delegate distinction are already made at L40, so the rest pays context load to restate rationale the executing agent does not act on.
3. L32 / L49 — the Routing Boundary "Do not use it for" list and the "Skip when" line both restate the description's L7 NOT-clause. Keep the Routing Boundary table, drop the overlapping prose. (This is a tidy-up, not a length fix: the body is already lean at 59 non-blank lines.)

## Behavioral cases
- trigger `/handover pro-31` with a plan holding ≥3 rote build units → expected process: run the L60 gate, derive non-passing U-IDs from acceptance checks (L74), build the XML payload, spawn `codex exec` in background, poll in foreground, classify the single result per the reference table, then Claude commits a `completed` batch and keeps review/ship.
- anti-trigger `ship this finished work / open the PR` → should NOT fire; routes to `ship` (L37 excludes closing finished work, PR, publishing). Handover only delegates already-planned, unfinished mechanical units.
