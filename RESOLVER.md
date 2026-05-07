# RESOLVER.md

> Map of every skill / persona / flow / context in pandastack v2. Use this as the index when something looks like overlap or you can't tell which skill to invoke.
>
> Companion to PHILOSOPHY.md (the why) and the per-skill SKILL.md files (the how).

## Why this file exists

pandastack v2 ships 38 skills, 5 personas, 7 lifecycle flows, and 7 context recipes. That's a lot of surface area. RESOLVER.md is the disambiguation layer — when two things look similar but serve different purposes, you read this file to learn the boundary.

This is the pattern used by gstack and alirezarezvani: monorepo + RESOLVER.md beats multi-repo split, because the categorization lives next to the content.

---

## Skill catalog (by lifecycle, not alphabetical)

### Knowledge / research

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:curate-feeds` | Process Inbox feeds, route by source quality | weekly cron, feed pipeline |
| `pandastack:ship knowledge <path>` | Close + Extract + Backflow on a knowledge note (was: `knowledge-ship`) | ship this note |
| `pandastack:scout` | Recon public ecosystem for skill / harness patterns | survey other harnesses |
| `pandastack:summarize` | Summarize URL / podcast / file | summarize, TL;DR |

Vault hygiene (orphans / stale / superseded / dead redirects) is now a direct file scan (`rg` / `find`), not a dedicated skill. v1.x had `wiki-lint` for this; cut in v2.0.0. v2.1.0 cut `deep-research` (gbrain-core skill) since pandastack no longer assumes a brain index.

### Writing

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:write` | Voice-aware drafting + slop detection | help me write |
| `pandastack:ship write <draft>` | Close + Extract + Backflow on a Blog draft (was: `write-ship`) | ship this draft, publish this post |
| `pandastack:brief-morning` | Morning briefing into daily note | any 8am cron (Hermes / launchd / system cron) |
| `pandastack:evening-distill` | End-of-day distill into daily note | any 10pm cron (Hermes / launchd / system cron) |

### Work execution (vault-only, external pushed manually)

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:work-ship` | Close + Extract + Backflow on a work topic | close out this topic |

The `[ ]` items in ship-proposals / cron-reports are walked manually using whichever skill matches each item (`/notion`, `/slack`, `/inbox-triage`). v1.x had `process-decisions` as a central walker; cut in v2.0.0 because cron-report flow is sparse and ad-hoc execution is faster.

Additional work-specific skills (alert triage, Slack scans) ship in the private overlay — see [Private supplement](#private-supplement) below. Long-term plan (T2): work-ship + slack + notion move to a separate `yei-stack` plugin.

### Dev workflow

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:grill` | Adversarial requirement discovery, atomic 5-10 min, surfaces unknown unknowns. For structured-brief output use `office-hours`. | grill me, stress test, what am I missing |
| `pandastack:office-hours` | Structured 5-stage flow producing a brief in `docs/briefs/`. `--quick` mode skips capability probe + goal mapping. | office hours, draft a brief, structured intake |
| `pandastack:careful` | Confirmation gates for production / shared infra | working on prod |
| `pandastack:checkpoint` | Save / resume working state snapshot | pausing work |
| `pandastack:freeze` | Lock editing scope to specific paths | scope discipline |
| `pandastack:qa` | Browser-based UI QA | test this UI |
| `pandastack:review` | Parallel 3-pass review + Codex cross-check | review PR |
| `pandastack:ship` | Test + commit + PR (git mode is default) | code done, ship it |
| `pandastack:sprint` | Single-track 1-2h focused execution: dojo → grill-lite → execute → review → ship | small focused task |
| `pandastack:dojo` | Pre-action prep, surfaces gotchas | before a work session |
| `pandastack:team-orchestrate` | Conductor-driven parallel execution across N independent worktree branches | fan out, run these in parallel |

For multi-step sequential work, run multiple sprints in sequence. v1.x had `execute-plan` as a sequential subagent coordinator; cut in v2.0.0 because it overlapped sprint Phase 3 without earning its complexity.

For greenfield design (DB schema / service topology / ADRs), use `eng-lead` persona inside a sprint. v1.x had a separate `architect` persona; folded into eng-lead in v2.0.0 because Panda's day-to-day is maintenance, not greenfield.

### Retro / session

| Skill | Purpose | Trigger |
|---|---|---|
| `pandastack:retro-week` | Three-phase weekly retro (Auto-scan → Interview → Write). Phase 1 scans vault files directly (rg / find on `Blog/_daily/` + `Inbox/ship-log/`) to fetch retro inputs. | weekly retro |
| `pandastack:retro-month` | Three-phase monthly retro (with weekly retros referenced) | monthly retro |
| `pandastack:done` | Save session context, persist memory | session done, /done |
| `pandastack:inbox-triage` | Weekly Inbox/ hygiene, bucket stale .md by category | clean inbox, scheduled weekly |

v1.x had a separate `retro-prep-week` cron that pre-fetched retro inputs; cut in v2.0.0 and folded into retro-week Phase 1 (direct vault scan is fast enough that a separate cron earned no time savings).

### Tool wrappers (1:1 with CLIs)

| Skill | Wraps |
|---|---|
| `pandastack:bird` | bird CLI (X / Twitter) |
| `pandastack:notion` | notion-cli |
| `pandastack:slack` | slack-cli |
| `pandastack:deepwiki` | DeepWiki repo docs |
| `pandastack:agent-browser` | Browser automation (npm `agent-browser`) |

### Persona thinking frames

| Skill | Frame |
|---|---|
| `pandastack:think-like-naval` | Leverage / specific knowledge / wealth-vs-capture |
| `pandastack:think-like-alan-chan` | Product 0→1 / focus discipline / unfounded inference |

v1.x had `think-like-karpathy` for agent architecture framing; cut in v2.0.0 because Panda cites Karpathy in notes but does not actively use his frame to think.

### Multi-lens review

| Skill | Purpose |
|---|---|
| `pandastack:boardroom` | Single-skill 4-voice critique (CEO → product → design → eng) on a plan. Per-finding apply gate. |

### Trust evaluation (NOT code review)

| Skill | Purpose |
|---|---|
| `pandastack:gatekeeper` | Pre-adoption trust check for external agents / MCP / repos / on-chain. NOT a code review skill. STRIDE classification at Step 0. |

---

## Private supplement

Some lifecycles (work alert triage, on-chain trading research, Sommet network ops) ship as a private overlay outside this index. If you have access to the private stack, its `RESOLVER.md` lists those skills with the same table format. The public index above stays self-contained: anything you can read here, you can install from this repo alone.

---

## Disambiguation: where things look like overlap but aren't

### Sprint vs team-orchestrate

| | sprint | team-orchestrate |
|---|---|---|
| Tracks | 1 | N |
| Executor | Main session | N subagents (one per worktree) |
| Use when | Single focused task; for N-step sequential, run N sprints | N truly independent branches, wall-clock parallelism matters |

Different shapes. Sprint = time line. team-orchestrate = space cut. They are not "sprint × N".

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
- `pandastack:office-hours` — structured 5-stage flow that produces a brief in `docs/briefs/`. Default ~30 min; `--quick` mode (~10-15 min) skips capability probe + goal mapping when context is pre-loaded.

### Two retro skills

| Skill | When |
|---|---|
| `pandastack:retro-week` | Sunday or end of week. Three phases (Auto-scan / Interview / Write). |
| `pandastack:retro-month` | End of month. References past 4 weekly retros. |

### Three ship modes (single skill)

`/ship` is one skill with three modes:

| Mode | Trigger | What it does |
|---|---|---|
| git (default) | `/ship` (no args) or `/ship <branch-flag>` | test + commit + push + PR |
| knowledge | `/ship knowledge <path>` or `/ship knowledge/...` | Close + Extract + Backflow on a knowledge note |
| write | `/ship write <draft>` or `/ship Blog/_daily/...` | Close + Extract + Backflow on a Blog draft |

`work-ship` stays separate (different artifact: external system push proposals). Will move to yei-stack in T2.

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
| `pandastack:eng-lead` | Build / debug / ship — minimal diff, root cause, no spiral. Also covers tech-stack / DB schema / API contract decisions (was: separate `architect` persona in v1.x, folded in v2.0.0). |
| `pandastack:design-lead` | Intentional over decorative, every element earns its place |

All 5 are READ-ONLY persona skills. They recommend; user decides.

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

Private contexts (in the private overlay) may reference additional skills beyond this index. Public contexts only reference skills listed above.

---

## v2.1.0 cut summary

| Action | Items | Reason |
|---|---|---|
| Cut skill | `deep-research` | gbrain-core: required `gbrain` CLI + brain index; pandastack v2.1.0 stops assuming a brain index |
| Cut context | `work-sommet-abyss-po` | Sommet Abyss inactive; will land in a separate plugin if revived |
| Cut substrate dependencies | `gbq` / `gbrain` calls across `brief-morning`, `evening-distill`, `dojo`, `done`, `retro-week`, all `flows/*.md` | substrate-agnostic: vault scan via `rg` / `find` works on any clone, no brain prerequisite |

## v2.0.0 cut summary

| Action | Skills | Reason |
|---|---|---|
| Cut (orphan / overlap / replaced) | `atomize`, `architect`, `execute-plan`, `think-like-karpathy`, `process-decisions`, `wiki-lint`, `retro-prep-week` | atoms.jsonl pattern died; greenfield rare → fold into eng-lead; sequential subagent overlapped sprint Phase 3; Karpathy frame referenced not used; cron-reports sparse → manual walk; vault lint → file scan; retro pre-fetch → fold into retro-week Phase 1 |
| Merged into `/ship` | `knowledge-ship`, `write-ship` → `/ship knowledge`, `/ship write` | one verb, one mental model |
| Renamed in v1.4.0 (still aliased) | `tool-pdf`→`pdf` (then deleted v1.4.1), `tool-bird`→`bird`, `tool-slack`→`slack`, `tool-notion`→`notion`, `tool-deepwiki`→`deepwiki`, `tool-summarize`→`summarize`, `tool-browser`→`agent-browser` | drop tool- prefix, names already disambiguate via `pandastack:` namespace |

## Provenance: how skills came to live here

| Origin | Skills |
|---|---|
| Built in v0.16 | careful, checkpoint, freeze, init, qa, review, ship |
| Added in v1 from `~/.claude/skills/` (local) | deep-research (v2.1.0: cut), curate-feeds, grill, knowledge-ship (v2: merged into ship), work-ship, write-ship (v2: merged into ship), retro-week, retro-month, gatekeeper, bird, notion, summarize, deepwiki, agent-browser, slack |
| Added in v1 (Hermes cron lifecycle) | brief-morning, evening-distill |
| Two-strike promoted in v1 | scout |
| Persona skills | ceo, eng-lead, design-lead, ops-lead, product-lead |
| Frame skills | think-like-naval, think-like-alan-chan |
| Decision/sprint flow | sprint, dojo, office-hours, boardroom, team-orchestrate |
| Meta | using-pandastack, init, done, inbox-triage |

---

## Version

This RESOLVER.md is for pandastack v2.1.0. Update when adding / removing / renaming skills.

---

## Aliases (90-day grace)

The following skill names were renamed/merged across versions. Old names still resolve via `aliases:` frontmatter for 90 days from each rename. After grace period, alias entries are removed and old names will fail.

| Old name (alias) | New name | Renamed in | Grace until |
|---|---|---|---|
| `knowledge-ship` | `ship knowledge` | v2.0.0 (2026-05-07) | 2026-08-05 |
| `write-ship` | `ship write` | v2.0.0 (2026-05-07) | 2026-08-05 |
| `tool-bird` | `bird` | v1.4.0 | 2026-08-05 |
| `tool-slack` | `slack` | v1.4.0 | 2026-08-05 |
| `tool-notion` | `notion` | v1.4.0 | 2026-08-05 |
| `tool-deepwiki` | `deepwiki` | v1.4.0 | 2026-08-05 |
| `tool-summarize` | `summarize` | v1.4.0 | 2026-08-05 |
| `tool-browser` | `agent-browser` | v1.4.0 | 2026-08-05 |
| `agent-browser` | `tool-browser` | v1.1 (then reverted in v1.4.0) | n/a |
| `content-write` | `write` | v1.1 | expired 2026-08-04 |
| `feed-curator` | `curate-feeds` | v1.1 | expired 2026-08-04 |
| `harness-survey` | `scout` | v1.1 | expired 2026-08-04 |
| `morning-briefing` | `brief-morning` | v1.1 | expired 2026-08-04 |
| `slowmist-agent-security` | `gatekeeper` | v1.1 | expired 2026-08-04 |
| `weekly-retro-prep` | `retro-prep-week` (then deleted v2.0.0) | v1.1 → cut v2.0.0 | n/a |

If you have hardcoded old names in cron jobs, launchd plists, Hermes manifests, or pdctx context recipes, update before 2026-08-05.
