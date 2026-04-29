# Solo Flow

The minimum closed loop for individual development.

## When to Use

Daily development as a solo builder. Most tasks fall here.

## Flow

```
/ps-brief (optional) → build → /ps-review → /ps-ship
                                                 ↓
                                          /ps-compound (if worth it)
```

## Decision Guide

| Task Size | What to Run |
|-----------|-------------|
| Typo, config change | Just do it. No pstack needed. |
| Small feature (< 1hr) | `/ps-quick` — review + ship |
| Bug fix | `/ps-fix` — debug + review + ship + compound |
| New feature | `/ps-sprint` — brief + build + review + ship |
| UI feature | `/ps-design` — brief + design + build + review + qa + ship |

## When to Compound

Not every session. Only when:
- Debug took > 10 minutes
- Solution was non-obvious
- You discovered a pattern that applies to other parts of the codebase
- You want to remember something for next time
