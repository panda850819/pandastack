---
type: skill-eval
skill: team-orchestrate
bucket: engineering
evaluated_skill_hash: 6b943a6ca8445198f31825ae3f8b14b641ec9f98
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — team-orchestrate

**Verdict: WEAK.** Leading virtue is a sharp, checkable conductor protocol with a mandatory independence audit; it loses points to a broken default-persona read path (L85), 196-line body sprawl driven by an inlined artifact template, and a gate rendered as a printed menu instead of the `AskUserQuestion` its own cited contract mandates.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | weak | L85 — hardcodes `Read each persona's skills/productivity/{persona}/SKILL.md`, but the default persona `eng-lead` (skill-decision-tree.md L85) lives in `skills/engineering/eng-lead`, and only ceo/design-lead/product-lead/ops-lead are under `productivity/`; the most common branch dispatch reads a nonexistent file, so the same process diverges per persona. |
| Description / invocation | pass | L4 — front-loads "Conductor-driven parallel execution", one trigger per branch (`/team-orchestrate`, "run these in parallel", "fan out", "N branches independent"), explicit anti-trigger routing sequential work to sprint. No body-identity restated. |
| Completion criteria | pass | L62 — independence audit is checkable AND exhaustive-where-it-matters (cross-check file lists, ABORT on any overlap); each phase ends on a checkable artifact (L64 announce, L119 PASS/FAIL verification, L131 gate). |
| Information hierarchy | pass | L83 — persona-dispatch mechanics pushed behind a `lib/persona-frame.md` pointer; gate schema behind `lib/gate-contract.md` (L122); steps stay inline, co-location held under each Phase heading. |
| Leading words | pass | L33 — "conductor" anchors the orchestration model in a pretrained concept ("It dispatches, reviews returns, merges. It does NOT edit during dispatch"); reinforced by "gate-as-they-return" (L113). |
| Pruning | weak | L158 — the full Inbox artifact template (YAML frontmatter + results table + audit + gate-log + OPEN_QUESTIONS, L158-189) is reproduced inline, the main driver of a 196-line body; anti-patterns L200/L202 also near-restate When-to-skip L46/L47. |
| Granularity | pass | L81 — Phase 1 (parallel dispatch) earns its split via independent subagent reach; Phase 2 (gate-as-they-return) earns its split as anti-premature-completion (gate blocks auto-merge on self-report drift, L201). |
| pandastack conformance | weak | L131 — gate is printed as a `[approve]/[edit]/[reject]/[skip]` text menu, but the cited `lib/gate-contract.md` L27 mandates the `AskUserQuestion` tool; compounded by a 196-line body (>> ~80) not clearly earning the length and the L85 broken persona path. |

## Why it's good

The conductor leading word does real work: it fixes a single execution model (dispatch / review / merge, never edit) that the whole protocol hangs off, and the mandatory independence audit (L62) with a hard ABORT is the load-bearing safety gate that justifies parallelism existing at all. Phase boundaries are checkable and the gate explicitly distrusts subagent self-report (L201, "read worktree files, don't trust the report"), which is exactly the predictability discipline the rubric rewards. All four `lib/` context pointers resolve and the named sections they cite actually exist.

## Top fixes

1. L85 — fix the persona read path. `eng-lead` is the default persona (skill-decision-tree.md L85) but lives in `skills/engineering/eng-lead`, not `skills/productivity/`. Note deferring to `lib/persona-frame.md`'s resolve chain (L55-58) does NOT fix this: that chain hardcodes the same wrong assumption (L57 "all 5 personas live in the `productivity` bucket"), so it also misses `eng-lead`. The real fix is to correct the bucket map in both the skill (L85) and persona-frame.md (L57) so the default `eng-lead` resolves to `skills/engineering/`, or to drive resolution off the host plugin-resolver (persona-frame L56a) instead of any hardcoded bucket. The current hardcode breaks the most common dispatch.
2. L158-189 — push the Inbox artifact template behind a context pointer (a `references/inbox-template.md` or a `lib/` ref). Inlining the full YAML+table+log skeleton is the bulk of the 196-line overrun; the body should keep "write `Inbox/...` per the template" and let the template load cold.
3. L131-135 — reconcile the gate rendering with the cited contract. `lib/gate-contract.md` L27 says invoke `AskUserQuestion`; the skill prints a bracketed text menu. Either state "use `AskUserQuestion` per gate-contract" or note the deliberate divergence, so the cited SSOT and the step agree.

## Behavioral cases

- trigger `/team-orchestrate run these 4 audit passes in parallel, no shared files` -> expected process: Phase 0 branch intake + independence audit (PASS) -> Phase 0.5 persona routing per branch with override gate -> Phase 1 single message with 4 `Agent` worktree dispatches -> Phase 2 gate each return (verify worktree, scope match, PASS/FAIL) -> Phase 3 synthesis + Inbox artifact, suggest /review, no auto-chain.
- anti-trigger `sprint on adding the export button, iterate as I go` -> should NOT fire (routes to `/sprint`; single iterative track, main-session executes, per When-to-skip L45 and skill-decision-tree Q1).
- anti-trigger `do these 3 steps in order, step 2 needs step 1's output` -> should NOT fire (sequential dependency; routes to N sequential sprints per When-to-skip L44 / Anti-pattern L199).
