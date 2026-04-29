---
name: ps-compound
description: |
  Extract learnings from a recently solved problem. Use after
  debugging a tricky issue, discovering a non-obvious pattern,
  or when the user says "remember this", "document this",
  "compound", or "that was interesting".
---

# Compound

Capture what you just learned so future sessions benefit.

## Step 1: Assess

Not every session is worth compounding. Skip if:
- Simple typo or obvious fix
- Config change with no insight
- Routine work with nothing surprising

Proceed if:
- Debug took > 10 minutes
- Solution was non-obvious
- You discovered a pattern that applies beyond this one case
- The user explicitly asked to compound

If skipping: "Nothing worth compounding this session." and stop.

## Step 2: Extract

Review the conversation history. Identify:

1. **What was the problem?** (symptoms, not just the error message)
2. **What didn't work?** (failed approaches — this is the most valuable part)
3. **What was the root cause?**
4. **What was the fix?**
5. **How to prevent it next time?**

## Step 3: Check for Duplicates

Read pstack config from CLAUDE.md for the learnings directory.

Search `{learnings_dir}` for existing learnings with similar keywords:

```bash
grep -rl "keyword1\|keyword2" {learnings_dir}/ 2>/dev/null
```

If a high-overlap match exists:
- Update the existing file: add new context, bump `last_seen`, adjust confidence
- Don't create a duplicate

## Step 4: Write

Determine the category from the problem type:
- Code pattern → `patterns/`
- "Don't do this" → `pitfalls/`
- Structural decision → `architecture/`

Write to `{learnings_dir}/{category}/{slug}.md` using the format in `lib/learning-format.md`.

## Step 5: Confirm

Tell the user:
- What was captured (key + one-line insight)
- Where it was saved (file path)
- How it will be used ("This will surface automatically in future /ps-review runs")
