---
name: team-orchestrate
description: |
  Conductor-driven parallel execution. Dispatches N independent branches to subagents
  in a single message, each in its own git worktree, gates each branch as it returns.
  Use after a plan is approved AND its branches are genuinely independent (no shared
  files, no inter-branch dependencies). Triggers on /team-orchestrate, "run these in
  parallel", "fan out", "N branches independent". Skip for sequential work (use
  execute-plan) or single-track iterative work (use sprint).
reads:
  - repo: lib/capability-probe.md
  - repo: lib/persona-frame.md
  - repo: lib/skill-decision-tree.md
  - repo: lib/gate-contract.md
  - repo: skills/execute-plan/SKILL.md
  - cli: gbq
  - vault: knowledge/**
writes:
  - vault: Inbox/team-orchestrate-*.md
  - cli: stdout
  - git: worktrees + commits per branch
forbids:
  - file: /Users/panda/site/knowledge/work-vault/**
domain: shared
classification: lifecycle-flow
capability_required:
  - agents.md
  - vault
  - lib/persona-frame.md
  - lib/skill-decision-tree.md
  - skills/execute-plan
---

# Team-Orchestrate

Conductor-driven parallel execution. The third execution locus per `lib/skill-decision-tree.md`:

| Skill | Locus | Time ordering |
|---|---|---|
| `/sprint` | Main session executes | Single track |
| `/execute-plan` | One subagent per task | Sequential, gate between tasks |
| `/team-orchestrate` | N subagents at once | **Parallel**, gate per branch as it returns |

Main session is the conductor. It dispatches, reviews returns, merges. It does NOT edit during dispatch — that defeats both parallelism and worktree isolation.

## When to use

- Plan has N branches that are **truly independent** (no shared files, no inter-branch dependency)
- Wall-clock parallelism matters (e.g. running 4 audit passes that each take 5 min — serial = 20 min, parallel = 5 min)
- Each branch is large enough to justify subagent overhead (≥1 file edit, ≥1 verification step)
- User says "fan out", "run these in parallel", "N branches independent"

## When to skip

- Branches share files OR depend on each other's output → use `/execute-plan` (sequential gates)
- Single iterative task → use `/sprint`
- Branches would each take <2 min → serial in main session is faster than dispatch overhead
- Branch independence is unclear → default to `/execute-plan`, not this skill

---

## Protocol

### Phase 0: Branch intake

Read the plan / brief. Extract branches into a numbered list with:

- **Branch N**: what to do
- **Scope**: files/systems touched (must NOT overlap with other branches)
- **Risk**: low / medium / high
- **Worktree branch name**: `team-{slug}-{n}` (used for `isolation: "worktree"`)

**Independence audit** (mandatory): cross-check the file lists. If any two branches touch the same file, ABORT and route to `/execute-plan`. Independence is not optional — parallel writes to the same file under worktrees produce silent merge conflicts on conductor merge.

Announce: `Team-orchestrate intake — N branches, M-way parallel dispatch. Independence audit: PASS.`

### Phase 0.5: Persona routing per branch

Read `lib/skill-decision-tree.md` § "Persona routing table". For each branch, classify task signal → pick persona skill. Same routing as `execute-plan` Phase 0.5. Print routing block:

```
PERSONA ROUTING
  Branch 1 ({title}): {persona} — {why}
  Branch 2 ({title}): {persona} — {why}
  ...

  Override? [confirm / edit / dispatch all to <persona>]
```

User can override. Wait for confirmation.

### Phase 1: Parallel dispatch (single message, N Agent calls)

Build N dispatch prompts using inline-from-skill pattern (see `lib/persona-frame.md` § "Inline-from-skill dispatch pattern"):

1. Read each persona's `skills/{persona}/SKILL.md`
2. Extract 6 contract sections (Soul / Iron Laws / Cognitive Models / On Invoke / Anti-patterns / BAD-GOOD)
3. Inline persona block + hard rules + branch-specific brief at top of subagent prompt
4. Dispatch ALL branches in **one message** with multiple `Agent` tool calls:

```
Agent({
  description: "Branch 1 — {title}",
  subagent_type: "general-purpose",
  prompt: "{persona block + hard rules + branch 1 brief}",
  isolation: "worktree",
  model: "{per heuristic — sonnet default, opus for architect, haiku for pure read}",
})
Agent({
  description: "Branch 2 — {title}",
  ...
})
...
```

Single message, multiple tool-use blocks = wall-clock parallel execution per the Agent tool docs.

**Hard rules to inline in every dispatch**:
- Conventional Commits, body in English, no em dash, no Co-Authored-By trailer
- Voice: no sycophantic openers, no closing fluff
- Subagent must commit to its worktree branch before returning (conductor merges later)
- Subagent must NOT touch files outside its declared scope (independence guarantee)

### Phase 2: Gate-as-they-return

Subagent results arrive in a single tool-result block but are independently parseable. For each returned branch, in order of completion:

1. **Verify**:
   - Worktree branch exists and has commits
   - Files changed match declared scope (no scope creep into other branches)
   - Subagent's self-reported result matches actual state (read worktree files, don't trust the report)

2. **Per-branch gate** (`lib/gate-contract.md`):
   ```
   Branch N returned.
     Done: {what subagent reports}
     Worktree: {path}, branch: {branch-name}
     Files changed: {list}
     Scope match: PASS / FAIL
     Verification: PASS / FAIL

   [approve] merge to main and continue
   [edit]    user supplies revision instruction → re-dispatch this branch only
   [reject]  discard worktree, log as REJECTED, continue
   [skip]    leave worktree dangling, continue (user merges manually later)
   ```

3. On approve → `git worktree add` merge OR rebase branch into main (per user preference, default: merge no-ff)
4. On edit → re-dispatch only this branch with revision instructions, return to step 1
5. On reject → `git worktree remove` + branch delete
6. On skip → leave intact, log path

### Phase 3: Synthesis + handoff

After all branches resolved:

```
Team-orchestrate complete — N branches.
  Branch 1: APPROVED → merged ({commit-hash})
  Branch 2: REJECTED → worktree discarded
  Branch 3: APPROVED → merged ({commit-hash})
  ...
  Conflicts surfaced: {any cross-branch issues caught at merge}
  Open issues: {any deferred via skip}
```

Write `Inbox/team-orchestrate-{slug}-{date}.md` with:

```markdown
---
date: {YYYY-MM-DD}
type: team-orchestrate
topic: {topic}
branches: N
outcomes: {n_approved, n_rejected, n_skipped}
tags: [team-orchestrate]
---

# Team-orchestrate — {topic} — {date}

## Branch results

| Branch | Persona | Outcome | Commit / Note |
|---|---|---|---|
| 1 {title} | {persona} | APPROVED | {commit} |
| 2 {title} | {persona} | REJECTED | {reason} |
| ... | | | |

## Independence audit

PASS / file-overlap details if FAIL

## Gate Log

{per-branch gate decisions}

## OPEN_QUESTIONS

{anything skipped or deferred}
```

Suggest next skill if applicable (typically `/review` for cross-branch coherence check, then `/ship`). Do NOT auto-chain.

---

## Anti-patterns

- ❌ Skipping the independence audit — parallel writes to the same file = silent corruption at merge
- ❌ Conductor edits files during dispatch — defeats isolation, contaminates main branch state
- ❌ Bundling sequential dependencies as parallel branches ("branch 2 uses branch 1's output") — that's `/execute-plan`
- ❌ Using team-orchestrate for parallelism feel when branches really run <2 min each — dispatch overhead > savings
- ❌ Auto-merging on subagent return without verification — gate exists because subagent self-report drifts from actual worktree state
- ❌ Defaulting to team-orchestrate when independence is unclear — default is `/execute-plan` (sequential gates catch what parallel hides)
- ❌ Mixing personas within one branch — same rule as execute-plan, one branch = one persona

---

## Relationship to other skills

- **`/office-hours`** Stage 5 routes here when brief shape = "N branches independent, wall-clock parallel meaningful"
- **`/execute-plan`** is the safer cousin — when independence is uncertain, use that with sequential gates
- **`pandastack:review`** runs after team-orchestrate on the merged state for cross-branch coherence
- **`pandastack:ship`** runs after review for final commit / push / PR

## Origin

- `lib/skill-decision-tree.md` Q3 (2026-05-05) — defined the third execution locus, marked "future / two-strike pending"
- pandastack 2026-05-05 cut — built early because the decision tree's Q3 had no destination, leaving the architecture incomplete. User judgment: this is a structural hole, not an emergent pattern, so two-strike doesn't apply.
- Mirror of `skills/execute-plan/SKILL.md` Phase 0-3 structure, swapped sequential dispatch for single-message multi-Agent parallel.
