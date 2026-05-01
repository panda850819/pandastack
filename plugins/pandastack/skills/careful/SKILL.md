---
name: careful
description: |
  Use when working on production code, shared infrastructure, or
  unfamiliar codebases. Adds confirmation gates before destructive
  commands (force push, rm -rf, publish, DROP).
---

# Careful Mode

Adds a confirmation gate before destructive or high-risk actions.

## On Invoke

Announce: "CAREFUL mode ON. Will confirm before destructive actions."

## While Active

Before executing any of the following, pause and ask the user for explicit confirmation:

### Git
- `git push --force`, `git reset --hard`, `git clean -f`
- `git branch -D` (force delete)
- `git checkout .` or `git restore .` (discard all changes)
- `git rebase` on shared branches
- Any push to main/master

### Filesystem
- `rm -rf` on any directory
- Deleting more than 3 files at once
- Overwriting files outside the current project

### External
- Any API call that mutates external state (POST/PUT/DELETE to production)
- Publishing packages (`npm publish`, `cargo publish`)
- Deploying to production environments

### Database
- DROP, TRUNCATE, DELETE without WHERE
- Schema migrations on production

## Confirmation Format

```
CAREFUL: About to {action}.
  Target: {what}
  Reversible: yes/no
  Proceed? [y/n]
```

## Deactivate

User says "careful off" or starts a new session. Announce: "CAREFUL mode OFF."
