---
name: execute-plan
description: |
  Subagent-driven plan execution. Dispatches each task in an approved plan to an
  isolated subagent with a verification gate before continuing. Use after a plan
  is approved (pandastack:grill, pandastack:brief, /plan, or any explicit written
  plan). Triggers on "execute the plan", "run the plan", "go ahead with the plan",
  "implement this step by step". Skip for single-file edits or tasks with no
  written plan.
---

# Execute-Plan

Subagent-driven execution of an approved plan. Borrowed from superpowers' isolation
pattern: each task runs in its own context firewall so one bad step cannot contaminate
later steps. Adapted for Panda's operator context — covers vault work, Yei/Abyss ops,
and code equally, not just coding.

## When to use

- A written plan exists (from `/plan`, `pandastack:grill --mode structured`, a brief,
  or any numbered step list the user approved)
- 3+ tasks that touch different files, systems, or contexts
- High-stakes work (Yei/Abyss ops paths, production infra, vault schema changes)
- User says "execute the plan", "go step by step", "run it with verification"

## When to skip

- Single-file edit or typo fix
- User says "just do it" / "no verification needed" / "skip gates"
- Plan has only one step

---

## Protocol

### Phase 0: Plan intake

Read the plan. If no written plan exists in this session, ask the user to provide one
before proceeding — do NOT generate a plan and immediately execute it in the same turn.
That bypasses the human review gate.

Confirm the plan is approved: either the user explicitly said "yes" / "go" after
reviewing, or they invoked this skill themselves. If unsure, ask once.

Extract tasks into a numbered list with:
- **Task N**: what to do
- **Scope**: files/systems/commands touched
- **Risk**: low / medium / high (high = irreversible, external, or financial)

Announce: "Executing plan — N tasks. High-risk steps will pause for confirmation."

### Phase 1: Execute tasks with isolation

For each task:

1. **Dispatch to subagent** (or run in focused context). Subagent prompt must be
   self-contained: include task goal, relevant file paths, any prior task output it
   depends on, and "report back: what you did, what files changed, any errors."

   **Model selection — main agent picks per task, do not inherit silently.** Pass
   `model:` explicitly on every Agent call. Default heuristic:

   | Task shape | Model | Why |
   |---|---|---|
   | Read-only / grep / file listing / orientation | haiku | No judgment, fast + cheap |
   | File edits, refactors, mechanical writes, structured execution | sonnet | Default — covers most plan steps |
   | Architectural decisions, deep cross-file reasoning, ambiguous trade-offs | opus | Reserve for the 1-2 tasks that actually need it |

   When in doubt, sonnet. Don't pay opus for mechanical work; don't starve
   architecture with haiku.

2. **Verification gate** before continuing to the next task:
   - Low risk: auto-verify (check file exists, command exit code, expected output).
     State result in one line. Continue.
   - Medium risk: auto-verify + show summary. Pause only if verification fails.
   - High risk: pause and show:
     ```
     GATE: Task N complete.
       Done: {what happened}
       Changed: {files/state}
       Reversible: yes/no
     Proceed to Task N+1? [y/n]
     ```

3. If verification fails (exit code, missing file, wrong output):
   - Stop. Report what failed and why.
   - Do NOT auto-retry. Ask the user whether to fix and continue, skip, or abort.

### Phase 2: Final verification

After all tasks complete, run the overall verification:
- Were all task outputs produced?
- Is the system in the expected post-plan state?
- Any side effects not covered by the plan?

Report:
```
Plan complete — N/N tasks done.
  [Task 1]: {result}
  [Task 2]: {result}
  ...
  [Any open issues]: {if any}
```

### Phase 3: Handoff

After execution, state which skill to run next if applicable:
- Code change → suggest `pandastack:review` before commit
- Knowledge note created → suggest `pandastack:knowledge-ship`
- Work topic closed → suggest `pandastack:work-ship`
- Published content → suggest `pandastack:write-ship`

Do NOT auto-chain into the next skill. State the suggestion and stop.

---

## Isolation rules (subagent dispatch)

When a task is dispatched to a subagent:

- The subagent prompt must be self-contained. Do NOT say "based on what we discussed"
  — include the specific context the subagent needs.
- Subagent scope: one task only. Do not bundle multiple tasks into one subagent call.
- Subagent model: `sonnet` by default. Use `haiku` for read-only/grep tasks. Use
  `opus` only if the task requires deep architectural judgment.
- If the task is a simple Bash command or file edit with no judgment needed, run it
  directly rather than spawning a subagent — subagents have overhead.

When NOT to use subagents:
- Read-only checks (ls, cat, grep) — run directly
- Single Edit/Write where the content is already known — run directly
- Bash commands where the output is needed immediately for the next decision — run directly

---

## Risk classification

| Scope | Risk level |
|---|---|
| Read-only (search, read, grep) | low |
| Vault file write (knowledge note, daily note) | low |
| Config file edit in `~/.claude/` or `~/.agents/` | medium |
| Code edit in `~/site/apps/` or `~/site/cli/` | medium |
| Work vault write | medium |
| Anything under `~/site/infra/` or `~/site/trading/` | high |
| External system (Notion, Linear, Slack, GitHub push) | high |
| Yei/Abyss protocol ops (contracts, treasury) | high |
| `rm`, `git reset --hard`, destructive ops | high — must confirm |

---

## Anti-patterns

- **Bundling all tasks into one big context**: kills isolation. One task = one scope.
- **Auto-chaining into the next skill**: always stop after Phase 3 handoff suggestion.
- **Skipping the verification gate on medium/high risk**: the gate is the point.
- **Generating a plan and executing it in the same turn**: requires human review in between.
- **Retrying on failure without telling the user**: surface failures, don't swallow them.
- **Spawning a subagent for a 1-line bash command**: overhead not worth it.

---

## Relationship to other skills

- **`pandastack:grill`** — surfaces the requirements before writing a plan. Run grill first if scope is fuzzy.
- **`pandastack:review`** — runs after execute-plan on code changes before committing.
- **`pandastack:careful`** — should already be active when touching prod/infra/ops paths. If not, invoke it before Phase 1.
- **`/plan`** — Claude Code's built-in plan mode. Compatible: use /plan to produce the plan, then invoke execute-plan to run it with gates.
- **`pandastack:ship`** — for committing and pushing after code execution. execute-plan does not commit.
