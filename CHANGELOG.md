# Changelog

## Unreleased (v1.0.0-rc.3 candidate)

### Added

- `lib/goal-mapping.md` — shared module documenting goal-hierarchy
  pre-step. Reads user's L1 (long horizon) / L2 (this season) /
  L3 (this week) goals from `<memory-dir>/`, maps the current task to
  each layer, picks the dominant layer, and feeds downstream Clarify +
  Alternatives steps so questions adapt to the user's actual goal
  hierarchy instead of running generic forcing questions in a goal
  vacuum.

### Changed

- `skills/brief/SKILL.md` and `skills/grill/SKILL.md` (`--mode
  structured`): inserted **Step 1.5 Goal Mapping** between Load
  Context and Clarify. Step 2 Clarify now smart-skips forcing
  questions answered by goal mapping. Step 3 Premise Challenge adds a
  fourth premise checking dominant-layer framing. Step 4 Alternatives
  filters options to the dominant layer and flags constraint
  violations from non-dominant layers. Gate Log gains a Goal Mapping
  line.
- `skills/grill/SKILL.md` default (adversarial) mode: added "Pre-step:
  Goal Mapping (recommended)" pointer so adversarial drilling lands
  with awareness of what is actually being protected.
- All public skill content went through a personal-info hygiene pass
  (separate `chore(hygiene)` commit): hardcoded vault / CLI / memory /
  skills paths replaced with `<placeholder>` tokens; team handles,
  Slack workspace IDs, and Yei repo names replaced with generics;
  README gained a "Path tokens" section documenting the convention
  for external users to bind via private overlay.
- `commands/sprint.md`, `commands/fix.md`, `commands/design.md`:
  replaced `/ps-compound` references with `/pandastack:knowledge-ship`
  or `/pandastack:work-ship` (compound logic was absorbed in v1.0.0
  but the composite commands still pointed at the dead skill).
- `plugins/pandastack/CLAUDE.md`: refreshed from stale `pstack`-era
  content. Removed references to deleted skills, updated to v1
  composite command names, mentioned new goal-mapping pre-step.
- `README.md`: removed `/pandastack:learn` from Dev workflow primitives
  table; removed `solo.md` / `full.md` mentions from Lifecycle Flows
  (those files are deleted); fixed a stale `/pandastack:retro` ref to
  `/pandastack:retro-week`.
- `RESOLVER.md`: removed `pandastack:learn` from Dev workflow table;
  noted `solo.md` + `full.md` removed; updated Provenance to reflect
  the v1.0.0-rc.3 trim.

### Removed (over-scaffold trim)

Audit pass identified zombie skills, orphan lib modules, and
old-version flow files. Removed:

| Removed | Why |
|---|---|
| `skills/compound/` | Logic absorbed into knowledge-ship/work-ship Stage 3 in v1.0.0; SKILL.md remained as a zombie |
| `skills/retro/` | Logic absorbed into retro-week Phase 1 in v1.0.0; SKILL.md remained as a zombie |
| `skills/learn/` | 0 dispatches anywhere; "search learnings" function is LLM-native (just grep + read) |
| `lib/stop-check.md` | Orphan — 0 references; advisory checks rebuildable from prompt if needed |
| `flows/full.md` | Earlier-version reference per README; superseded by `flows/dev.md` |
| `flows/solo.md` | Earlier-version reference per README; superseded by `flows/dev.md` |

### Why this matters

`docs/sessions/2026-05-01` audit found ~12-15 dead-weight files in the
public stack: 3 zombie skills (CHANGELOG declared removed but files
still shipping), 1 orphan lib module, 2 old-version flow files, plus
several stale dispatch references in composite commands. Trimming
~20-30% of the dead surface area before alpha testers see the stack.
The remaining substrate (pdctx hooks, memory firewall, using-pandastack
contract, careful gate, etc.) was audited and judged justified — each
solves something the model cannot do reliably from prompting alone.

## v1.0.0-rc.2 — 2026-04-30

Codex CLI multi-CLI support. Skill content stays Claude-first; Codex consumes via tool-name mapping injected at session start. Modeled on Superpowers v5.0.7's per-CLI shim pattern.

### Added

- `plugins/pandastack/.codex-plugin/plugin.json` — Codex native plugin manifest
- `plugins/pandastack/.codex/INSTALL.md` — clone + symlink install path for Codex 0.124.0+
- `plugins/pandastack/AGENTS.md` — symlink to `CLAUDE.md` (Codex convention)
- `plugins/pandastack/skills/using-pandastack/references/codex-tools.md` — Claude → Codex tool-name mapping (`Skill` / `Agent` / `TaskCreate` → native skill load / `spawn_agent` / `update_plan`), local CLI dependency notes, named subagent dispatch workaround

### Changed

- `plugins/pandastack/hooks/session-start` — 3-platform output envelope (Cursor / Claude Code / Codex+Copilot+default), all paths emit valid JSON
- README: tagline + new "Other runtimes" subsection pointing at `.codex/INSTALL.md`

### Verified

- End-to-end on Codex CLI 0.124.0 via `~/.codex/skills/pandastack` symlink: all 40 skills enumerated, SKILL.md frontmatter readable.
- Audit: 17/40 SKILL.md fully portable, 22/40 needs Codex tool-mapping adapter, 7% Claude-only by definition (hooks mechanic, subagent format, slash command format).

## v1.0.0-rc.1 — 2026-04-29

Major scope expansion. The stack grows from a dev-only workflow (brief → build → review → ship → compound) into a 7-lifecycle personal AI operator OS.

### Added

**Skills (+15 from old `~/.claude/skills/`, +11 from `claude-skills` repo, total ~37 skills now):**

- Knowledge / research: `deep-research`, `feed-curator`, `knowledge-ship`, `wiki-lint`, `tool-summarize`, `tool-web-extract`
- Writing: `content-write`, `write-ship`
- Work execution: `work-ship`, `process-decisions`
- Retro / session: `retro-week`, `retro-month`, `done`
- Tool wrappers: `tool-bird`, `tool-notion`, `tool-railway`, `tool-deepwiki`, `tool-pdf`, `tool-slack`, `agent-browser`
- Persona thinking: `think-like-naval`, `think-like-alan-chan`, `think-like-karpathy`
- Multi-lens: `persona-pipeline`
- Trust evaluation: `slowmist-agent-security`

**Agents (+1):**

- `ops` — COO / operations lead. Build systems that run without you, process when there's real pain.

**Lifecycle flows (+7):**

- `flows/dev.md` — original dev workflow, now formal flow spec
- `flows/knowledge.md` — capture → distill → verify → ship → lint
- `flows/writing.md` — capture → structure → draft → ship → distribute
- `flows/work.md` — triage → context → execute → ship → push (vault-only)
- `flows/research.md` — scope → fetch → dive → distill → ship
- `flows/retro.md` — daily / weekly / monthly cadence
- `flows/decision.md` — cron-driven decision triage

**Context recipes (+8):**

`contexts/*.toml` — bind flow + persona + skill subset to identity. Read by future pdctx loader. Eight recipes covering personal dev / writer / knowledge-manager / trader and work yei-ops / yei-hr / yei-finance / sommet-abyss-po.

**Other:**

- `RESOLVER.md` at repo root — disambiguation index for the larger surface area. Read this when two skills look like they overlap.

### Changed

**`grill` skill** now has two modes:

- Default: adversarial requirement discovery (unchanged from v0.16-era)
- `--mode structured`: 5-step structured brief flow that **replaces the deprecated `pandastack:brief`**

**`retro-week` and `retro-month` skills** are now three-phase:

- Phase 1: Auto-scan (git log + learnings/ + daily highlights — replaces standalone `pandastack:retro`)
- Phase 2: Interactive interview
- Phase 3: Write retro to `docs/retros/{weekly,monthly}/`

**`knowledge-ship` and `work-ship` Stage 3 Backflow** added a row that writes to `docs/learnings/<category>/<slug>.md` — **replaces standalone `pandastack:compound`**.

### Removed (from v0.16)

These three skills are gone in v1; their logic was absorbed into other skills:

| Removed | Absorbed into |
|---|---|
| `pandastack:brief` | `pandastack:grill --mode structured` |
| `pandastack:retro` | `pandastack:retro-week` Phase 1 (Auto-scan) |
| `pandastack:compound` | `pandastack:knowledge-ship` and `pandastack:work-ship` Stage 3 |

### Migration from v0.16

If you're upgrading from v0.16:

```bash
# Update the plugin
/plugin marketplace update pandastack
/plugin update pandastack@pandastack
```

**Breaking changes**: none for skill INVOCATION — the three removed skills' logic still runs, just via the absorbing skills. Specifically:

- If you previously ran `/pandastack:brief`, run `/pandastack:grill --mode structured` instead.
- If you previously ran `/pandastack:retro`, run `/pandastack:retro-week` (its Phase 1 does what the old skill did).
- If you previously ran `/pandastack:compound`, run `/pandastack:knowledge-ship` or `/pandastack:work-ship` and answer the Extract-stage questions.

No agent renames in this release. The 4 v0.16 agents (`ceo`, `design`, `eng`, `product`) keep their names. The new `ops` is additive.

### Plugin description

Old: `4 agent personas, 11 skills, 5 composite commands. brief → build → review → ship → compound.`
New: `5 agent personas, ~37 skills, 7 lifecycle flows, 8 context recipes. Personal AI operator OS for dev / knowledge / writing / work / research / retro / decision lifecycles.`

---

## v0.16.0 — earlier

(Pre-changelog releases. See git log for older history.)
