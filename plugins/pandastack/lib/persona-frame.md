# lib/persona-frame.md — Shared persona structure

> Shared module. Loaded by `boardroom` which switches between 4 voices internally, and by the 5 lead skills (ceo / eng-lead / design-lead / product-lead / ops-lead) for their cognitive model + iron law structure.
>
> Origin: pandastack 5 lead personas existed only as agents at `agents/{ceo,design,eng,ops,product}.md`. v1.1 cut: pandastack is **skill-only**, agents/ deleted. Persona content lives in `skills/{persona}/SKILL.md`. This lib defines the shared structure so 5 lead skills + boardroom voices stay aligned.

## Persona contract (shared structure)

Every lead persona skill must declare:

```yaml
---
name: {ceo / eng-lead / design-lead / product-lead / ops-lead}
description: {one-line role + tone}
---

# {Persona name}

## Soul
{2-3 sentences on the role's core orientation}

## Iron Laws (3-5 numbered, non-negotiable)
1. {law 1 with one-line elaboration}
2. ...

## Cognitive Models (2-3 frameworks the persona reaches for)
- {framework 1}: {when to apply}
- {framework 2}: {when to apply}

## On Invoke (3-5 step protocol)
1. {step}
2. ...

## Anti-patterns (3-5 common drifts)
- ❌ {anti-pattern}
- ...
```

This 6-section structure (Soul / Iron Laws / Cognitive Models / On Invoke / Anti-patterns) is the persona contract. All persona skills follow it.

## Why skill-only (no agent mode)

User direction (2026-05-04): pandastack is skill-first. Reasons:

- 5 lead persona usage is mostly sequential thinking + conversational, not parallel + cold context
- Agent overhead (token + latency + context startup) not justified for in-session quick lens use
- Single execution model = simpler resolver, fewer contracts to maintain
- If genuinely need cold-context parallel critique, use built-in `Agent` tool with the persona skill as system prompt — not a separately-maintained agent file

## Boardroom integration

`boardroom` (B4) is a single skill that switches between 4 voices internally (ceo → product → design → eng — ops not included by default, scope-add when ops decisions are central). Voice switching mechanism:

1. Boardroom loads `lib/persona-frame.md` to know the contract
2. For each voice, boardroom loads `skills/{voice}/SKILL.md` and reads the 6 sections
3. Boardroom prompts: "Now critiquing as {voice}: {Soul}. Apply Iron Laws {1-N}. Reach for {cognitive models}."
4. Voice produces critique, returns to boardroom
5. Repeat for next voice

This means the 5 lead skill files are LOAD-BEARING for boardroom. They can't be empty stubs.

## When loading lib in a skill

```markdown
@lib/persona-frame.md          # at top of skill body or in frontmatter ref
```

Skills that ref this lib:
- `boardroom` (B4) — for voice switching contract
- `sprint` (B6) — when auto-invoking design-lead skill on UI scope detection
- `prep` / `dojo` (B3) — when persona-driven framing is needed for Stage 0
- 5 lead skills — for self-consistency check (they should match this contract)

## Why a frame, not 5 hard-coded skills

Without a frame:
- Each skill drifts in structure over edits
- boardroom can't programmatically extract sections (it tries to grep "Iron Laws" but finds different markers each time)
- Adding a 6th persona requires copy-paste from another skill, drift compounds

With a frame:
- 5 leads share structure, only content varies
- boardroom programmatically loads → extract Soul / Iron Laws / Cognitive Models / On Invoke
- Adding a persona = follow the frame, lower marginal cost

## Anti-patterns

- ❌ Persona skill body that doesn't follow the 6-section structure (boardroom will fail to extract)
- ❌ Putting tool-use logic into a persona skill — personas are thinking frames, not tool wrappers
- ❌ Cross-persona references inside a persona skill ("as the eng-lead would say...") — each persona stands alone
- ❌ Updating only the agent file or only the skill file when changing iron laws — both must update together (or split with a reason in the changelog)

## Origin

- pandastack `agents/{ceo,design,eng,ops,product}.md` — original agent-only personas (deleted v1.1)
- v1.1 cut (2026-05-04) — pandastack is skill-only, agents/ deleted, content lives in `skills/{persona}/SKILL.md`
- `lib/persona-frame.md` defines the contract for the 5 persona skills
