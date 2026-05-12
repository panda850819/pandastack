---
name: skill-creator
description: |
  Create new pandastack skills. MECE-checks against existing 26 skills via
  RESOLVER.md. Enforces the hot/cold dispatch rule (skills that read >5K
  tokens of data must dispatch a sub-agent rather than consume inline).
  Triggers: "create a skill", "new pandastack skill", "improve this skill",
  "扩 skill".
version: 1.0.0
user-invocable: true
type: skill
---

# Skill Creator

Create a new pandastack skill that follows the SKILL-FRONTMATTER.md contract and the hot/cold dispatch rule. Sized to fit between `office-hours` (idea → brief) and `sprint` (brief → execution).

## Phases

### 1. Identify the gap

What user intent has no existing skill? Be explicit:
- What phrase / trigger will invoke this?
- What is the input shape?
- What is the output shape?
- Why doesn't an existing skill already handle it?

### 2. MECE check

Open `pandastack/RESOLVER.md`. Walk every category (Knowledge / Writing / Dev workflow / Retro-session / Tool wrappers / Personas / Multi-lens review / Trust evaluation). For each existing skill in scope, ask: does its trigger surface already cover this intent? If yes, extend that skill instead of adding new.

Also read the **Disambiguation** section — it lists known "look-like overlap" pairs (sprint vs team-orchestrate, four review skills, requirement-discovery split, etc.). Make sure your new skill doesn't recreate a deliberately-separated split.

### 3. Decide hot or cold (mandatory)

```
Will this skill read >5K tokens of data per invocation?
   ┌─────────────────────┴─────────────────────┐
   │                                           │
  NO (HOT)                                    YES (DATA-HEAVY)
   │                                           │
Normal skill.                          MUST dispatch sub-agent
Body executes in main                  for the heavy read.
agent context.                         Main agent only sees
                                       the returned summary.

                                       Wrong: skill reads 50 docs
                                              inline, builds answer
                                              in main context
                                       Right: dispatch Agent
                                              (subagent_type='Explore')
                                              → 200-token return
                                              → main agent reasons
                                                over the summary
```

This rule is non-negotiable. Skills that violate it silently degrade long-session recall (see `learnings/patterns/long-session-evals` for evidence; observed in Arize Alyx and Claude Code source, converged solution).

### 4. Write SKILL.md

Frontmatter must match `pandastack/SKILL-FRONTMATTER.md`:

```yaml
---
name: <folder-name>             # plain. no pandastack: prefix.
description: |
  <one-paragraph trigger sentence — short, concrete, decision-enabling>
version: 1.0.0                  # optional
user-invocable: true | false    # default false
type: skill | flow | lib        # default skill
allowed-tools: <patterns>       # optional
---
```

Body sections in order:
1. **Phases** — numbered workflow
2. **Output Format** — what good output looks like
3. **Anti-Patterns** — 3-5 items; MUST include the hot/cold rule when relevant

### 5. Add to RESOLVER.md

Place under the matching category:

```
| `pandastack:<name>` | <one-line purpose> | <trigger phrase> |
```

If no existing category fits, add a new section AND justify in commit message. Categories are deliberate — fragmenting the index has cost.

### 6. Verify

Run pandastack conformance:

```bash
cd "$PANDASTACK_ROOT" && bun test tests/
```

Pass = ship. Fail = read the error and fix the frontmatter / RESOLVER / body before merging.

## Output Format

```
plugins/pandastack/skills/<name>/
└── SKILL.md            ← created
pandastack/RESOLVER.md   ← row added
```

Conformance tests pass green.

## Anti-Patterns

- **MECE violation** — overlapping an existing skill's trigger surface. Extend, don't add.
- **Skipping Phase 3 (hot/cold check)** — data-heavy skill running inline degrades long sessions. See `learnings/patterns/long-session-evals`.
- **gbrain-flavored frontmatter** — `triggers:` array, `tools:`, `mutating:`. Pandastack uses description-sentence + optional `allowed-tools`.
- **Adding a new RESOLVER category without justification** — categories are an MECE budget, not a free namespace.
- **Shipping a one-off skill** — if it won't fire >3 times in the next month, don't ship. Pandastack tightened 38 → 26 for this reason.

## Related

- `pandastack/SKILL-FRONTMATTER.md` — the contract this skill enforces
- `pandastack/RESOLVER.md` — the index this skill updates
- `learnings/patterns/long-session-evals` — why the hot/cold rule exists
