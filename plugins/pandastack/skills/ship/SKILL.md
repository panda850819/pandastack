---
name: ship
description: |
  Test, commit, and create PR. One command from "code done" to
  "PR open". Use when asked to "ship", "create PR", or "we're done".
---

# Ship

## Step 0: Read Config

Read pstack config from CLAUDE.md for: test command, tag format, release preference.

## Step 1: Pre-flight

1. Run `git pull` to sync with remote (avoid conflicts from auto-backup).
2. Run the project's test/build command. If it fails, stop and report.
3. Run `git diff --stat` to see uncommitted changes.
4. Run `git log origin/{main}..HEAD --oneline` for commit history.
5. Check current branch: `git branch --show-current`.

## Step 2: Load Learnings

Search `{learnings_dir}` for `type: pitfall` related to the changed files.
If any match, do a quick sanity check against the diff before proceeding.

## Step 3: Scope Check

If a brief exists for this branch (check `docs/briefs/`):
1. Read the brief's **Scope > In/Out** sections.
2. Get the **current** full diff: `git diff origin/{main} --stat`.
3. Compare against the brief scope. Flag any files or features outside stated scope.
4. Also compare against the diff at review time (if `/review` was run earlier, the reviewed diff may be smaller than the current diff). Check for **post-review additions**: files changed after the last review that were never reviewed.
5. Output:
   - "Scope: ON TRACK" if all changes match the brief and nothing was added post-review.
   - "SCOPE DRIFT: [description]" for each out-of-scope change.
   - "POST-REVIEW CHANGES: [files]" for any files modified after the last review.
   Ask user to confirm before proceeding if either is detected.

If no brief exists, still check for post-review additions:
1. Run `git log --oneline --since="1 hour ago"` to see recent commits.
2. If there are commits after the last `/review` in this session, list the changed files and warn:
   "These files were changed after the last review: [list]. Proceed without re-review?"

If neither brief nor review history exists, skip silently.

## Step 4: Review Gate

If `/review` has NOT been run on the current diff in this session:
1. Warn: "Review not run. Run /review first?"
2. If user says skip, proceed. Otherwise run review.

This prevents shipping unreviewed code by default.

## Step 5: Commit

If there are uncommitted changes:
1. Analyze the diff
2. Generate a conventional commit message (`type(scope): description`)
3. Stage relevant files (never `git add -A`)
4. Commit (don't amend, don't skip hooks)

## Step 6: Branch (mandatory)

**Never push directly to main/master.** Always ship via PR.

1. If on main/master, create a feature branch:
   - `fix/*` for bug fixes
   - `feat/*` for features
   - `refactor/*` for refactoring
   - Branch name should be short and descriptive (e.g., `fix/mainnet-label`)
2. If already on a feature branch, stay on it.

## Step 7: Tag (if configured)

If pstack config has `tag: semver`:
1. Read current version from package.json, VERSION, or latest git tag
2. Determine bump type from commits (feat = minor, fix = patch)
3. Create tag: `git tag v{version}`

If `tag: none`: skip.

## Step 8: Push + PR

1. Push the branch with `-u` (and tags if created)
2. Create PR with `gh pr create`:
   - Title: short, under 70 chars
   - Body: what changed, why, how to test
   - If learnings were written this session, mention in PR body
3. Return the PR URL to the user.

## Step 9: Release (if configured)

If pstack config has `release: true`:
- Create GitHub Release from the tag
- Auto-generate release notes from commits

If `release: false`: skip.

## Step 10: Write Learnings (if applicable)

If the ship process itself revealed something useful:
- A test that caught a subtle bug
- A deploy pattern worth remembering
- A CI configuration gotcha

Write a learning to `{learnings_dir}/pitfalls/` or `{learnings_dir}/patterns/`.
