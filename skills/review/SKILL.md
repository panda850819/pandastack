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

## Step 4: Parallel Review

Launch 3 review passes in parallel using `context: fork` (isolated subagents — results flow back, intermediate work stays out of main context). Each reviews the same diff with a different lens:

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

Each pass outputs findings in the same format:
```
[P0-P3] (confidence: N/10) file:line — description
  Fix: what to do
  Action: AUTO-FIX | ASK
```

Merge all findings, deduplicate, sort by priority.

**AUTO-FIX**: mechanical fixes (typos, missing null checks, obvious bugs). Apply directly.
**ASK**: judgment calls (architecture, design trade-offs). Batch all ASK items into one AskUserQuestion.

If no issues found across all passes: "Review clean. No issues found."

## Step 5: Write Learnings

After review completes, evaluate whether any non-obvious pattern was discovered.

Test: "Would this save time in a future session on this codebase?"

If yes, check `{learnings_dir}` for existing learnings with similar key.
- If match exists: update `last_seen` and add new context.
- If no match: write new file to `{learnings_dir}/{category}/{slug}.md`

Use the format from `lib/learning-format.md`.

If nothing worth recording: skip silently. Not every review produces learnings.
