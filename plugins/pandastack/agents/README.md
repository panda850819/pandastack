# Agents

Agent personas are markdown files that define **who** does the work. Skills define **what** to do; agents define **how** to think about it.

## Structure

Each agent file has:

```markdown
---
name: {role}
description: {one line}
model: inherit
disallowedTools: []
---

# {Title}

## Soul          — who this person is, how they think, their tone
## Iron Laws     — rules they never break
## On Invoke     — what they do first when called
## Team Protocol — how they work with other agents
```

## Customizing

1. Copy the agent you want to change
2. Edit the Soul and Iron Laws
3. Save — all skills that reference this agent will use your version

## Adding a New Agent

Create a new `.md` file in this directory. Follow the same structure. Reference it from your skills or commands.
