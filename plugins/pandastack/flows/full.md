# Full Sprint Flow

Complete feature development with all checkpoints.

## When to Use

- New features that take more than a day
- Changes that affect multiple systems
- Work that involves UI/UX decisions
- Anything where getting it wrong is expensive

## Flow

```
/ps-brief
    ↓
@ceo scope review (optional — for large scope)
    ↓
@design direction (optional — for UI work)
    ↓ taste gate: user approves design
    ↓
build (eng agent)
    ↓
/ps-review
    ↓
/ps-qa (if UI changed)
    ↓
/ps-ship
    ↓
/ps-compound (if non-trivial pattern found)
```

## Taste Gates

The flow pauses at two points for user judgment:
1. **After design direction** — user picks which design approach
2. **After review findings** — user decides on ASK items

These are not optional. Skipping taste gates defeats the purpose.

## Agent Involvement

| Agent | When | What They Do |
|-------|------|-------------|
| product | /ps-brief | Clarify problem, define metric |
| ceo | After brief | Scope review: GO / ITERATE / KILL |
| design | After brief | Design direction + visual spec |
| eng | Build + review | Implementation + code review |
