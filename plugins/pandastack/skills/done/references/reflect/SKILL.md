---
name: session-reflect
description: Mid-session structured self-reflection. Analyze current session patterns against existing infrastructure (skills, memory, knowledge docs) and produce concrete, actionable growth suggestions. Use mid-session to capture insights and reorient. Triggers on "/reflect", "reflect".
allowed-tools: Bash, Read, Glob, Grep
version: "1.0.0"
user-invocable: true
model: sonnet
---

# /reflect -- Mid-Session Growth Check

Pause mid-session for a structured analysis of patterns so far, identifying things worth capturing.

Unlike `/done`: /reflect does not save or archive, it only produces suggestions for the user to pick from.

---

## Workflow

```
1. SCAN     → Review what's been done in the session so far
2. CHECK    → Compare against existing infrastructure, find gaps
3. SUGGEST  → Produce tiered suggestions
4. ORIENT   → Quick direction confirmation
```

---

## Step 1: Scan

Internal analysis (don't list for user), quick review:

- This session's topic/domain
- What operations were performed (reading code, writing code, debug, research, design...)
- Where the most time was spent
- Any repeating patterns (similar queries, similar operations)
- Any workarounds or detours

---

## Step 2: Check

Compare against existing infrastructure, find gaps:

### 2a. Skills Coverage

```bash
ls ~/.claude/skills/ | head -50
```

Does this domain have a corresponding skill? If so, are there patterns in this session that exceed the skill's coverage?

### 2b. Memory Coverage

Read the current project's MEMORY.md, check how much is recorded for this domain.
Also scan the memory directory for related topic files:

```bash
ls <project-memory-dir>/
```

### 2c. Knowledge Docs

Check for related knowledge docs or cheatsheets:

```bash
ls <project-memory-dir>/*.md 2>/dev/null
```

### 2d. Past Learnings

```bash
grep -i "<domain-keyword>" ~/.claude/references/skill-learnings.md 2>/dev/null | tail -5
```

Any B/C records from past sessions in this domain? What patterns?

---

## Step 3: Suggest

Based on Scan + Check results, produce suggestions. Three tiers:

### Tier 1: Quick Capture (can do now, < 5 minutes)

- Update MEMORY.md (newly discovered patterns, paths, commands)
- Record workarounds to existing knowledge docs
- Extend existing skill's coverage

### Tier 2: Build (takes some time, can do now or schedule for later)

- Create new skill (with rough outline: what it covers, how many workflow steps)
- Write new knowledge doc / cheatsheet
- Do a structured deep research

### Tier 3: Explore (directions for future sessions)

- Topics worth deeper investigation
- Upstream changes or ecosystem dynamics to watch
- Cross-domain connections (can this pattern be used in other projects?)

### Suggestion Format

Each suggestion must be concrete, with observed evidence:

```
BAD: "Suggest building a skill"
GOOD: "You queried Compact's cast syntax 3 times and disclose usage 2 times this session,
    plus memory already has compiler version management and shielded token workaround,
    could consolidate into a midnight-compact skill, covering:
    - Syntax quick reference (cast, disclose, import, kernel)
    - Common bugs/workarounds
    - compile -> deploy standard workflow
    Want to build it now?"
```

Only list suggestions backed by evidence. If no clear pattern is observed, don't force it.

---

## Step 4: Orient

A brief direction confirmation in conversational tone:

> We're currently working on [X], at [stage].
> Suggested next step is [Y].
> Want to continue the original direction, or handle one of the suggestions above first?

Possible user responses:
- "continue" -> back to work
- "do the tier 1 one first" -> execute quick capture
- "build that skill now" -> switch to building skill
- "wrong direction" -> discuss adjustment

---

## When to Skip

- Session just started (< 10 turns), too early to reflect meaningfully
- User is in urgent debug mode, not appropriate to pause
- Pure conversation/discussion session, no capturable patterns

## Safety

- /reflect only produces suggestions, does not auto-create files or auto-modify skills
- Only execute after user selects
- If nothing worth suggesting, say "nothing particularly needs capturing right now, continuing"
