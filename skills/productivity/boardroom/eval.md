---
type: skill-eval
skill: boardroom
bucket: productivity
evaluated_skill_hash: 0f64410ea1248758a5cf88a0f550ab3169e2ad23
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — boardroom

**Verdict: WEAK.** Leading virtue is a principled two-mode mechanism (sequential coherence vs `--panel` independence) with a checkable per-finding `Apply? [Y/N/edit]` spine and real quorum aggregation; it lands at WEAK because four axes carry defensible flags: non-deterministic voice-scope (L88), a count-based completion step (L112), a boundary restated many times (L210/L42), and a 231-line body far over the ~80-line discipline (L1-231).

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | weak | L88 — `ops_dominant` ANDs fuzzy keyword-presence with a "dominant frame is feature/code/UX" judgment that has no tie-break; on a borderline plan the same input can route to a different voice-set across runs. This is where same-process determinism actually breaks. |
| Description / invocation | pass | L5 — front-loads the leading word "Multi-lens plan critique router", one-trigger-per-branch list, explicit `/boardroom` + NOT clause, no body-identity restated. (Missing `version`/`user-invocable` are spec-OPTIONAL per SKILL-FRONTMATTER.md, not an invocation defect.) |
| Completion criteria | weak | L112 — "Output 3-5 critiques in voice's posture" gates on a count, not a checkable done-condition; an agent can emit 3 shallow critiques and call the voice complete. Stage 0 (L77) and the gate loop (L122) are sharp; this one step is premature-completion bait. |
| Information hierarchy | pass | L75 — capability-probe pushed behind `@../../../lib/...` pointer; per-voice contracts pushed to each voice's SKILL.md via `lib/persona-frame.md` rather than inlined; co-location of each Stage's rules under its heading. Progressive disclosure held. |
| Leading words | pass | L138 — "quorum-aggregate", "mutually-blind" (L36), "cold subagents" (L130), "uncorrelated errors across lenses" (L64) anchor the panel mechanism in pretrained concepts in few tokens. |
| Pruning | weak | L210 — the sequential-vs-panel distinction is restated at least six times (L36, the L61-67 table, L69, L79, L210, L221) and the "single-domain / plans not problems" boundary three more (L42, L53, L225); the table is the SSOT and the prose is duplication. Compounding it, the `## Origin` section (L227-231) is pure changelog sediment ("deleted v1.1", gstack-collapse history) — provenance that changes no behaviour and belongs in a commit message, not the hot body. Together these push the body to 231 lines. |
| Granularity | pass | L126 — Stage 2 vs Stage 2-PANEL earns its load: opposite mechanism (mutual blindness, independent reach), and panel dispatches cold subagents (L130) instead of loading four sibling SKILL.md hot; the cut is anti-correlated-error, not a premature-completion artifact. |
| pandastack conformance | weak | L1-231 — `name: boardroom` = folder and all ten `reads:` refs resolve (verified), so paths and required fields pass; but the body is 231 lines (~3× the ~80-line discipline in writing-great-skills L54/L81) and default-mode Stage 2 (L100-124) hot-loads ~6K of voice+lib reference into the main context without the >5K sub-agent dispatch that `--panel` (L130) correctly uses. |

## Why it's good
The Modes table (L61-69) is the load-bearing asset: it turns the sequential/panel choice into a one-glance decision keyed to stakes, with mechanism, optimization target, cost, and failure-cure in one cell-set. The per-finding `Apply? [Y/N/edit]` gate (L113-122) routed through `lib/outside-voice-rule.md`, plus the stop-rule and escape-hatch (L122-123), make the skill checkable and interruptible. Panel mode's quorum-aggregation (L138-142) with an explicit "never drop single-voice findings" rule (L142) is a correct defence against consensus-washing, and every reference resolves.

## Top fixes
1. **L88** — make `ops_dominant` deterministic: a keyword-count threshold, or "if the frame is ambiguous, do NOT add ops-lead." Voice-scope is the one place the process diverges across runs; pin it.
2. **L112** — replace "Output 3-5 critiques" with a coverage criterion (e.g. "check every Iron Law against the plan; emit a finding per law that fires") so per-voice completion is a done-condition, not a count.
3. **L210 / L42 / L227** — collapse the restatements toward budget: let the L61-69 Modes table be the single source for the sequential-vs-panel split and cut the prose duplicates (L36 intro, L69, the L221 anti-pattern re-explanation, the L208-217 ordering preamble); fold "When to invoke"/"When to skip" (L44-55) into the Routing Boundary; and delete the `## Origin` changelog tail (L227-231) — provenance belongs in git, not the hot body. This is the main lever to pull the 231-line body back toward the ~80-line discipline.

## Behavioral cases
- trigger `/boardroom plans/q3-launch.md --panel` -> expected process: Stage 0 probe + load plan, announce `boardroom mode: panel (independent)`, Stage 1 scope (CEO+product+design+eng; ops only if coordination-dominant), dispatch all voices as cold mutually-blind subagents on the original plan, quorum-tag each cluster `[high-confidence/corroborated/investigate]`, gate per finding via `lib/outside-voice-rule.md`, write `Inbox/boardroom-q3-launch-2026-06-26.md`.
- trigger `review this PRD, 4-voice critique` -> expected process: default sequential Stage 2, CEO->product->design->eng, each voice sees prior applied patches, per-finding gate, Stage 3 synthesis with Gate Log + final plan diff.
- anti-trigger `grill me on this scope` -> should NOT fire; routes to `/grill` (boardroom is for prepared plans, not problems; L54).
- anti-trigger `the login button is misaligned, fix it` -> should NOT fire; single-domain tactical execution routes to `/design-lead` or `/eng-lead` directly (L53-54).
