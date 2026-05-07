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
| `pandastack:curate-feeds` | Process Inbox feeds, route by source quality (was: `feed-curator`) | weekly cron, feed pipeline |
| `pandastack:knowledge-ship` | Close + Extract + Backflow on a knowledge note | ship this note |
| `pandastack:wiki-lint` | Vault hygiene scan (orphans, stale, duplicates) | weekly hygiene |
| `pandastack:scout` | Recon public ecosystem for skill / harness patterns (was: `harness-survey`) | survey other harnesses |
| `pandastack:summarize` | Summarize URL / podcast / file | summarize, TL;DR |

### Writing

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:write` | Voice-aware drafting + slop detection (was: `content-write`) | help me write |
| `pandastack:write-ship` | Close + Extract + Backflow on a Blog draft | ship this draft |
| `pandastack:brief-morning` | Morning briefing into daily note (was: `morning-briefing`) | Hermes 8am cron |
| `pandastack:evening-distill` | End-of-day distill into daily note | Hermes 10pm cron |
| `pandastack:retro-prep-week` | Pre-fetch retro inputs (was: `weekly-retro-prep`) | Friday 9am cron |

### Work execution (vault-only, external pushed manually)

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:work-ship` | Close + Extract + Backflow on a work topic | close out this topic |
| `pandastack:process-decisions` | Walk ticked items in Inbox/cron-reports/ | post-cron decision sweep |

Additional work-specific skills (alert triage, Slack scans) ship in the private overlay — see [Private supplement](#private-supplement) below.

### Dev workflow

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:grill` | Adversarial requirement discovery, atomic 5-10 min, surfaces unknown unknowns, no brief output. For structured-brief output use `pandastack:office-hours`. | grill me, stress test, what am I missing |
| `pandastack:office-hours` | Structured 5-stage flow that produces a brief in `docs/briefs/`. Default ~30 min; `--quick` mode skips capability probe + goal mapping when context is pre-loaded. Absorbs the structured-brief role formerly under `grill --mode structured`. | office hours, draft a brief, structured intake |
| `pandastack:careful` | Confirmation gates for production / shared infra | working on prod |
| `pandastack:checkpoint` | Save / resume working state snapshot | pausing work |
| `pandastack:freeze` | Lock editing scope to specific paths | scope discipline |
| `pandastack:qa` | Browser-based UI QA | test this UI |
| `pandastack:review` | Parallel 3-pass review + Codex cross-check | review PR |
| `pandastack:ship` | Test + commit + PR | code done, ship it |

### Retro / session

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:retro-week` | Three-phase weekly retro (Auto-scan → Interview → Write) | weekly retro |
| `pandastack:retro-month` | Three-phase monthly retro (with weekly retros referenced) | monthly retro |
| `pandastack:done` | Save session context, persist memory | session done, /done |

### Tool wrappers (1:1 with CLIs)

| Skill | Wraps |
|---|---|
| `pandastack:bird` | bird CLI (X / Twitter) |
| `pandastack:notion` | notion-cli |
| `pandastack:slack` | slack-cli |
| `pandastack:deepwiki` | DeepWiki repo docs |
| `pandastack:agent-browser` | Browser automation (was: `agent-browser`) |

### Persona thinking frames

| Skill | Frame |
|---|---|
| `pandastack:think-like-naval` | Leverage / specific knowledge / wealth-vs-capture |
| `pandastack:think-like-alan-chan` | Product 0→1 / focus discipline / unfounded inference |
| `pandastack:think-like-karpathy` | Agent architecture / skill-as-code / human-vs-agent boundary |

### Multi-lens review

| Skill | Purpose |
|---|---|
| `pandastack:boardroom` | Single-skill 4-voice critique (CEO → product → design → eng) on a plan. Per-finding apply gate. Replaces deleted `persona-pipeline`. |

### Trust evaluation (NOT code review)

| Skill | Purpose |
|---|---|
| `pandastack:gatekeeper` | Pre-adoption trust check for external agents / MCP / repos / on-chain (was: `slowmist-agent-security`). NOT a code review skill. STRIDE classification at Step 0 (B1). |

---

## Private supplement

Some lifecycles (work alert triage, on-chain trading research, Sommet network ops) ship as a private overlay outside this index. If you have access to the private stack, its `RESOLVER.md` lists those skills with the same table format. The public index above stays self-contained: anything you can read here, you can install from this repo alone.

---

## Disambiguation: where things look like overlap but aren't

### Four "review" skills

| Skill | What it reviews |
|---|---|
| Built-in `/review` | Generic PR review (Claude Code platform default) |
| Built-in `/security-review` | Branch code for security issues |
| `pandastack:review` | YOUR code via parallel 3-pass + Codex cross-check |
| `pandastack:gatekeeper` | EXTERNAL agents / MCP / repos BEFORE you adopt them — adoption gate, not code review |

If you're reviewing your own PR → `pandastack:review`. If you're deciding whether to install someone else's MCP server / clone their skill repo → `pandastack:gatekeeper`.

### Requirement-discovery skills (split by output)

- `pandastack:grill` — adversarial, one-question-at-a-time, surfaces unknown unknowns. Atomic 5-10 min, no brief output (just `Inbox/grill-*.md` log).
- `pandastack:office-hours` — structured 5-stage flow that produces a brief in `docs/briefs/`. Default ~30 min; `--quick` mode (~10-15 min) skips capability probe + goal mapping when context is pre-loaded. **Absorbs the structured-brief role formerly under `grill --mode structured` (deprecated 2026-05-05).**

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

## Persona skills (5)

pandastack is **skill-only**. No agent dispatch. The 5 lead personas live as skills under `skills/{persona}/SKILL.md`, share the structure defined in `lib/persona-frame.md`, and are invoked in-session via `/persona` slash or chained from `boardroom`.

| Skill | When |
|---|---|
| `pandastack:ceo` | Strategic decisions, kill/pivot/continue, framework tension |
| `pandastack:ops-lead` | COO-level — systems that run without you, process-when-painful, decision shape (action / owner / deadline) |
| `pandastack:product-lead` | User problems over solutions, metric-driven, says no more often than yes |
| `pandastack:eng-lead` | Build / debug / ship — minimal diff, root cause, no spiral |
| `pandastack:design-lead` | Intentional over decorative, every element earns its place |

All 5 are READ-ONLY persona skills. They recommend; user decides. Previously also shipped as agents at `agents/{ceo,design,eng,ops,product}.md` — agents/ deleted in v1.1.

---

## Lifecycle flows (7)

Read these when you need to know which skill chain handles a given lifecycle. Each flow file lists Trigger / Phases / Exit / Anti-patterns / Skill choreography.

| Flow | Trigger | File |
|---|---|---|
| dev | new feature, debug, refactor | `flows/dev.md` |
| knowledge | new note, capture | `flows/knowledge.md` |
| writing | draft article / thread | `flows/writing.md` |
| work | alert / ticket / Slack ask | `flows/work.md` |
| research | unfamiliar concept, decision needs prior art | `flows/research.md` |
| retro | daily / weekly / monthly cadence | `flows/retro.md` |
| decision | cron reports accumulated for triage | `flows/decision.md` |

Flows are not skills — they're choreography spec. The skills they call ARE the work. (`solo.md` and `full.md` from earlier versions removed in v1.0.0-rc.3 trim.)

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

Private contexts (in the private overlay) may reference additional skills beyond this index. Public contexts only reference skills listed above.

---

## Provenance: how skills came to live here

| Origin | Skills |
|---|---|
| Built in v0.16 | careful, checkpoint, freeze, init, qa, review, ship (compound / retro / brief / learn from v0.16 removed in v1.0.0-rc.3 — compound + brief absorbed into knowledge-ship/work-ship + office-hours; retro absorbed into retro-week Phase 1; learn dropped, learning search is LLM-native) |
| Added in v1 from `~/.claude/skills/` (local) | deep-research, curate-feeds (renamed from feed-curator in v1.1), grill, knowledge-ship, work-ship, write-ship, persona-pipeline (deprecated v1.1), process-decisions, retro-week, retro-month, gatekeeper (renamed from slowmist-agent-security in v1.1), wiki-lint, tool-bird, tool-notion, tool-railway (removed v1.3, leaked work-project name) |
| Added in v1 from `claude-skills` repo | tool-browser (renamed from agent-browser in v1.1), write (renamed from content-write in v1.1), done, think-like-naval, think-like-alan-chan, think-like-karpathy, tool-deepwiki, tool-pdf, tool-slack, tool-summarize (tool-web-extract removed in v1.2 — folded into `~/.claude/rules/url-routing.md`) |
| Added in v1 (Hermes cron lifecycle) | brief-morning (renamed from morning-briefing in v1.1), evening-distill, retro-prep-week (renamed from weekly-retro-prep in v1.1) |
| Two-strike promoted in v1 | scout (renamed from harness-survey in v1.1) |
| New v1 agent | ops |

`claude-skills` repo's role after v1: hold the residual community-curated content (ops-lead reference, wave-analyst, _archived-*). Most of Panda's personal stack is in pandastack now.

---

## Version

This RESOLVER.md is for pandastack v1.1 (rename batch B0). Update when adding / removing / renaming skills.

---

## Aliases (v1.1, 90-day grace period through 2026-08-04)

The following skill names were renamed in v1.1 B0. Old names still resolve via `aliases:` frontmatter for 90 days. After 2026-08-04, alias entries removed and old names will fail.

| Old name (alias) | New name | Reason |
|---|---|---|
| `agent-browser` | `tool-browser` | cluster `tool-*` |
| `content-write` | `write` | drop redundant prefix |
| `feed-curator` | `curate-feeds` | verb-first |
| `harness-survey` | `scout` | metaphor (Layer 2) |
| `morning-briefing` | `brief-morning` | verb-first |
| `slowmist-agent-security` | `gatekeeper` | metaphor (Layer 2), drop brand |
| `weekly-retro-prep` | `retro-prep-week` | cluster `retro-*` |

If you have hardcoded old names in cron jobs, launchd plists, Hermes manifests, or pdctx context recipes, update before 2026-08-04. `pandastack:scout` will surface remaining old-name references on each run.
