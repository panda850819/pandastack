---
name: review
description: |
  Use when asked to "review", "check my code", or before creating a PR.
  Parallel 3-pass review (correctness, security, architecture) with
  cold review, Codex adversarial cross-check, and learning integration.
reads:
  - repo: "**"
  - repo: CLAUDE.md
  - repo: docs/briefs/**
  - repo: docs/learnings/**
  - cli: git
  - cli: grep
writes:
  - repo: "**"
  - cli: stdout
forbids:
  - cli: git push
  - cli: gh pr create
domain: shared
classification: hybrid
---

# Code Review

## Step 0: System Audit (fixed opener)

Before scoping the diff, audit branch state. Run these 5 commands. **Do not skip.**

```bash
git log --oneline -30
git diff origin/main --stat 2>/dev/null || git diff main --stat 2>/dev/null
git stash list
grep -rln "TODO\|FIXME\|HACK\|XXX" --include="*.md" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.go" --include="*.rb" . 2>/dev/null | head -20
git log --since=30.days --name-only --format= 2>/dev/null | sort | uniq -c | sort -rn | head -10
```

Then read (if present): `CLAUDE.md`, `AGENTS.md`, `TODOS.md`.

Report findings in 5 bullets max:
- Branch state: ahead/behind/diverged
- Stashed work: count and topics (if any)
- TODO/FIXME hotspots in changed files
- Files touched most in past 30 days (architectural drift signal)
- Convention sources read (which CLAUDE.md / AGENTS.md / TODOS.md)

If output for any command is > 30 lines, summarize. Don't dump raw output into the review.

## Step 1: Scope

1. Read pstack config from CLAUDE.md.
2. Run `git branch --show-current`. If on the main branch, stop: "Nothing to review — you're on main."
3. Run `git diff origin/{main} --stat`. If no diff, stop.
4. Get the full diff: `git diff origin/{main}`

## Step 2: Load Learnings

Search `{learnings_dir}` for learnings related to the changed files:

```bash
# Search by file paths mentioned in the diff
grep -rl "relevant-file-path" {learnings_dir}/ 2>/dev/null

# Search by keywords from the diff (function names, patterns)
grep -rl "keyword" {learnings_dir}/ 2>/dev/null
```

Read matching files. For each match, note:
"Prior learning: [key] (confidence N/10, from [date])"

Apply confidence decay per `lib/confidence.md` rules. Skip learnings with effective confidence < 3.

## Step 3: Brief Alignment Check

If a brief exists for this branch (check `docs/briefs/` for a matching slug or date):

1. Read the brief's **Problem**, **Success Metric**, **Scope > In**, and **Scope > Out** sections.
2. **Drift check** — compare against the diff. Flag any changed files or features that fall outside the stated scope.
3. **Coverage check** — for each In-scope item and the Success Metric, verify the diff addresses it. Flag any in-scope item with no visible implementation.
4. Output:
   - "Brief: ON TRACK" if drift and coverage both clean.
   - "SCOPE DRIFT: [description]" for each out-of-scope change. Ask user to confirm or revert.
   - "COVERAGE GAP: [in-scope item with no matching change]" for each missing piece. Ask user to confirm intentional or flag as incomplete.

If no brief exists, skip this step silently.

## Step 4: Detect Diff Scope

Scan the diff file list to detect which conditional passes to activate:

```
SCOPE_MIGRATION  — files matching **/migrations/**, **/migrate*, **/*.sql with CREATE/ALTER/DROP
SCOPE_API        — files matching **/routes/**, **/controllers/**, **/api/**, **/handlers/**
SCOPE_AUTH       — files matching **/auth/**, **/middleware/**, or diff containing token/session/password/permission
SCOPE_INFRA      — files matching **/docker*, **/.github/**, **/terraform/**, **/k8s/**
```

Log detected scopes: "Scope signals: {list}" (or "none" if only base code changes).

## Step 5: Parallel Review

Launch review passes in parallel using `context: fork` (isolated subagents — results flow back, intermediate work stays out of main context). Each reviews the same diff with a different lens.

**Model routing** — pass `model: <name>` when spawning each Agent. Don't pay Opus tokens for mechanical checks; don't starve architecture with Haiku.

| Pass | Model | Why |
|---|---|---|
| Correctness, Security, Migration, API, Auth, Infra | sonnet | Pattern-match against known bug shapes |
| Architecture | opus | Deep reasoning about coupling and long-term trade-offs |

**Always-on passes (run every time):**

**Pass 1 — Correctness** (eng agent lens):
- Bugs that pass CI but break production
- Race conditions, N+1 queries, stale reads
- Missing error handling at system boundaries
- Test gaps for changed code paths

**Pass 2 — Security**:
- Injection (SQL, command, XSS)
- Auth/authz bypass
- Secrets in code or logs
- Unsafe deserialization, SSRF

**Pass 3 — Architecture**:
- Coupling that will hurt later
- Abstractions that don't earn their complexity
- API surface changes that break consumers
- Missing migrations or backwards-incompatible changes

**Conditional passes (only when scope detected):**

**Pass 4 — Migration Safety** (only if SCOPE_MIGRATION):
- Backwards-incompatible schema changes without migration path
- Missing rollback strategy (no down migration)
- Data loss risk (column drops, type changes on populated tables)
- Lock duration on large tables (ALTER on millions of rows)

**Pass 5 — API Contract** (only if SCOPE_API):
- Breaking changes to existing endpoints (removed fields, changed types)
- Missing versioning for breaking changes
- Inconsistent error response format
- Missing or wrong HTTP status codes

**Pass 6 — Auth/Permissions** (only if SCOPE_AUTH):
- Privilege escalation paths (user can access admin resources)
- Missing auth checks on new endpoints
- Token/session handling flaws (no expiry, no rotation)
- Secrets logged or exposed in error messages

**Pass 7 — Infra/CI** (only if SCOPE_INFRA):
- Secrets hardcoded in config files
- Missing environment variable validation
- Docker image using latest tag instead of pinned version
- CI steps that can silently fail

Each pass outputs findings in the same format:
```
[P0-P3] (confidence: N/10) file:line — description
  Fix: what to do
  Action: AUTO-FIX | ASK
```

Merge all findings, deduplicate, sort by priority. If multiple passes flag the same file:line, boost confidence and mark "MULTI-PASS CONFIRMED".

**AUTO-FIX**: mechanical fixes (typos, missing null checks, obvious bugs). Apply directly.
**ASK**: judgment calls (architecture, design trade-offs). Batch all ASK items into one AskUserQuestion using the four-option gate contract (approve / edit / reject / skip). See `lib/gate-contract.md`.

If no issues found across all passes: "Review clean. No issues found."

## Step 6: Cold Review (Uncorrelated Context)

Spawn a fresh agent with `isolation: "worktree"` to review the same diff
with zero knowledge of why the code was written. This catches issues that
the in-session reviewer misses due to confirmation bias.

The cold reviewer receives ONLY:
- The raw diff (`git diff origin/{main}`)
- The project's CLAUDE.md (for conventions, not intent)
- This instruction: "Review this diff for bugs, security issues, and
  design problems. You have no context about why these changes were made.
  Report only findings with confidence >= 7/10. Format: [P0-P3] file:line — description."

DO NOT pass: the brief, the conversation history, the task description,
or any explanation of what the code is supposed to do.

Merge cold review findings with Step 5 findings:
- If cold reviewer flags something Step 5 missed → boost to P1 minimum,
  tag as "COLD-CATCH"
- If cold reviewer flags something Step 5 also caught → tag as
  "CROSS-CONFIRMED" (highest confidence)
- If cold reviewer flags something that Step 5 explicitly cleared →
  present both opinions to user, don't auto-resolve

## Step 6.5: Codex Adversarial Review (Cross-Model)

Run Codex as an independent adversarial reviewer. This adds a second model's
perspective (GPT) to Claude's review, catching blind spots from model-specific
reasoning patterns.

**Launch in parallel with Step 6** (both run in background):

```bash
node "${CLAUDE_PLUGIN_ROOT}/scripts/codex-companion.mjs" adversarial-review --wait
```

If the Codex plugin is not available (command fails), skip this step silently
and note "Codex: unavailable" in the final report.

**Outside Voice Integration Rule:** Codex findings are **informational only**. Each must be explicitly approved by the user before it lands in the final report or any follow-up commit. Cross-model consensus is a strong signal — surface it as such — but **do not auto-elevate** priority or confidence based on consensus alone.

**Merge Codex findings with Steps 5-6 findings:**
- Codex finding matches a Claude finding → tag as "CROSS-MODEL CONFIRMED". Display original Claude confidence + Codex confirmation. **Do not auto-boost** to maximum.
- Codex finding is novel (not caught by Claude) → tag as "CODEX-CATCH, suggested P{N}". The suggested priority is informational. **User approval required** before it enters the final report at that priority.
- Codex finding contradicts a Claude "clean" assessment → present both opinions to user, don't auto-resolve.

**Output format for Codex findings:**
```
[suggested P0-P3] (CODEX-CATCH, confidence: N%) file:line — description
  Fix: recommendation
  Apply to final report? [Y / N / edit]
```

`N` responses go to the Completion Summary's `OPEN_QUESTIONS` count, not discarded silently.

## Step 7: Write Learnings

After review completes (including cold review), evaluate whether any non-obvious pattern was discovered.

Test: "Would this save time in a future session on this codebase?"

If yes, check `{learnings_dir}` for existing learnings with similar key.
- If match exists: update `last_seen` and add new context.
- If no match: write new file to `{learnings_dir}/{category}/{slug}.md`

Use the format from `lib/learning-format.md`.

If nothing worth recording: skip silently. Not every review produces learnings.

## Step 8: Completion Summary

Before exiting, print a single ASCII box so the user can see scope at a glance.

```
+============================================================+
|              REVIEW — COMPLETION SUMMARY                   |
+============================================================+
| Branch       | {branch}                                    |
| Commit       | {short hash}                                |
| Step 0 audit | ran / skipped — {N} stashed, {N} TODOs hit  |
| Step 3 brief | ON TRACK / DRIFT:{N} / GAP:{N} / no brief   |
| Step 5 passes| P0:_ P1:_ P2:_ P3:_  ({N} AUTO-FIX applied) |
| Step 6 cold  | ran / skipped — {N} COLD-CATCH              |
| Step 6.5 cdx | ran / unavailable — {N} CODEX-CATCH         |
| Codex apply  | {N} approved, {N} deferred to OPEN_QUESTIONS|
| Step 7 learn | {N} learnings written / skipped             |
+------------------------------------------------------------+
| OPEN_QUESTIONS  | {N}                                       |
| CRITICAL_GAPS   | {N}  (any P0 not approved counts)        |
| Files reviewed  | {N}                                      |
+============================================================+
```

If the user aborts mid-review, still print the box. Mark unrun steps as `skipped (user)`. Solves the "did I actually finish review?" ambiguity.
