# pandastack

Agent-driven development with a learning loop. 4 agent personas, 11 skills, 5 composite commands. Zero runtime dependencies.

## What It Does

pandastack turns Claude Code into a small team that gets smarter over time:

```
brief → build → review → ship → compound
                  ↑                   ↓
                  └── learnings ──────┘
```

Every review searches past learnings. Every review can write new ones. The system compounds.

## Install

pandastack is a Claude Code plugin. Install via the built-in marketplace system.

```
/plugin marketplace add panda850819/pandastack
/plugin install pandastack@pandastack
/reload-plugins
```

For local development (cloned the repo yourself):

```
/plugin marketplace add ~/path/to/pandastack
/plugin install pandastack@pandastack
/reload-plugins
```

Then in your project, run `/pandastack:init` once.

## Skills

All skills are namespaced under `pandastack:*`.

| Skill | What It Does |
|-------|-------------|
| `/pandastack:init` | One-time project setup |
| `/pandastack:brief` | Structured requirement gathering |
| `/pandastack:review` | Code review + read/write learnings |
| `/pandastack:qa` | Browser-based QA with structured assertions and parallel testing |
| `/pandastack:ship` | Test + commit + PR (+ tag/release if configured) |
| `/pandastack:compound` | Extract learnings from solved problems |
| `/pandastack:learn` | Search and manage learnings |
| `/pandastack:retro` | Weekly retrospective + prune stale learnings |
| `/pandastack:careful` | Confirmation gates for destructive commands on prod/shared code |
| `/pandastack:freeze` | Lock editing scope to specific paths for the session |
| `/pandastack:checkpoint` | Save or resume working state snapshots |

## Commands (Composites)

| Command | What It Runs |
|---------|-------------|
| `/brainstorm` | New idea: diverge → filter → define → research → cost → go/no-go |
| `/sprint` | Full flow: brief → build → review → qa → ship → compound |
| `/design` | Design-driven: brief → design → build → review → qa → ship |
| `/fix` | Bug fix: debug → fix → review → ship → compound |
| `/quick` | Small change: review → ship |

## Agents

4 replaceable agent personas in `plugins/pandastack/agents/`:

| Agent | Role | When |
|-------|------|------|
| `eng.md` | Staff engineer — build, review, debug, ship | Every skill |
| `product.md` | VP Product — requirements, scope, metrics | `/pandastack:brief` |
| `design.md` | Senior designer — UI/UX, accessibility, anti-slop | UI work |
| `ceo.md` | Strategic advisor — scope decisions, kill/pivot (read-only) | Large scope |

Don't like the default eng persona? Replace `agents/eng.md` with your own. All skills that reference it pick up the change.

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
- **Prune**: `/pandastack:retro` flags learnings with confidence < 3 for user review.
- **Storage**: defaults to `docs/learnings/` in your repo. Configurable to any path (global dir, Obsidian vault, etc.).

## Flows

Reference docs in `plugins/pandastack/flows/` showing how to combine skills:

- `solo.md` — daily solo development
- `full.md` — complete sprint with all checkpoints

## Customize

### Replace an Agent

Copy `plugins/pandastack/agents/eng.md`, edit the Soul and Iron Laws, save. All skills that use the eng agent pick up your changes after `/reload-plugins`.

### Change Learnings Location

In your project's CLAUDE.md:

```yaml
## pandastack
learnings: ~/my-vault/knowledge/learnings   # any path
```

### Add Your Own Skills

pandastack skills are just SKILL.md files. Add new ones to `plugins/pandastack/skills/your-skill/SKILL.md` and `/reload-plugins`.

## Repo Layout

```
pandastack/
├── .claude-plugin/
│   └── marketplace.json          # marketplace manifest (single-plugin)
├── plugins/
│   └── pandastack/
│       ├── .claude-plugin/
│       │   └── plugin.json       # plugin manifest
│       ├── agents/               # 4 agent personas
│       ├── commands/             # 5 composite commands
│       ├── skills/               # 11 skills (one dir per skill, each with SKILL.md)
│       ├── flows/                # reference flow docs
│       ├── lib/                  # shared snippets (confidence decay, gate contracts, etc.)
│       ├── CLAUDE.md
│       └── PHILOSOPHY.md
└── README.md
```

## Uninstall

```
/plugin uninstall pandastack
```

## Philosophy

See [PHILOSOPHY.md](plugins/pandastack/PHILOSOPHY.md).

**In one sentence**: pandastack lets you coach your own team.

## History

Renamed from `pstack` on 2026-04-29 as part of the pdctx framework split. The old `setup` script (gstack-style symlink installer with `ps-*` prefix) is sunset; Claude Code's native plugin marketplace replaces it.
