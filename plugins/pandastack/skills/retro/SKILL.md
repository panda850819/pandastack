---
name: ps-retro
description: |
  Weekly retrospective. Reviews git activity, learnings health,
  and patterns. Use when asked for "retro", "weekly review",
  or "how did this week go?"
---

# Retro

## Step 1: Activity

```bash
git log --since="1 week ago" --oneline --no-merges
git shortlog --since="1 week ago" -sn
```

Summarize: commits, files touched, key deliverables.

## Step 2: Learnings Health

Read pstack config from CLAUDE.md for the learnings directory.

Count learnings in `{learnings_dir}`:
- New this week (by `created` date in frontmatter)
- Total active (effective confidence >= 3)
- Stale (effective confidence < 3)
- Referencing deleted files

## Step 3: Patterns

From this week's git history + learnings:
- What types of work dominated? (features, bugs, refactors)
- Any recurring patterns? (same file keeps breaking, same type of bug)
- Any learning that got matched multiple times during reviews?

## Step 4: Output

```markdown
## Week of YYYY-MM-DD

### Shipping
- N commits, +N/-N lines
- Key deliverables: ...

### Learnings
- N new, N total active, N stale
- Most referenced: [key] (matched N times)

### Patterns
- [observations]

### Recommendation
- [one actionable suggestion for next week]
```

## Step 5: Prune

Run the prune logic from `/ps-learn` on any stale learnings found in Step 2.
Present each stale learning to the user for decision.
