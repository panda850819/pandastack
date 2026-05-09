---
name: careful
description: |
  Use when working on production code, shared infrastructure, or
  unfamiliar codebases. Adds confirmation gates before destructive
  commands (force push, rm -rf, publish, DROP).
reads: []
writes:
  - cli: stdout
forbids:
  - cli: git push --force
  - cli: git reset --hard
  - cli: git clean -f
  - cli: rm -rf
  - cli: npm publish
  - cli: cargo publish
domain: shared
classification: exec
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

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "It's not really production" | If it has prod data, prod users, or shared infra (DNS, OAuth, public packages), it's prod. The blast radius defines the gate, not the label. |
| "I've done this rebase a hundred times" | Muscle memory is precisely how branches get nuked. The confirm gate is 3 seconds; recovering a force-pushed branch is 30 minutes when it's recoverable at all. |
| "Force push is fine, it's my branch" | Anyone who pulled has a divergent local copy. They will silently rebase onto the wrong head and ship phantom commits. Force push to a shared remote is never local. |
| "The migration is read-only / SELECT only" | A long SELECT on a hot table acquires locks. Read-only on a replica is OK; read-only against prod primary at peak is not. |
| "I'll just `rm -rf node_modules` real quick" | Typo'd `rm -rf node_modules /` once. Confirm even when the path looks obvious — the typo lives in the half-second between intent and enter. |
| "Careful is for when I'm tired, not now" | The decision to skip the gate is itself a tiredness signal. The gate is cheap; the override is what should be expensive. |
