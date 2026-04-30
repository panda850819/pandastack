---
name: dev-flow
description: Full development lifecycle from requirement lock to learning extraction, covering feature work, bug fixes, and refactors.
type: lifecycle-flow
---

# Dev Flow

> Triggered whenever new feature work, a bug fix, or a non-trivial refactor begins. The flow runs from requirement clarity through code review and ship, and ends only when a learning has been extracted and committed. Its purpose is to prevent the two most common failure modes in solo/small-team dev: starting without a clear scope, and finishing without capturing what was learned.

## Trigger

- Opening a new feature branch or creating a Linear/Jira ticket
- "I need to build X", "fix this bug", "refactor Y"
- Any code change touching 3+ files or crossing a module boundary

Skip to Phase 3 (careful gate) for hotfixes where scope is unambiguous and time is critical.

## Phases

### Phase 1 — Brief (requirement lock)

- **What happens**: Clarify what is being built and why before any code is written. For tasks under 1 hour (single function, config toggle, obvious rename), skip to Phase 2.
- **Skills used**: `pandastack:grill` (default adversarial mode to surface hidden constraints; `--mode structured` for formal specs)
- **Output**: A short requirement statement or acceptance criteria block, written inline in the ticket or as a comment in the relevant work-vault file

### Phase 2 — Plan (implementation design)

- **What happens**: Break the requirement into a file-level plan. Name which files change, what the interface looks like, which tests cover it. For single-file edits, skip this phase.
- **Skills used**: Native `/plan` command (built into Claude Code)
- **Output**: Numbered implementation steps, confirmed by user before any writes begin

### Phase 3 — Careful gate (production / shared infra check)

- **What happens**: Before touching production code, shared infra, published APIs, or database migrations, pause and surface a confirmation gate. Low-risk dev-only changes pass through automatically.
- **Skills used**: `pandastack:careful`
- **Output**: Explicit user confirmation or explicit skip. Never silently passed.

### Phase 4 — Build

- **What happens**: Implement the approved plan. One variable at a time; stop tweaking after plateau and look for structural gaps. Iron Law: no claiming done without passing type check and build.
- **Skills used**: Native editor tools; `pandastack:checkpoint` to save working state at logical milestones
- **Output**: Working code, passing `tsc` + build with no type errors

### Phase 5 — QA (UI changes only)

- **What happens**: For any user-facing change (UI, API endpoint, page), run browser-based verification against the actual rendered result. Backend-only changes skip this phase.
- **Skills used**: `pandastack:qa`
- **Output**: Verified on-screen state matching expected behavior, documented with a screenshot path or pass/fail note

### Phase 6 — Review

- **What happens**: 3-pass code review: correctness, edge cases, style. Cross-check with Codex when available for independent perspective.
- **Skills used**: `pandastack:review`
- **Output**: Review comments addressed; reviewer sign-off or self-sign-off with explicit reasoning

### Phase 7 — Ship

- **What happens**: Commit, push, open PR. Follow Conventional Commits. No `--no-verify`. No force-push to main.
- **Skills used**: `pandastack:ship`
- **Output**: PR open, CI green, or CI failure investigated before marking done

### Phase 8 — Extract (learning)

- **What happens**: Extract one concrete learning from the build — a debugging pattern, architecture decision, pitfall, or counterfactual. Replaces standalone `pandastack:compound`. Skip only if the build was genuinely trivial.
- **Skills used**: `pandastack:work-ship` (Stage 2 Extract logic) or inline write to `docs/learnings/`
- **Output**: One entry under `docs/learnings/<category>/<slug>.md` (categories: patterns / pitfalls / architecture)

## Exit criteria

- PR merged (or deliberately closed with documented reason)
- At least one learning written to `docs/learnings/` or an explicit "no new insight" note in the ship log
- No open type errors or build failures

## Anti-patterns

- **Skip Phase 1 on 3+ file changes**: scope creep is invisible until it is too late. Even five minutes of grill pays back hours of rework.
- **Skip Phase 2 and "figure it out as you go"**: plan-skipping compresses research + decision + execution into one noisy context. The model drifts toward the first plausible fix.
- **Mock the database on integration tests**: this is the most common way to ship code that looks correct but fails in production. Test against real state or an accurate fixture.
- **Amend already-pushed commits**: causes silent divergence. Create a new commit with a `fix:` prefix instead.
- **Mark done without running tests**: "should work" is not evidence. CI must be green or failure must be understood.

## Skill choreography

```
grill (--mode structured)
  |
  v
/plan (built-in)
  |
  v
pandastack:careful  [gate: prod/infra only]
  |
  v
[build]
  |
  v
pandastack:qa  [gate: UI only]
  |
  v
pandastack:review
  |
  v
pandastack:ship
  |
  v
pandastack:work-ship (Stage 2 Extract → docs/learnings/)
```
