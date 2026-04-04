# pstack

Agent-driven development with a learning loop. 4 agents, 10 skills, zero dependencies.

## What It Does

pstack turns Claude Code into a small team that gets smarter over time:

```
brief → build → review → ship → compound
                  ↑                   ↓
                  └── learnings ──────┘
```

Every review searches past learnings. Every review can write new ones. The system compounds.

## Quick Start

```bash
# Install (30 seconds)
git clone https://github.com/panda850819/pstack.git ~/.claude/skills/pstack
cd ~/.claude/skills/pstack && ./setup

# In your project
/ps-init              # one-time setup
# ... write some code ...
/ps-review            # review with learnings
/ps-ship              # test + commit + PR
```

## Skills

| Skill | What It Does |
|-------|-------------|
| `/ps-init` | One-time project setup |
| `/ps-brief` | Structured requirement gathering |
| `/ps-review` | Code review + read/write learnings |
| `/ps-qa` | Browser-based QA with structured assertions and parallel testing |
| `/ps-ship` | Test + commit + PR (+ tag/release if configured) |
| `/ps-compound` | Extract learnings from solved problems |
| `/ps-learn` | Search and manage learnings |
| `/ps-retro` | Weekly retrospective + prune stale learnings |
| `/ps-careful` | Confirmation gates for destructive commands on prod/shared code |
| `/ps-freeze` | Lock editing scope to specific paths for the session |

## Commands (Shortcuts)

| Command | What It Runs |
|---------|-------------|
| `/ps-sprint` | Full flow: brief → build → review → qa → ship → compound |
| `/ps-design` | Design-driven: brief → design → build → review → qa → ship |
| `/ps-fix` | Bug fix: debug → fix → review → ship → compound |
| `/ps-quick` | Small change: review → ship |

## Agents

4 replaceable agent personas in `agents/`:

| Agent | Role | When |
|-------|------|------|
| `eng.md` | Staff engineer — build, review, debug, ship | Every skill |
| `product.md` | VP Product — requirements, scope, metrics | `/ps-brief` |
| `design.md` | Senior designer — UI/UX, accessibility, anti-slop | UI work |
| `ceo.md` | Strategic advisor — scope decisions, kill/pivot (read-only) | Large scope |

Don't like the default eng persona? Replace `agents/eng.md` with your own. All skills that reference it will pick up the change.

## Learning System

Learnings are markdown files with YAML frontmatter, stored in your repo at `docs/learnings/`.

```markdown
---
type: pitfall
key: n-plus-one-api
confidence: 8
source: observed
skill: review
files:
  - src/api/users.ts
created: 2026-03-30
last_seen: 2026-03-30
---

## Problem
API endpoints query DB in a loop, causing N+1.

## Solution
Use batch query or eager loading.

## Prevention
Grep for `for.*await.*find` pattern during review.
```

- **Confidence decay**: observed/inferred learnings lose 1 point per 30 days. User-stated preferences never decay.
- **Dedup**: before writing, check for existing learnings with the same key. Update instead of duplicate.
- **Prune**: `/ps-retro` flags learnings with confidence < 3 for user review.
- **Storage**: defaults to `docs/learnings/` in your repo. Configurable to any path (global dir, Obsidian vault, etc.).

## Flows

Not code — just reference docs in `flows/` that show how to combine skills:

- `solo.md` — daily solo development
- `full.md` — complete sprint with all checkpoints

## Customize

### Replace an Agent

Copy `agents/eng.md`, edit the Soul and Iron Laws, save. All skills that use the eng agent will pick up your changes.

### Change Learnings Location

In your project's CLAUDE.md:

```yaml
## pstack
learnings: ~/my-vault/knowledge/learnings   # any path
```

### Add Your Own Skills

pstack skills are just SKILL.md files. Add new ones to `skills/your-skill/SKILL.md` and re-run `./setup`.

## Uninstall

```bash
cd ~/.claude/skills/pstack && ./setup --uninstall
```

## Philosophy

See [PHILOSOPHY.md](PHILOSOPHY.md).

**In one sentence**: pstack lets you coach your own team.
