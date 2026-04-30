# RESOLVER.md

> Map of every skill / agent / flow / context in pandastack v1. Use this as the index when something looks like overlap or you can't tell which skill to invoke.
>
> Companion to PHILOSOPHY.md (the why) and the per-skill SKILL.md files (the how).

## Why this file exists

pandastack v1 ships ~30 skills, 5 personas, 7 lifecycle flows, and 8 context recipes. That's a lot of surface area. RESOLVER.md is the disambiguation layer — when two things look similar but serve different purposes, you read this file to learn the boundary.

This is the pattern used by gstack, gbrain, and alirezarezvani: monorepo + RESOLVER.md beats multi-repo split, because the categorization lives next to the content.

---

## Skill catalog (by lifecycle, not alphabetical)

### Knowledge / research

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:deep-research` | Two-layer planner+researcher with quality gates | overnight research, deep explore |
| `pandastack:feed-curator` | Process Inbox feeds, route by source quality | weekly cron, feed pipeline |
| `pandastack:knowledge-ship` | Close + Extract + Backflow on a knowledge note | ship this note |
| `pandastack:wiki-lint` | Vault hygiene scan (orphans, stale, duplicates) | weekly hygiene |
| `pandastack:tool-summarize` | Summarize URL / podcast / file | summarize, TL;DR |
| `pandastack:tool-web-extract` | Defuddle web → markdown | URL to read |

### Writing

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:content-write` | Voice-aware drafting + slop detection | help me write |
| `pandastack:write-ship` | Close + Extract + Backflow on a Blog draft | ship this draft |

### Work execution (vault-only, external pushed manually)

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:work-ship` | Close + Extract + Backflow on a work topic | close out this topic |
| `pandastack:process-decisions` | Walk ticked items in Inbox/cron-reports/ | post-cron decision sweep |
| `pandastack-private:misalignment` | Slack misalignment scan | weekly Slack scan |
| `pandastack-private:yei-alert-triage` | Hypernative + on-chain risk triage | alert triage |

### Dev workflow

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:grill` | Adversarial requirement discovery (default) + structured intake (`--mode structured`, replaces old `pandastack:brief`) | grill me, stress test, draft a brief |
| `pandastack:careful` | Confirmation gates for production / shared infra | working on prod |
| `pandastack:checkpoint` | Save / resume working state snapshot | pausing work |
| `pandastack:freeze` | Lock editing scope to specific paths | scope discipline |
| `pandastack:qa` | Browser-based UI QA | test this UI |
| `pandastack:review` | Parallel 3-pass review + Codex cross-check | review PR |
| `pandastack:ship` | Test + commit + PR | code done, ship it |
| `pandastack:learn` | Search / manage project learnings | what have we learned |

### Retro / session

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:retro-week` | Three-phase weekly retro (Auto-scan → Interview → Write) | weekly retro |
| `pandastack:retro-month` | Three-phase monthly retro (with weekly retros referenced) | monthly retro |
| `pandastack:done` | Save session context, persist memory | session done, /done |

### Tool wrappers (1:1 with CLIs)

| Skill | Wraps |
|---|---|
| `pandastack:tool-bird` | bird CLI (X / Twitter) |
| `pandastack:tool-notion` | notion-cli |
| `pandastack:tool-slack` | slack-cli |
| `pandastack:tool-railway` | railway CLI |
| `pandastack:tool-pdf` | PDF read / extract / OCR |
| `pandastack:tool-deepwiki` | DeepWiki repo docs |
| `pandastack:agent-browser` | Browser automation |

### Persona thinking frames

| Skill | Frame |
|---|---|
| `pandastack:think-like-naval` | Leverage / specific knowledge / wealth-vs-capture |
| `pandastack:think-like-alan-chan` | Product 0→1 / focus discipline / unfounded inference |
| `pandastack:think-like-karpathy` | Agent architecture / skill-as-code / human-vs-agent boundary |

### Multi-lens review

| Skill | Purpose |
|---|---|
| `pandastack:persona-pipeline` | Sequential product → design → eng → ceo review |

### Trust evaluation (NOT code review)

| Skill | Purpose |
|---|---|
| `pandastack:slowmist-agent-security` | Pre-adoption gate for external agents / MCP / repos / on-chain. NOT a code review skill. |

### Trading (private only)

| Skill | Purpose |
|---|---|
| `pandastack-private:chain-scout` | BSC token chip + cluster + MM analysis |

### Sommet (private)

| Skill | Purpose |
|---|---|
| `pandastack-private:sommet:abyss-dry-run-init` | Abyss Phase 1 morning state |
| `pandastack-private:sommet:abyss-dry-run-step` | Abyss Phase 1 single playbook step |
| `pandastack-private:sommet:midnight-compact` | Midnight network compact validator |
| `pandastack-private:sommet:midnight-dapp` | Midnight network dApp dev workflow |
| `pandastack-private:sommet:wallet-smoke-test` | Wallet smoke test playbook |

---

## Disambiguation: where things look like overlap but aren't

### Four "review" skills

| Skill | What it reviews |
|---|---|
| Built-in `/review` | Generic PR review (Claude Code platform default) |
| Built-in `/security-review` | Branch code for security issues |
| `pandastack:review` | YOUR code via parallel 3-pass + Codex cross-check |
| `pandastack:slowmist-agent-security` | EXTERNAL agents / MCP / repos BEFORE you adopt them — adoption gate, not code review |

If you're reviewing your own PR → `pandastack:review`. If you're deciding whether to install someone else's MCP server / clone their skill repo → `pandastack:slowmist-agent-security`.

### Two requirement-discovery skills (collapsed)

`pandastack:grill` is the only one as of v1.

- Default mode: adversarial, one-question-at-a-time, surfaces unknown unknowns.
- `pandastack:grill --mode structured`: 5-step structured brief flow. **Replaces the deprecated `pandastack:brief` from v0.16.**

### Two retro skills (was three)

| Skill | When |
|---|---|
| `pandastack:retro-week` | Sunday or end of week. Three phases now (Auto-scan / Interview / Write) — Phase 1 absorbed the old standalone `pandastack:retro` from v0.16. |
| `pandastack:retro-month` | End of month. References past 4 weekly retros. |

The old `pandastack:retro` (v0.16) is gone in v1. Its git-activity-scan logic moved into `retro-week` Phase 1.

### Compound is gone (absorbed into ship)

The old `pandastack:compound` from v0.16 is removed. Compound logic (write a learning to `docs/learnings/`) is now a Backflow row in `pandastack:knowledge-ship` and `pandastack:work-ship` Stage 3. If you want to "remember this", run the appropriate ship and answer the Extract questions — Stage 3 will route to `docs/learnings/` automatically.

### `done` vs `retro-week`

`pandastack:done` = end of one session (commit + memory persist + brief summary).
`pandastack:retro-week` = aggregate over 7 days, interactive interview.

Different time horizons, both legitimate. Run `done` daily, `retro-week` once a week.

---

## Agents (5 personas)

| Agent | When |
|---|---|
| `pandastack:ceo` | Strategic decisions, kill/pivot/continue, framework tension |
| `pandastack:ops` | COO-level — systems that run without you, process-when-painful, decision shape (action / owner / deadline) |
| `pandastack:product` | User problems over solutions, metric-driven, says no more often than yes |
| `pandastack:eng` | Build / debug / ship — minimal diff, root cause, no spiral |
| `pandastack:design` | Intentional over decorative, every element earns its place |

All 5 are READ-ONLY personas. They recommend; user decides.

---

## Lifecycle flows (7)

Read these when you need to know which skill chain handles a given lifecycle:

| Flow | Trigger | File |
|---|---|---|
| dev | new feature, debug, refactor | `flows/dev.md` |
| knowledge | new note, capture | `flows/knowledge.md` |
| writing | draft article / thread | `flows/writing.md` |
| work | alert / ticket / Slack ask | `flows/work.md` |
| research | unfamiliar concept, decision needs prior art | `flows/research.md` |
| retro | daily / weekly / monthly cadence | `flows/retro.md` |
| decision | cron reports accumulated for triage | `flows/decision.md` |

Flows are not skills — they're choreography spec. The skills they call ARE the work.

---

## Contexts (8 recipes for pdctx)

Each `.toml` file in `contexts/` binds a flow + persona + skill subset to a specific identity. Read by the future pdctx loader.

| Context | Identity | Private |
|---|---|---|
| `personal-developer` | Personal dev work | no |
| `personal-writer` | Personal writing | no |
| `personal-knowledge-manager` | Personal knowledge work | no |
| `personal-trader` | Personal trading | yes |
| `work-yei-ops` | Yei Ops Manager | yes |
| `work-yei-hr` | Yei HR | yes |
| `work-yei-finance` | Yei Finance | yes |
| `work-sommet-abyss-po` | Sommet Abyss product owner | yes |

Private contexts may reference `pandastack-private:*` skills. Public contexts may not.

---

## Provenance: how skills came to live here

| Origin | Skills |
|---|---|
| Built in v0.16 | careful, checkpoint, compound (now absorbed), freeze, init, learn, qa, retro (now absorbed), review, ship, brief (now absorbed) |
| Added in v1 from `~/.claude/skills/` (local) | deep-research, feed-curator, grill, knowledge-ship, work-ship, write-ship, persona-pipeline, process-decisions, retro-week, retro-month, slowmist-agent-security, wiki-lint, tool-bird, tool-notion, tool-railway |
| Added in v1 from `claude-skills` repo | agent-browser, content-write, done, think-like-naval, think-like-alan-chan, think-like-karpathy, tool-deepwiki, tool-pdf, tool-slack, tool-summarize, tool-web-extract |
| New v1 agent | ops |

`claude-skills` repo's role after v1: hold the residual community-curated content (ops-lead reference, wave-analyst, _archived-*). Most of Panda's personal stack is in pandastack now.

---

## Version

This RESOLVER.md is for pandastack v1. Update when adding / removing / renaming skills.
