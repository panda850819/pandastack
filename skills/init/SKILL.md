---
name: ps-init
description: |
  Use once per project to initialize pstack. Detects project type,
  asks ship preferences, writes pstack config to CLAUDE.md.
---

# Init

## Step 1: Detect

Auto-detect from the repo:
- Language/framework (package.json, Cargo.toml, pyproject.toml, go.mod, Gemfile)
- Test command (scripts.test, Makefile, etc.)
- Main branch (main or master)
- Existing CI (.github/workflows, .gitlab-ci.yml)

## Step 2: Confirm

Present detected values via AskUserQuestion. One question, all fields:

> pstack detected:
> - Test: `{detected or "not found"}`
> - Main branch: `{main or master}`
> - Tag format: none
> - GitHub Release: false
> - Deploy command: none
> - Learnings dir: `docs/learnings`
>
> Adjust anything, or approve to continue?

## Step 3: Write Config

Append to the project's CLAUDE.md (create if needed):

```markdown
## pstack

test: {test command}
main: {main branch}
tag: none
release: false
deploy: null
learnings: docs/learnings
```

## Step 4: Create Directories

```bash
mkdir -p docs/learnings/{patterns,pitfalls,architecture,preferences}
```

## Step 5: Confirm

Output: "pstack initialized. Run `/ps-review` after your next change to start building learnings."
