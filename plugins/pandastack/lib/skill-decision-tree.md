# lib/skill-decision-tree.md — Workflow shape → execution skill

> Shared module. Loaded by `office-hours` (Stage 5 next-skill recommendation), `sprint` (Stage 3 persona-routing reference), `boardroom` (post-critique handoff), and any other Layer 1 flow skill that needs to recommend the next execution step.
>
> Origin: 2026-05-05 — office-hours produced briefs but did not point to the next skill. `/sprint`, `/execute-plan`, and (future) `/team-orchestrate` had overlapping framing without a clean differentiator. This lib defines the sharp distinction by **execution locus** (who actually does the work) and provides a 3-question decision test.

## The sharp distinction: execution locus

Don't pick by time-box, task count, or topic. Pick by **who executes**:

| Skill | Main session role | Executor | Context isolation | Time ordering |
|---|---|---|---|---|
| `/sprint` | **Executor itself** | Main session (you + the AI in same context) | None — same context throughout, persona is a cognitive lens | N/A (single track) |
| `/execute-plan` | **Coordinator** | Subagent per task | Fresh context per task (avoid pollution + verify gates) | Sequential, gate between tasks |
| `team-orchestrate` (future, two-strike pending) | **Conductor** | N subagents at once | Fresh context per branch + worktree isolation | Parallel, gate per branch as it returns |

## 3-question decision test

Ask in order. First Yes wins.

### Q1: 「我要不要邊做邊 iterate / debug / 改方向？」

If yes → **`/sprint`**. Reason: iteration is cheap when the executor is in-session. Subagent dispatch loses iteration ergonomics (each iteration = new dispatch, expensive context rebuild).

If no, the work is already specified clearly enough to hand off → continue to Q2.

### Q2: 「N 步之間需要 verify gate？某步需要 fresh context 避免污染？」

If yes → **`/execute-plan`**. Reason: gates between sequential subagent dispatches catch cross-task drift; fresh context per task prevents accumulated pollution from breaking later steps.

If no, steps are independent (no inter-step verification needed) → continue to Q3.

### Q3: 「N 個元件互相獨立，wall-clock 平行有意義嗎？」

If yes → **team-orchestrate** (future skill). Until skill exists, use raw `Agent` tool with `isolation: "worktree"` per parallel dispatch, and conductor (main session) reviews/merges as agents return.

If no → reconsider entry. The work likely fits Q1 or Q2 better, or the framing is wrong.

## Brief shape → skill mapping

Use this when reading an office-hours brief or boardroom synthesis:

| Brief shape | Skill |
|---|---|
| "Ship X in 1-2 hr; iteration expected" | `/sprint` |
| "These N steps in order, each needs verify" | `/execute-plan` |
| "These N branches can advance independently" | team-orchestrate (raw Agent for now) |
| "I need a brief / I have a fuzzy idea" | (you're earlier in the flow — `/office-hours` first) |
| "Plan critique needed" | `/boardroom` (read brief, return findings, then route per Q1-Q3) |

## Persona dispatch is orthogonal

Persona (architect / eng-lead / design-lead / ops-lead / product-lead / ceo) is **not the same axis** as execution locus. Personas can be used in any of the 3 execution modes:

| Skill | Persona usage |
|---|---|
| `/sprint` | Stage 3 detects task shape, loads ONE persona's SKILL.md as in-session lens (main session reads + applies the iron laws as cognitive frame). No subagent. |
| `/execute-plan` | Phase 0.5 picks persona per task. Phase 1 dispatch uses inline-from-skill pattern (read SKILL.md → inline contract into subagent prompt → dispatch as `general-purpose`). See `lib/persona-frame.md` § "Inline-from-skill dispatch pattern". |
| team-orchestrate | Same as execute-plan but parallel (multiple subagent dispatches in one message, per `Agent` tool docs). |

Persona routing table (shared with `pandastack:execute-plan` Phase 0.5):

| Task signal | Persona skill |
|---|---|
| Tech stack 選型 / DB schema / 服務拓撲 / API contract / non-functional reqs | `pandastack:architect` |
| Code edit / refactor / debug / fix / feature impl / ship | `pandastack:eng-lead` |
| UX / layout / accessibility / visual hierarchy / interaction design | `pandastack:design-lead` |
| Multi-team coord / process design / SLA / runbook / handoff / on-call | `pandastack:ops-lead` |
| Feature scoping / metric / PMF / pricing / user research | `pandastack:product-lead` |
| Kill / pivot / scope cut / strategic frame / cross-axis prioritization | `pandastack:ceo` |
| Default (no clear signal) | `pandastack:eng-lead` |

## Anti-patterns

- ❌ Picking skill by time-box (1-2 hr → sprint regardless) — execution locus matters more than duration
- ❌ Picking skill by task count (3+ tasks → execute-plan regardless) — a 5-task sprint with iteration is still sprint, not plan
- ❌ Pick `/sprint` then spawn multi-agent inside Stage 3 — defeats single-track discipline; that's `/execute-plan` or team-orchestrate
- ❌ Pick `/execute-plan` for a single iterative task — subagent dispatch overhead not justified; use sprint
- ❌ Mixing personas in a single `/sprint` topic — sprint is single-track single-persona; if scope spans personas, split topic and run multiple sprints OR use execute-plan with Phase 0.5 routing
- ❌ Skipping the 3-question test ("I'll figure it out") — the test takes 30s, picking wrong skill costs 30 min of wrong-flow execution
- ❌ Defaulting to team-orchestrate for parallelism feel — true parallelism requires independent branches AND worktree isolation that's been smoke-tested; default to sequential execute-plan if unsure

## When this lib is loaded

- `office-hours` Stage 5 — read this lib to recommend next skill in the brief
- `sprint` Stage 3 — read this lib for persona routing table (single-persona in-session lens)
- `execute-plan` Phase 0.5 — same routing table, but for subagent dispatch
- `boardroom` Stage 4 — recommend follow-up skill after critique synthesis

## See also

- `lib/persona-frame.md` § "Inline-from-skill dispatch pattern" — operational details for subagent dispatch
- `lib/capability-probe.md` — substrate availability check, runs at start of every flow skill
- `pandastack:execute-plan` SKILL.md — concrete implementation of Phase 0.5 routing
