# Stop Check

Run automatically when a session ends or when the user says "done", "wrap up", or "that's it".

## Checks

1. **Uncommitted changes**
   - Run `git status --short`. If modified files exist, warn:
     "You have uncommitted changes. Run /ps-ship or commit manually."

2. **Unreviewed diff**
   - Run `git log origin/{main}..HEAD --oneline`. If commits exist and /ps-review was not run this session:
     "Commits on branch but no review was run this session."

3. **New TODOs**
   - Run `git diff origin/{main}` and search for added lines containing `TODO` or `FIXME`.
   - If found, list them: "New TODOs added this session: [list]"

4. **Test status**
   - If tests were run this session and any failed, remind:
     "Tests failed earlier in this session. Verify before shipping."

## Output

If all checks pass: nothing (silent).
If any check triggers: output a short summary block:

```
SESSION CHECK:
- [x] or [ ] Uncommitted changes
- [x] or [ ] Unreviewed commits
- [x] or [ ] New TODOs
- [x] or [ ] Failing tests
```

This is advisory only — the user decides whether to act.
