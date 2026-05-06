# Changelog

## v1.3.0 — 2026-05-07

> Fresh-install hardening. Tier model + bootstrap script + decoupled hardcoded data. Goal: a fresh A-class clone runs Core skills without author hand-holding. Personal-CLI skills become opt-in via private overlay rather than baked into public skills. Skill count 49 → 48 (removed `tool-railway`).

### Added

- `plugins/pandastack/manifest.toml` — single source of truth for skill tier (`core` / `ext` / `personal`) + dependency declarations (`requires` + `config`). Read by `scripts/bootstrap.sh` and capability-probe.
- `scripts/bootstrap.sh` — fresh-clone onboarding: probes substrate, lists 35 core skills runnable now, prints exact `brew install` / `npm install -g` per ext skill, marks personal skills as needing the private overlay. Single entrypoint replaces the previous 4-section README install dance.
- `plugins/pandastack/skills/curate-feeds/scripts/curate-feeds.ts` — script moved in-tree from `~/site/cli/feed-server/scripts/curate-feeds.ts`. Skill is now self-contained on the script side; the feed-server daemon stays a separate concern (HTTP-only contract). Script also patched to require `PANDASTACK_VAULT` env var (was: hardcoded vault path) and accept `PANDASTACK_FEED_SERVER` override.
- `plugins/pandastack/skills/gatekeeper/` — gatekeeper bumped 0.2.0 → 0.3.0 with DeFi protocol governance / admin risk review (`reviews/defi-protocol.md` + `templates/report-defi-protocol.md`). Triggers on "看這個協議的中央化風險" and pre-deposit due diligence on lending / yield / RWA / stableswap protocols.

### Changed

- **Hardcoded data extracted to env vars** (was: baked into SKILL.md body):
  - `pandap.d819@gmail.com` → `${PANDASTACK_USER_EMAIL}` in `brief-morning`, `evening-distill`, `personal-writer.toml`
  - `/Users/panda/site/knowledge/work-vault/**` → `${PANDASTACK_WORK_VAULT}/**` in 17 skill frontmatter `forbids`
  - `/Users/panda/site/knowledge/obsidian-vault/...` → `<vault>/...` in `atomize/SKILL.md`
  - `~/site/skills/pandastack/plugins/pandastack/skills/<persona>/SKILL.md` → `${PANDASTACK_HOME}/skills/<persona>/SKILL.md` resolution chain in `lib/persona-frame.md`, `execute-plan/SKILL.md`, `scout/SKILL.md`
- **Work-context leakage cleaned out of public surface**:
  - `tool-railway` deleted (leaked `natural-joy (Yei Sentinel)` project name and Railway service topology)
  - `think-like-naval`, `think-like-karpathy`, `think-like-alan-chan` example dialogues rewritten with generic operator dilemmas (was: pstack / Yei / Abyss / DeFi protocol ops)
  - `execute-plan` risk classification table: `Yei/Abyss protocol ops` → `Production protocol ops (smart contracts, treasury, governance, on-chain writes)`
  - Context TOML deny comments: `Sommet ticketing` / `Yei ticketing (Jira)` → `work issue tracker` (generic)
- **Private skill refs decoupled from public flows**:
  - `flows/work.md` and `flows/decision.md` now mark `yei-alert-triage`, `misalignment`, `harness-slim` as `[private overlay, optional]`. Public flow runs without them.
- **README install section collapsed**: 4 host-specific sections (~80 lines) → one bootstrap-driven flow + per-host one-liner table. Quick-start now points at `bash scripts/bootstrap.sh --claude`.
- `personal-writer.toml`, `personal-trader.toml`, `personal-knowledge-manager.toml`: removed dangling `pandastack:tool-web-extract` reference (skill was archived in v1.2.1).

### Removed

- `plugins/pandastack/skills/tool-railway/` — leaked work-context project name (`natural-joy (Yei Sentinel)`) into a generic Railway skill. Railway docs / common diagnosis flow not unique enough to justify a tool wrapper; users can read Railway's official CLI docs directly.

### Migration

- **Set env vars** in your shell rc (`~/.zshrc` / `~/.bashrc`):
  ```bash
  export PANDASTACK_VAULT=$HOME/path/to/your/vault
  export PANDASTACK_HOME=/absolute/path/to/pandastack/plugins/pandastack
  export PANDASTACK_USER_EMAIL=you@example.com           # only for brief-morning / evening-distill
  export PANDASTACK_WORK_VAULT=$HOME/path/to/work-vault  # only if separate work vault
  ```
- **Run** `bash scripts/bootstrap.sh` to verify state.
- **If you had `pandastack:tool-railway` in any context recipe or cron**: remove it. No replacement; use Railway's own docs.
- **L5 firewall behavior**: skills that previously had hardcoded `forbids: /Users/panda/...` now use `${PANDASTACK_WORK_VAULT}`. If your firewall implementation does not do env-var expansion in TOML/YAML, set the env var to your work-vault path; if you don't have a work vault, leave the env var unset and the forbid pattern simply doesn't match anything (pass-through).

### Why this batch

Audit 2026-05-07 surfaced that v1.2 was honest about being personal-substrate-stable (`0 fresh installs`) but didn't lower the install bar. Tier model + bootstrap script ship the structural fix needed for fresh-install viability. Author launchd jobs disabled in same session (operational, not in scope of this changelog).

## v1.2.2 — 2026-05-06

> Stability scope clarified: v1 = personal-substrate stable, v2 = public-ready. README and capability-probe reframed to reflect 0 fresh-user installs over 6 months and the v1 dogfood reality (1 user, the author). No skill content changes; documentation reframe only.

### Why this reframing

Original v1.0 README presented pandastack as fresh-user-ready. 6-month dogfood window (2026-04-30 → 2026-05-07) confirmed: 0 fresh A-class users (Obsidian + Coding Agent power users) successfully ran `/plugin install` end-to-end without author intervention. The TA stated in v1 README was aspiration, not validated reality. Continuing to ship v1 stable while claiming public-readiness misrepresents the substrate's actual maturity.

Two paths considered and rejected:
1. **Hold v1 cut** until 1-3 fresh users complete install + 1 week of use. Rejected: Sommet PO + companyos Phase 1 sprint backlog leaves no bandwidth for active outreach; finding fresh users on a deadline is not in the author's control.
2. **Ship v1 stable as-is, accept TA gap**. Rejected: gaps that are not visible cannot be fixed. Without an explicit v2 scope, the public-readiness work would never get prioritized.

Chosen: reframe v1 as personal-substrate stable, scope public-readiness to v2 with explicit roadmap. Ship 5/7 stable cut on schedule with the corrected framing. See `docs/briefs/2026-05-06-pandastack-v1-stable-cut.md` (vault-side brief) for full reasoning, alternatives considered, and gate log.

### Changed

- `README.md`:
  - Line 7 area: "v1.0.0 stable" claim split into two scopes. v1 = personal-substrate stable (author's daily use, dogfooded across 4 of 7 lifecycles). Public-readiness deferred to v2 with explicit `0 fresh-user installs` data point.
  - New "Stability scope (read this first)" callout added before "Who this is for" — makes the scope distinction load-bearing rather than buried.
  - "Quick start" section: dev-mode notice prepended. Tells fresh users that substrate (vault, gbq, pdctx) must be set up separately and that capability-probe will surface gaps rather than fail silently.
  - "Who this is for": added 4th bullet stating v1 dogfood reality (1 user, author).
- `plugins/pandastack/lib/capability-probe.md`: fresh-clone dev-mode hint appended to "Action by probe result" → "Degraded mode rules". Tells fresh users that substrate degradation is expected on v1 and points at v2 roadmap.

### Added

- `ROADMAP.md` (new, repo root) — explicit v2 scope: onboarding scaffold, multi-vault provider abstraction (Logseq / Roam / Notion), fresh A-user dogfood criteria. Open questions on v2 timeline (when to start; conditional on fresh user inbound vs scheduled). Companion to this CHANGELOG entry; lives in repo so version-controlled rather than in vault-only briefs.

### Migration

No code or skill changes. Existing v1.x users: no action needed; behavior is identical. Fresh-clone users: read the "Stability scope" section in README before installing. The `pandastack:init` flow already runs capability-probe; degraded states now point at the v2 roadmap rather than implying the install is broken.

## v1.2.1 — 2026-05-05

> Surface area slim: `tool-web-extract` archived, routing folded into `~/.claude/rules/url-routing.md`. Skill count 51 → 50 active.

### Removed

- `tool-web-extract` skill (56 lines, archived to `skills/_archive/tool-web-extract-2026-05-05/`). Skill was a thin wrapper over Defuddle CLI flags; routing already lived in `~/.claude/rules/url-routing.md` Fallback Chain section. Defuddle command reference (the only procedural value the skill held) folded into the same rule file under new "Defuddle command reference" subsection.

### Cross-reference updates

- `RESOLVER.md` — removed `pandastack:tool-web-extract` row + updated "Added in v1" list to note removal.
- `plugins/pandastack/skills/using-pandastack/references/codex-tools.md` — defuddle row points at url-routing rule instead of skill.
- `plugins/pandastack/flows/research.md` — Phase 3 + skill choreography updated to invoke `defuddle parse <url> --md` directly per url-routing rule. Same pass also fixed a stale `feed-curator` reference to `curate-feeds` (v1.1 rename followup).

### Migration

If any downstream skill or doc still references `pandastack:tool-web-extract`, the replacement is the rule reference: `~/.claude/rules/url-routing.md` § "Defuddle command reference" + § "Fallback Chain".

## v1.2.0 — 2026-05-05

> Surface area cleanup + decision-tree completeness. Two changes: (a) `grill --mode structured` removed, structured-brief role consolidated into `office-hours --quick`; (b) `team-orchestrate` skill built early to fill the Q3 hole in `lib/skill-decision-tree.md`. Net skill count unchanged (-1, +1).

### Added

- `skills/team-orchestrate/SKILL.md` — Conductor-driven parallel execution. Dispatches N independent branches to subagents in a single message, each in its own git worktree, gates each branch as it returns. Mirrors `execute-plan` Phase 0-3 structure but parallel. Fills the Q3 destination of `lib/skill-decision-tree.md` (was marked "future / two-strike pending"; built early because the architecture had a structural hole, not an emergent pattern).
- `skills/office-hours/SKILL.md` `--quick` flag — skips Stage 1 (capability probe + gbq load + goal mapping) when context is pre-loaded in-session. Reduces total time from ~30 min to ~10-15 min. Replaces the structured-brief role formerly under `grill --mode structured`.

### Removed

- `grill --mode structured` body removed (was lines 162-309 of `skills/grill/SKILL.md`). Grill returns to atomic adversarial-only positioning. The "5-step structured brief flow" content is no longer needed because `office-hours` already covers the same 5 stages with better staging (capability probe → premise challenge → alternatives → premise refresh → output) and `--quick` mode handles the case where context is already loaded.

### Why this consolidation

`grill --mode structured` (added v1.1 to absorb deprecated `pandastack:brief`) and `office-hours` (5-stage flow) overlapped ~70% by the dogfood window: both did Load Context → Premise Challenge → Alternatives → Brief output. The middle ground was a naming smell — "grill" but with brief output. Single canonical structured-brief skill is `office-hours` going forward.

### Cross-reference updates

- `RESOLVER.md` (rows 52, 124, 207) — split grill / office-hours rows, removed `--mode structured`.
- `plugins/pandastack/CLAUDE.md` (lines 12, 42) — split skill list, updated goal-mapping note.
- `plugins/pandastack/lib/push-once.md` — removed `--mode structured` from skill list.
- `plugins/pandastack/lib/stop-rule.md` — `--mode structured` Step 4 → `office-hours` Stage 3.
- `plugins/pandastack/lib/escape-hatch.md` — split grill / office-hours skill rows.
- `plugins/pandastack/lib/skill-decision-tree.md` — removed "future / two-strike pending" qualifiers from team-orchestrate (5 places).
- `plugins/pandastack/lib/persona-frame.md` — removed "future" qualifier from team-orchestrate mention.
- `plugins/pandastack/skills/execute-plan/SKILL.md` line 21 — `pandastack:grill --mode structured` → `pandastack:office-hours`.
- `plugins/pandastack/skills/scout/SKILL.md` line 206 — same swap.
- `plugins/pandastack/skills/grill/SKILL.md` — frontmatter description, in-body refs, Origin section all updated.
- `plugins/pandastack/skills/office-hours/SKILL.md` — frontmatter description, Modes section, Stage 1 skip-on-quick, Stage 5 routing.
- `plugins/pandastack/flows/dev.md` — Phase 1 + skill choreography updated.
- `tests/resolver-golden.md` T08 — `/grill --mode structured` → `/office-hours --quick`.

### Migration

- If you previously ran `/grill --mode structured`, run `/office-hours --quick` instead (when context is already loaded) or `/office-hours` (full mode, when starting cold).
- No alias period — `--mode structured` was added v1.1.0 (2026-05-04), removed v1.2.0 (2026-05-05). 1-day lifecycle inside dogfood window means alias overhead not justified.

## v1.1.0 — 2026-05-04

> Skill-only redesign. agents/ + commands/ + persona-pipeline deleted. 9 new skills + 7 new lib/ modules + 1 regression test file. 7 skill renames with 90-day alias period through 2026-08-04. Codex review patches integrated (Q3 reverted by user, Q4 / Q6 / Q7 / Q9 + 2 blind spots applied).



### Renamed (v1.1 B0, 2026-05-04, 90-day alias period through 2026-08-04)

7 skill directory renames; old names remain valid via SKILL.md `aliases:`
frontmatter and RESOLVER.md Aliases section through 2026-08-04. After that
the alias entries will be removed and old names will fail.

| Old | New | Reason |
|---|---|---|
| `agent-browser` | `tool-browser` | cluster `tool-*` |
| `content-write` | `write` | drop redundant prefix |
| `feed-curator` | `curate-feeds` | verb-first |
| `harness-survey` | `scout` | metaphor (Layer 2) |
| `morning-briefing` | `brief-morning` | verb-first |
| `slowmist-agent-security` | `gatekeeper` | metaphor (Layer 2), drop brand |
| `weekly-retro-prep` | `retro-prep-week` | cluster `retro-*` |

Cross-reference updates in same batch:
- `RESOLVER.md`: 7 skill rows updated + new "Aliases" section listing all v1.1 renames.
- `README.md`: 3 cron-job table entries + Hermes example dispatch updated.
- `plugins/pandastack/contexts/personal-writer.toml`: 5 skill refs updated
  (`content-write` → `write`, `morning-briefing` → `brief-morning`,
  `weekly-retro-prep` → `retro-prep-week`, plus 2 footer notes).
- `plugins/pandastack/contexts/personal-knowledge-manager.toml`:
  `feed-curator` → `curate-feeds`.
- `~/.agents/AGENTS.md` (Tier 1 substrate): `agent-browser` → `tool-browser`
  in Tool Routing table + Fallback chain.
- `vault/AGENTS.md`: `feed-curator` → `curate-feeds` (3 references).
- `~/.codex/agents/morning-briefing.toml` → `brief-morning.toml` (file rename).

### Removed (v1.1, 2026-05-04)

pandastack is **skill-only** as of v1.1. agents/ and commands/ entirely deleted, no alias period.

- `agents/`: full directory deleted. Previously held 5 lead persona agents
  (`ceo / eng / design / ops / product`, renamed to `*-lead` in B2.5 then
  deleted). Persona content lives in `skills/{persona}/SKILL.md` only.
- `commands/`: full directory deleted. 5 files removed:
  `sprint.md` → replaced by `skills/sprint/SKILL.md`,
  `brainstorm.md` → replaced by `skills/office-hours/SKILL.md`,
  `fix.md` / `quick.md` / `design.md` → folded into `skills/sprint/SKILL.md`
  (auto-detect bug context, `--quick` mode, design-lead auto-invoke on UI scope).
- `skills/persona-pipeline/`: deleted. Replaced by `skills/boardroom/SKILL.md`
  (single-skill 4-voice critique, no agent chain).

Rationale: user direction (2026-05-04) — pandastack is skill-first, no agent
overhead for in-session quick-lens use. Single execution model, single
resolver path, fewer contracts. If genuinely need cold-context parallel
critique, the built-in `Agent` tool can dispatch with a persona skill as
system prompt — no separately-maintained agent file needed.

Resolver impact: prompts that previously fired `persona-pipeline` or any of
the 5 persona agents now route to the corresponding persona skill instead.
Persona content identical (same Soul / Iron Laws / Cognitive Models / On
Invoke / Anti-patterns), now lives only in `skills/{persona}/SKILL.md`.

Codex Q3 (hybrid: keep agents alongside skills) was applied earlier in this
session, then rejected by user — user direction was skill-only from the
start. Hybrid was a regression. This batch reverses the hybrid attempt.

### Added

- `lib/outside-voice-rule.md`: new "Prior-direction conflict rule" section.
  When a codex / external-voice finding contradicts a prior explicit user
  statement (in session, in `~/.agents/AGENTS.md`, in project AGENTS.md, in
  validated memory), the integrating skill must surface the conflict via
  `[reverse / hold / edit]` gate instead of standard `[Y/N/edit]`. The standard
  Y is ambiguous between "agree with codex" and "ack the input"; reverse/hold
  forces explicit reversal-or-hold. Origin: 2026-05-04 session, codex Q3 hybrid
  applied via standard Y gate, ate ~30 min of work that was reverted at session
  end. Learning at `docs/learnings/architecture/2026-05-04-skill-only-vs-hybrid-pandastack.md`.

- `skills/done/SKILL.md` Step 4 Commit handoff (v3.2.0):
  `/done` now closes the session by proposing a commit of the artifacts it
  writes (session.md / daily-note updates / memory entries / optional learnings)
  plus any working-tree code changes from the session. Auto-detects logical
  units (vault writes vs learnings vs code) and offers `[approve / edit /
  split / skip]` gate. Vault writes default to approve (auto-resolve scope per
  AGENTS.md Routing Principles); code changes wait for explicit approve. Skips
  silently when working tree is clean. Solves the "operator forgets to commit
  artifacts at end of session" gap, which led to long-running working trees
  with mixed session work.

- **B6** — `skills/sprint/SKILL.md`: focused 1-2 hour execution flow, 7 stages
  (capability probe → dojo → grill lite → execute → review → ship gate →
  terminal state). 4 explicit terminal states (codex Q4 patch):
  `SHIPPED / PAUSED / FAILED / ABORTED_BY_USER`. Only SHIPPED triggers
  ship/extract/backflow. Modes: default / `--quick` / `--design`. Replaces
  deleted `commands/sprint.md` + `commands/fix.md` + `commands/quick.md` +
  `commands/design.md`. Auto-invokes `design-lead` skill on UI scope detection.

- **B5** — `skills/office-hours/SKILL.md`: 30-min structured pressure cooker,
  5 internal stages (capability probe + load context → premise challenge with
  push-once menu → forced alternatives 2-3 named approaches with stop-rule
  per-approach gate → premise refresh → write brief). Replaces deleted
  `commands/brainstorm.md`. Distilled from gstack `/office-hours` 943 lines
  into ~250 lines + 5 lib refs.

- **B4** — `skills/boardroom/SKILL.md`: multi-voice plan critique. Single
  skill swaps between 4 voices (CEO → product → design → eng) sequentially
  via `lib/persona-frame.md` voice-switching contract. Per-finding `Apply?
  [Y/N/edit]` gate with rejected → OPEN_QUESTIONS. Replaces deprecated
  `persona-pipeline` agent chain. Optional 5th voice (`ops-lead`) when plan
  is ops-dominant. Voice ordering rationale documented inline.

- **B3** — `skills/dojo/SKILL.md`: lifecycle Stage 0 — pre-action prep.
  5 internal stages (capability probe → past-case gbq → lib + pattern load →
  gotcha surface → output prep brief). Used by `/sprint`, `/office-hours`,
  any flow needing past-case lookup. Aliased as `/prep`. Codex Q6 patch
  systematizes the pre-action context that CE / gstack do implicitly.

- **B2.5** — Persona naming reconciliation, then deletion. `agents/` dir
  renamed (`{eng,design,product,ops}.md` → `*-lead.md`) to align with skill
  names, then entire `agents/` directory deleted in same batch. pandastack
  is skill-only from v1.1 forward. The codex Q3 hybrid (keep agents alongside
  skills) was rejected by user — original direction was no agents, hybrid
  was a regression.

- **B2** — 6 new shared `lib/` modules + 5 new lead persona skills.

  Lib modules (each ~80-150 lines, all under `plugins/pandastack/lib/`):
  - `escape-hatch.md` — 2-strike user-impatience hard cap. Ref'd by grill / office-hours / boardroom / gatekeeper / dojo.
  - `bad-good-calibration.md` — 4 BAD → GOOD voice posture pairs (mirrors `~/.agents/AGENTS.md` Voice section). Ref'd by grill / office-hours / boardroom / review / write / brief-morning / evening-distill.
  - `outside-voice-rule.md` — third-party finding integration with per-finding `[Y/N/edit]` gate, OPEN_QUESTIONS routing for N. Ref'd by review (Step 6.5) / boardroom / gatekeeper / scout.
  - `stop-rule.md` — per-decision AskUserQuestion gate enforcement. "A clearly winning option is still a decision." Ref'd by grill (Step 4) / review / boardroom / sprint / office-hours.
  - `persona-frame.md` — 6-section shared structure (Soul / Iron Laws / Cognitive Models / On Invoke / Anti-patterns) for the 5 lead personas. Defines skill-mode vs agent-mode equivalence. Ref'd by 5 lead skills + boardroom (B4 will use it for voice switching).
  - `capability-probe.md` — 8-check substrate availability probe with degraded-mode rules and abort messages (codex Q6 patch). Ref'd by all Layer 1 flow skills (sprint / office-hours / boardroom / dojo / prep) at startup.

  5 lead persona skills (each ~80-100 lines):
  - `skills/ceo/SKILL.md` — strategic advisor (no `-lead` suffix; CEO already exec).
  - `skills/eng-lead/SKILL.md` — staff engineer.
  - `skills/design-lead/SKILL.md` — senior designer.
  - `skills/product-lead/SKILL.md` — VP Product.
  - `skills/ops-lead/SKILL.md` — COO.

  Each lead skill refs `lib/persona-frame.md` for shared 6-section contract (Soul / Iron Laws / Cognitive Models / On Invoke / Anti-patterns) and `lib/bad-good-calibration.md` for voice posture. Cognitive model + iron law content was lifted from the (now deleted) agents/ directory and is the single source of truth in skill files.

- **B-test** — `tests/resolver-golden.md`: 30-prompt regression test
  covering direct slash invocation (12), old-name aliases (7), natural
  language triggers (8), and capability-probe degradation (3). Acceptance
  criteria: ≥27/30 pass on slash+alias+probe, ≥6/8 on natural language.
  Failure response protocol documented. Codex Blind Spot 2 patch — pandastack
  had no regression test, all dogfood was manual; 39 → 12 layer-1 + 9 renames
  + 4 new flows is high regression surface.

- `lib/push-once.md` (B7): new shared module. 5 named pushback patterns
  (具體一點 / 證據檢查 / 反命題 / 邊界條件 / 自由發問) extracted from
  gstack office-hours residue, refed by `grill` (now), `office-hours` (B5),
  `boardroom` (B4). Replaces ad-hoc improvised pushes with a fixed menu so
  the model's pushback choice is logged + audit-able instead of drifting
  every session. Selection rules table (which pattern matches which symptom),
  output protocol (menu print → user picks → model uses literal prompt),
  anti-patterns, and relationship to the escape hatch documented inline.
- `skills/grill/SKILL.md` Protocol section: replaced the ad-hoc 3-prompt
  example with the lib/push-once.md 5-pattern menu. Frontmatter `reads:`
  added `lib/push-once.md`.

- `skills/gatekeeper/SKILL.md` Step 0 STRIDE Classification (B1):
  6-category threat taxonomy (Spoofing / Tampering / Repudiation /
  Information Disclosure / DoS / Elevation of Privilege) classifier
  protocol with `none / suspect / confirmed` per category, frontmatter
  output `stride_categories: [...]`, risk floor rules (≥1 confirmed
  = 🔴 HIGH minimum, ≥2 suspect = 🟡 MEDIUM minimum), worked example
  for npm install case.
- `skills/gatekeeper/templates/report-skill.md`: new STRIDE
  CLASSIFICATION block between FILES SCANNED and RED FLAGS, exposes
  6-row classifier output + computed risk floor in the standardized
  ASCII report. Other 4 report templates (repository / url-document /
  onchain / product-service / message-share) to be backfilled in
  follow-up batch.

- `skills/harness-survey/`: new skill, two-strike promoted via `/done`
  Step 3b on 2026-05-04. Pattern: search public ecosystem
  (`gh search repos`) → fetch top-N READMEs → triage with vault
  dedup + layer-aware mapping → deep-read top picks → distill to
  substrate diff → execute approved batches. 6 phases, 5-7 patches
  cap per run, parks remainder as `[NEXT_BATCH]` in session note
  for retro-week pickup. Built-in discipline: feedback-log
  2026-05-01 layer mapping rule (mandatory before triage),
  AGENTS.md "No phantom quotes" rule (grep -F verify on every
  Before:/Source: quote), 5-7 patches cap, no auto-push to
  external systems. Prior strikes:
  `2026-04-18-harness-architecture-instinct-loop` +
  `2026-05-03-gstack-distillation-substrate-patches`.

### Removed

- `skills/brief/`: deleted. `grill --mode structured` had already
  replaced it (see grill SKILL.md line 5 — "replaces the deprecated
  /brief"); the directory was a zombie. References in
  `commands/sprint.md`, `commands/design.md`, and grill SKILL.md
  body updated to point at `/grill --mode structured`.

### Changed

- `skills/grill/SKILL.md` default (adversarial) mode Protocol:
  added "Expect rehearsed first answers" rule. First reply on any
  axis is the polished version; push once minimum before switching
  axes. Concrete push prompts: 具體一點？/ 你看過嗎？/ 拿掉這個假設會怎樣？
- `skills/grill/SKILL.md` Stopping rule replaced with Escape hatch
  protocol (hard cap): first push-back acknowledge + ask 2 most
  critical remaining axes; second push-back stop immediately, log
  unprocessed axes as OPEN_QUESTIONS, do not ask third time.
- `skills/grill/SKILL.md` Step 4 Alternatives hardened to
  MANDATORY: minimum 2 approaches (minimal viable + ideal
  architecture, equal weight, no minimal-viable-by-default bias),
  optional creative/lateral third, per-approach AskUserQuestion
  gate (not batched), explicit STOP rule preventing chat-prose
  recommendation + silent continuation.
- `skills/review/SKILL.md` gains **Step 0 System Audit** as fixed
  opener: 5 commands (git log -30, git diff --stat, git stash list,
  TODO/FIXME grep, recently touched files) + read CLAUDE.md /
  AGENTS.md / TODOS.md, report findings in 5 bullets max.
- `skills/review/SKILL.md` Step 6.5 Codex Adversarial Review:
  Outside Voice Integration Rule added — codex findings are
  **informational only**, no auto-boost on cross-model consensus,
  per-finding `Apply to final report? [Y/N/edit]` gate, N
  responses route to OPEN_QUESTIONS rather than discarded.
- `skills/review/SKILL.md` gains **Step 8 Completion Summary**:
  single ASCII box covering Step 0 audit, brief alignment, pass
  findings by priority, cold review hits, codex catches + apply
  count, learnings written, OPEN_QUESTIONS, CRITICAL_GAPS, files
  reviewed. Printed even on user-aborted runs (unrun steps marked
  `skipped (user)`).

### Added

- `lib/goal-mapping.md` — shared module documenting goal-hierarchy
  pre-step. Reads user's L1 (long horizon) / L2 (this season) /
  L3 (this week) goals from `<memory-dir>/`, maps the current task to
  each layer, picks the dominant layer, and feeds downstream Clarify +
  Alternatives steps so questions adapt to the user's actual goal
  hierarchy instead of running generic forcing questions in a goal
  vacuum.

### Changed

- `README.md`: install surface rewritten around host model instead of Claude-only plugin framing. Added runtime support matrix, Claude local-marketplace author loop, Hermes and OpenClaw status/installation guidance, user update paths, maintainer release loop, and explicit PR / issue contribution instructions.
- `plugins/pandastack/.claude-plugin/plugin.json` and `plugins/pandastack/.codex-plugin/plugin.json`: version markers bumped from `1.0.0-rc.2` to `1.0.0` to match the stable cut.

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

## v1.0.0 — 2026-05-03

Stable cut. Dogfood window 2026-04-29 → 2026-05-03 complete. API and schema frozen from this version forward.

### Added

- 39 skills across dev, knowledge, writing, work, research, retro, and decision lifecycles
- 8 context recipes (4 public + 4 work contexts via private overlay)
- 5 personas: eng, design, ceo, ops, product
- 7 lifecycle flows: dev, knowledge, writing, work, research, retro, decision
- JSONL session timeline (Track B): one event per action to `~/.pdctx/audit/timeline-YYYY-MM-DD.jsonl`; opt-out via `PDCTX_TIMELINE_DISABLED=1`
- Skill context metadata schema (Track C): optional `reads / writes / forbids / domain / classification` frontmatter fields
- Layer 5 firewall (Track D): per-skill tool-argument allowlist enforced at PreToolUse; opt-out via `PDCTX_L5_DISABLED=1`
- 3 Hermes cron jobs: morning-briefing (daily 8 AM), evening-distill (daily 10 PM), weekly-retro-prep (Fri 9 AM)
- 3 new skills: `morning-briefing`, `evening-distill`, `weekly-retro-prep`
- pdctx CLI 1.0.0: `--cwd`, `--sandbox`, `--allow-network`, `--writable-roots` flags
- Public README with Three-Tier architecture diagram, install instructions, and telemetry/firewall documentation

### Schema

- Skill frontmatter adds optional `reads`, `writes`, `forbids`, `domain`, `classification` fields. Backward compatible: skills without these are treated as `domain: shared, classification: read`. `pdctx skill-validate` warns on missing metadata instead of failing.

### Removed

- `qmd` retired 2026-05-02; `gbq` (gbrain hybrid search) replaces it

### Known Issues

- L5 false-positive on stale `active-skill.json` (P2 — Stop hook needed to clear on session end)
- `vault:` prefix assumes single vault root; multi-vault setups need explicit `file:` entries (P2)

---

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
