---
name: ps-checkpoint
description: |
  Save or resume working state snapshots. Captures git state,
  decisions made, remaining work. Use when pausing work, switching
  context, or before a long session break.
---

# Checkpoint

## Detect Command

Parse the user's input:

- `/ps-checkpoint` (no arguments) → **Save**
- `/ps-checkpoint resume` → **Resume**
- `/ps-checkpoint list` → **List**

Read pstack config from CLAUDE.md.

## Save (default)

1. Gather current state:
   ```bash
   git branch --show-current
   git log origin/{main}..HEAD --oneline
   git status --short
   git diff --stat
   ```

2. Write a checkpoint file to `docs/checkpoints/{branch-slug}-{YYYY-MM-DD}.md`:

   ```markdown
   ---
   branch: {branch name}
   created: {YYYY-MM-DD HH:MM}
   status: paused | blocked | ready-to-ship
   ---

   ## State
   - Branch: `{branch}`
   - Commits ahead of {main}: {N}
   - Uncommitted changes: {yes/no, summary}

   ## Decisions Made
   {List key decisions from this session — architecture choices,
   trade-offs accepted, user confirmations. Extract from conversation
   context, not invented.}

   ## Remaining Work
   {What's left to do on this branch. Be specific: file names,
   function names, test cases.}

   ## Blockers
   {Any blockers encountered. "None" if clear.}

   ## Resume Hint
   {One sentence: what to do first when resuming.}
   ```

3. Output: "Checkpoint saved. Resume with `/ps-checkpoint resume`."

## Resume

1. Find the most recent checkpoint for the current branch:
   ```bash
   git branch --show-current
   ```
   Then look for matching files in `docs/checkpoints/`.

2. If no checkpoint exists for this branch, check all checkpoints and list them.

3. Read the checkpoint file and output:
   ```
   RESUMING: {branch}
   Last checkpoint: {date}
   Status: {status}
   Decisions: {summary}
   Remaining: {summary}
   Resume hint: {hint}
   ```

4. Delete the checkpoint file after successful resume (it served its purpose).

## List

List all checkpoint files in `docs/checkpoints/`, sorted by date:

```
CHECKPOINTS:
  {branch} — {date} — {status}
  {branch} — {date} — {status}
```

If no checkpoints exist: "No checkpoints. Save one with `/ps-checkpoint`."
