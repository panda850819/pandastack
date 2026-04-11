---
name: ps-review
description: |
  Use when asked to "review", "check my code", or before creating a PR.
  Parallel 3-pass review (correctness, security, architecture) with
  learning integration — searches past learnings before, writes after.
---

# Code Review

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

## Step 3: Scope Drift Check

If a brief exists for this branch (check `docs/briefs/` for a matching slug or date):

1. Read the brief's **Scope > In** and **Scope > Out** sections.
2. Compare against the diff. Flag any changed files or features that fall outside the stated scope.
3. Output:
   - "Scope: ON TRACK" if all changes match the brief.
   - "SCOPE DRIFT: [description]" for each out-of-scope change. Ask user to confirm or revert.

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
**ASK**: judgment calls (architecture, design trade-offs). Batch all ASK items into one AskUserQuestion.

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

## Step 7: Write Learnings

After review completes (including cold review), evaluate whether any non-obvious pattern was discovered.

Test: "Would this save time in a future session on this codebase?"

If yes, check `{learnings_dir}` for existing learnings with similar key.
- If match exists: update `last_seen` and add new context.
- If no match: write new file to `{learnings_dir}/{category}/{slug}.md`

Use the format from `lib/learning-format.md`.

If nothing worth recording: skip silently. Not every review produces learnings.
