# pandastack

Personal AI operator OS for Claude Code, with Codex CLI compatibility. 5 agent personas, ~37 skills, 7 lifecycle flows, 8 context recipes. Zero runtime dependencies.

## What It Does

pandastack v1 is a stack of skills and lifecycle flows that turn Claude Code into a small team covering the seven lifecycles where personal AI compounds:

| Lifecycle | What it does |
|---|---|
| dev | brief → build → review → ship → extract |
| knowledge | capture → distill → verify → ship → lint |
| writing | capture → structure → draft → ship → distribute |
| work | triage → context → execute → ship → push (vault-only) |
| research | scope → fetch → dive → distill → ship |
| retro | daily → weekly → monthly cadence with auto-scan |
| decision | cron-driven decision triage |

Skills compose into flows. Flows bind to identity via context recipes. The system compounds across sessions through learnings, decisions, and memory.

For the disambiguation index of every skill / agent / flow / context, see [RESOLVER.md](RESOLVER.md).

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

### Other runtimes

Pandastack v1.0.0-rc.2+ also runs on Codex CLI via native skill discovery. See [`plugins/pandastack/.codex/INSTALL.md`](plugins/pandastack/.codex/INSTALL.md) for the clone + symlink install path. Tested on Codex CLI 0.124.0. Lifecycle skills are fully portable; `tool-*` skills depending on local CLIs (qmd / bird / notion-cli / slack / etc.) require those CLIs in the host environment.

## Skills

All skills are namespaced under `pandastack:*`. There are ~37 of them in v1, grouped by lifecycle. See [RESOLVER.md](RESOLVER.md) for the full catalog and disambiguation guide. The dev-workflow primitives are listed below; all other skills (knowledge / writing / work / research / retro / tool wrappers / persona thinking) live in RESOLVER.

### Dev workflow primitives

| Skill | What It Does |
|-------|-------------|
| `/pandastack:init` | One-time project setup |
| `/pandastack:grill` | Adversarial requirement discovery (`--mode structured` for the old brief flow) |
| `/pandastack:review` | Parallel 3-pass review + Codex cross-check + learnings |
| `/pandastack:qa` | Browser-based QA with structured assertions and parallel testing |
| `/pandastack:ship` | Test + commit + PR (+ tag/release if configured) |
| `/pandastack:learn` | Search and manage learnings |
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

5 replaceable agent personas in `plugins/pandastack/agents/`:

| Agent | Role | When |
|-------|------|------|
| `eng.md` | Staff engineer — build, review, debug, ship | dev / knowledge / work flows |
| `product.md` | VP Product — requirements, scope, metrics | grill --mode structured, sprint planning |
| `design.md` | Senior designer — UI/UX, accessibility, anti-slop | UI work, design reviews |
| `ceo.md` | Strategic advisor — scope decisions, kill/pivot (read-only) | Large scope, finance lifecycle |
| `ops.md` | COO — systems-without-you, process when painful (new in v1) | work / decision flows, team coordination |

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

## Lifecycle Flows

7 lifecycle flow specs in `plugins/pandastack/flows/`:

- `dev.md` — feature / debug / refactor lifecycle
- `knowledge.md` — note capture / distill / verify lifecycle
- `writing.md` — draft / structure / publish lifecycle
- `work.md` — alert / ticket / Slack ask → triage → ship lifecycle (vault-only writes)
- `research.md` — unfamiliar concept → fetch → distill lifecycle
- `retro.md` — daily / weekly / monthly cadence
- `decision.md` — cron-driven decision triage

Plus reference docs `solo.md` (daily solo development) and `full.md` (complete sprint with all checkpoints) from earlier versions.

Each flow lists Trigger / Phases / Exit / Anti-patterns / Skill choreography. They're not skills — they're spec for which skill chain handles a given lifecycle.

## Context Recipes

8 context recipe TOML files in `plugins/pandastack/contexts/`. These bind flow + persona + skill subset to a specific identity. They're the v0 schema for the pdctx loader (separate project, future).

| Context | Identity |
|---|---|
| `personal-developer` | Personal dev work |
| `personal-writer` | Personal writing |
| `personal-knowledge-manager` | Personal knowledge work |
| `personal-trader` | Personal trading (private) |
| `work-yei-ops` | Yei Ops Manager (private) |
| `work-yei-hr` | Yei HR (private) |
| `work-yei-finance` | Yei Finance (private) |
| `work-sommet-abyss-po` | Sommet Abyss product owner (private) |

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
│       ├── agents/               # 5 agent personas (ceo, design, eng, ops, product)
│       ├── commands/             # composite commands
│       ├── skills/               # ~37 skills (one dir per skill, each with SKILL.md)
│       ├── flows/                # 7 lifecycle flow specs
│       ├── contexts/             # 8 context recipes (.toml) — read by pdctx loader
│       ├── lib/                  # shared snippets (confidence decay, gate contracts, etc.)
│       ├── CLAUDE.md
│       └── PHILOSOPHY.md
├── CHANGELOG.md
├── RESOLVER.md                   # disambiguation index for the full surface area
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

v1.0.0-rc.1 (2026-04-29): scope expansion from dev-only to 7 lifecycles + 8 context recipes.
v1.0.0-rc.2 (2026-04-30): Codex CLI multi-CLI support (Superpowers-pattern shim + tool-name mapping).
See [CHANGELOG.md](CHANGELOG.md).
