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

- A written plan exists (from `/plan`, `pandastack:office-hours`, a brief,
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

### Phase 0.5: Persona routing

For each task, classify by **task shape** and pick the dispatch persona. Do NOT default everything to eng-lead — that defeats the routing purpose and over-fits architecture / UX / ops tasks to the implementation lens.

@../../lib/skill-decision-tree.md is the source of truth for the routing table. The table below is a rendered copy for convenience; if the two drift, `lib/skill-decision-tree.md` wins.

**Routing table (task signal → persona skill)**:

The persona name maps to a `pandastack:<persona>/SKILL.md` whose content gets inlined into the dispatch prompt (see Phase 1 dispatch shape).

| Task signal | Persona skill | Why |
|---|---|---|
| Tech stack 選型 / DB schema / 服務拓撲 / API contract / non-functional reqs (perf / cost / scale / security target) | `pandastack:architect` | Surfaces alternatives, names one-way doors, designs seams. Implementation comes later. |
| Code edit / refactor / debug / fix / feature impl / ship | `pandastack:eng-lead` | Minimal diff, root cause, no spiral. Default for most code work. |
| UX / layout / accessibility / visual hierarchy / interaction design | `pandastack:design-lead` | Intentional over decorative, anti-slop. |
| Multi-team coord / process design / SLA / runbook / handoff / on-call | `pandastack:ops-lead` | Builds systems that run without you. |
| Feature scoping / metric / PMF / pricing / user research / 推銷 | `pandastack:product-lead` | User problems over solutions. |
| Kill / pivot / scope cut / strategic frame / cross-axis prioritization | `pandastack:ceo` | Multi-framework strategic lens. |
| Bash one-liner / file copy / mechanical config edit (no judgment) | inline (no subagent) | Subagent overhead not worth it |
| **Default (no clear signal)** | `pandastack:eng-lead` | Most plan tasks are code work |

**Routing output format** (print as opening block before Phase 1):

```
PERSONA ROUTING
  Task 1 ({short title}): {persona} — {one-line why}
  Task 2 ({short title}): {persona} — {one-line why}
  ...

  Override? [confirm / edit / dispatch all to <persona>]
```

User can override. Common overrides:
- "all eng-lead" — for purely code-execution plans, skip the routing layer
- "task 3 should be architect not eng-lead" — surface the missed signal
- "skip persona, dispatch general-purpose" — fall back to default subagent

**Cross-persona tasks**: if a task spans 2+ personas (e.g. B6 bob-thinking = product scope + architect skill design + eng implementation), split into sub-tasks during Phase 0 extraction. One task = one persona. Don't bundle multiple personas into a single dispatch.

**Skip persona routing when**:
- All tasks are pure code execution with no architecture / UX / ops signal (announce "all tasks routed to eng-lead, persona-routing skipped").
- User explicit override (`skip persona`).
- Plan has 1-2 tasks (overhead > value).

### Phase 1: Execute tasks with isolation

For each task:

1. **Dispatch to subagent** (or run in focused context) with the persona assigned in Phase 0.5. Subagent prompt must be self-contained: include persona contract, task goal, relevant file paths, any prior task output it depends on, and "report back: what you did, what files changed, any errors."

   **Dispatch shape (skill-as-persona inline pattern, per `lib/persona-frame.md`)**:

   ```
   1. Read ~/site/skills/pandastack/plugins/pandastack/skills/{persona}/SKILL.md
   2. Extract 6 sections: Soul / Iron Laws / Cognitive Models / On Invoke / Anti-patterns / BAD-GOOD calibration
   3. Drop frontmatter + @../../lib/... include lines
   4. Build prompt:

      --- pandastack:{persona} persona contract ---
      {6 sections inlined verbatim}
      --- end persona ---

      ## Hard rules (substrate, must inline explicitly)
      - Commit style: Conventional Commits, body in English, NO em dash, NO Co-Authored-By trailer
      - Voice: no sycophantic openers, no closing fluff
      - {any other ~/.agents/AGENTS.md rules relevant to this task}

      ## Task
      {self-contained brief: goal, file paths, expected output, test plan}

   5. Agent({
        description: "{task n short title}",
        subagent_type: "general-purpose",          // ALWAYS general-purpose; persona comes from inlined skill
        prompt: "{built above}",
        isolation: "worktree",                      // when task is branch-scoped
        model: "{per heuristic below}",
      })
   ```

   **Why subagent_type is always general-purpose**: persona is delivered via inlined skill content, not via subagent_type selection. This matches pandastack v1.1 skill-only doctrine and removes the need for `~/.claude/agents/<persona>.md` files (which require session restart to register).

   **Model selection — main agent picks per task, do not inherit silently.** Pass
   `model:` explicitly on every Agent call. Default heuristic:

   | Task shape | Model | Why |
   |---|---|---|
   | Read-only / grep / file listing / orientation | haiku | No judgment, fast + cheap |
   | File edits, refactors, mechanical writes, structured execution | sonnet | Default — covers most plan steps |
   | Architectural decisions, deep cross-file reasoning, ambiguous trade-offs | opus | Reserve for the 1-2 tasks that actually need it |

   When in doubt, sonnet. Don't pay opus for mechanical work; don't starve
   architecture with haiku.

   **Persona × model interaction**:
   - `architect` tasks: opus default (deep trade-off reasoning) unless task is mechanical "fill out this ADR template"
   - `eng-lead` tasks: sonnet default; opus only for cross-file refactor with ambiguous root cause
   - `design-lead` / `product-lead` / `ops-lead` / `ceo`: sonnet default
   - Plain general-purpose (no persona inlined): per task-shape heuristic above

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
| Code edit in user's apps or custom CLI directories | medium |
| Work vault write | medium |
| Anything under user's infra or trading directories | high |
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
- **Defaulting all tasks to eng-lead persona**: defeats Phase 0.5 routing. Architecture / UX / ops tasks misrouted to eng-lead get over-fitted to "minimal diff" bias and miss the trade-off / accessibility / runbook lens.
- **Mixing personas within one task**: cross-persona task means split into sub-tasks during Phase 0. One task = one persona = one dispatch.
- **Skipping the routing block output**: Phase 0.5 must print the routing table before Phase 1 starts so user can override. Silently picking personas defeats the human review gate.

---

## Relationship to other skills

- **`pandastack:grill`** — surfaces the requirements before writing a plan. Run grill first if scope is fuzzy.
- **`pandastack:review`** — runs after execute-plan on code changes before committing.
- **`pandastack:careful`** — should already be active when touching prod/infra/ops paths. If not, invoke it before Phase 1.
- **`/plan`** — Claude Code's built-in plan mode. Compatible: use /plan to produce the plan, then invoke execute-plan to run it with gates.
- **`pandastack:ship`** — for committing and pushing after code execution. execute-plan does not commit.

## Persona dispatch targets (Phase 0.5)

- **`pandastack:architect`** — system design / tech stack / DB / service topology / API contract / non-functional reqs
- **`pandastack:eng-lead`** — code edit / refactor / debug / fix / feature impl / ship
- **`pandastack:design-lead`** — UX / layout / accessibility / interaction / visual hierarchy
- **`pandastack:ops-lead`** — multi-team coord / process / SLA / runbook / on-call / handoff
- **`pandastack:product-lead`** — feature scoping / metric / PMF / pricing / user research
- **`pandastack:ceo`** — kill / pivot / scope cut / strategic frame / cross-axis prioritization
- **plain `general-purpose`** (no persona inlined) — when no persona fits or user explicitly opts out

Each persona is a skill at `~/site/skills/pandastack/plugins/pandastack/skills/{persona}/SKILL.md`. Skill is the SSOT — there is no separately-maintained agent file. Phase 1 dispatch reads SKILL.md, extracts the 6 contract sections, inlines them into the subagent prompt, and dispatches as `subagent_type: "general-purpose"`. See `lib/persona-frame.md` § "Inline-from-skill dispatch pattern" for the exact format.
