Debug and fix this issue: $ARGUMENTS

## Step 1: Scope Freeze

Before touching code, lock down the problem:

1. Reproduce the bug — get the exact error, stack trace, or unexpected behavior.
2. Define the boundary: which files, functions, or layers could be involved?
3. State what is NOT broken — narrow the blast radius.

If you cannot reproduce, stop and ask the user for more context.

## Step 2: Load Learnings

Search `{learnings_dir}` for related past issues:

```bash
grep -rl "keyword" {learnings_dir}/ 2>/dev/null
```

Note any relevant pitfalls or patterns before investigating.

## Step 3: Hypothesis-Driven Investigation

Use the eng agent (read agents/eng.md). Do NOT shotgun-debug.

1. List 2-3 hypotheses ranked by likelihood.
2. For each hypothesis, state what evidence would confirm or rule it out.
3. Test one at a time — read code, add logging, check state.
4. After each test, update: confirmed / ruled out / inconclusive.

**3-Strike Rule**: If 3 hypotheses fail, STOP. Summarize what you've learned and escalate to the user. Do not spiral.

**Iron Law**: No fix without root cause. Tracing the data flow comes before any code change.

## Step 4: Fix

1. Implement the fix (minimal diff — touch only what the bug requires).
2. Verify the fix resolves the original reproduction case.
3. Check for regressions in related code paths.

## Step 5: Review + Ship

1. Run /review
2. Run /ship

## Step 6: Extract learning

If the debug took > 10 minutes or the solution was non-obvious, run /pandastack:knowledge-ship (or /pandastack:work-ship if work-context) — Stage 2 Extract surfaces what was learned and Stage 3 Backflow writes it to docs/learnings/.
