---
type: skill-eval
skill: handover
bucket: engineering
evaluated_skill_hash: 429e7aae8ce76e2f87362b84192cbbe31d7ffab2
evaluated_at: 2026-07-09
rubric: writing-great-skills@1.1.0
---

# Eval — handover

> 2026-07-09 re-validation (#170): the Boundary list shed its dead Hermes-era routing refs (`plan` / `writing-plans` / `subagent-driven-development` / `claude-code` / `opencode`), kept the raw-`codex exec` native competitor, and gained an `advisor` cross-reference (judgment IN vs build OUT). Axis evidence re-anchored; scores and verdict unchanged.

**Verdict: SOLID.** Fail-closed 5-gate preflight plus a clean hot/cold split keep the body a pure orchestration layer; costs one point for restating the Codex-quota economics across three sections.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L58 — the five-check "Gate (both modes)", each ending in a hard `stop`, runs before either mode, so every invocation takes the same derive→payload→spawn→classify path; state is derived from acceptance/git (L72), not model whim. |
| Description / invocation | pass | L4 — front-loads "Explicit Codex handover workflow", lists one trigger per branch (`/handover [slug]` L5, `--async` L6), and the NOT-clause (L7) fences plan-writing / ship / judgment-heavy work, cross-referencing `advisor` for the last. |
| Completion criteria | pass | L92 — state-emission carries a checkable, exhaustive done-condition: "Done when EITHER the `delegated` event is appended OR `scripts/pandastack-state` is confirmed absent" with the `[ -x ]` test named and "never skip silently". |
| Information hierarchy | pass | L68 — the XML payload, result schema, sandbox-escape gate, and status→action table are pushed to `references/codex-invocation.md`, pulled only when sync mode fires; the body keeps just the orchestration sequence. |
| Leading words | pass | L56 — "session occupancy, not cost" anchors the async/sync axis in one pretrained concept; L61 "already inside a sandbox… (delegation would recurse)" anchors the env/platform gate. |
| Pruning | weak | L40 — the "separate Codex quota / not double-paying" economic point recurs at L44 ("rather spend Codex quota") and L56 ("session occupancy… same subscription either way"); one meaning, three touches, collapsible to a single anchor. |
| Native parity | pass | L33 — names the native competitor as direct `codex exec` outside the protocol, while L68 gives the delta: verified invocation payload, result schema, sandbox gate, and classification table. |
| Granularity | pass | L68 — the cold split earns its load: the reference's own header shows both `/handover` (sync) and `/sprint --delegate codex` (batch loop) reach it, so the cut serves independent reach, not a single-use push. |
| pandastack conformance | pass | L30 — de-personalized: "an explicit pandastack `/handover`", description "you" (L7), Boundaries "the orchestrator" (L112) are generic/redistributable; `name: handover` (L2) matches the folder and `references/codex-invocation.md` (~1K tokens, under the 5K hot threshold) resolves. |

## Why it's good
The Gate (L58-64) is genuinely exhaustive — platform, env-guard, availability, repo-root, plan-precondition — and each check fails closed with a named stop reason, so the skill cannot half-run and both modes share one preflight. Reference extraction is disciplined: every brittle `codex exec` mechanic lives behind one shared pointer the body reaches twice, keeping the hot body as pure routing. The Boundary now points cross-runtime judgment at `advisor` (pull IN) and keeps `handover` strictly for build work (push OUT), so the inbound/outbound pair reads as one system without overlap.

## Top fixes
1. L40 / L44 / L56 — collapse the three restatements of the Codex-quota economics into one anchored sentence; keep the L56 "session occupancy, not cost" framing and drop the repeats in Routing Boundary (L40) and When-to-use (L44).
2. `references/codex-invocation.md:50` — the de-personalization missed the reference: it still reads "explicit one-time confirmation from Panda this session", contradicting SKILL.md L112's "the orchestrator". Same SSOT, one voice — sync the reference.
3. L104-106 — the "this reduces to `status: in_progress, owner: codex`" gloss is explanatory sediment the appended event already implies; trim it so the State-emission section earns its ~20 lines.

## Behavioral cases
- trigger `/handover pro-31` (plan with ≥3 rote, file-scoped build units) -> expected process: run the L58 gate, derive non-passing U-IDs from acceptance checks (L72), build the XML payload, spawn `codex exec` in background, poll in foreground, classify the single result per the reference table, Claude commits a `completed` batch and keeps review/ship, then append the `delegated` state event (L92).
- anti-trigger `ship this finished work / open the PR` -> should NOT fire; routes to `ship` (L34 excludes closing finished work, PR, publishing).
- anti-trigger `give me a second opinion on this design fork` -> should NOT fire; routes to `advisor` (L35), which pulls judgment IN — handover sends build work OUT to Codex and never reasons on your behalf.
