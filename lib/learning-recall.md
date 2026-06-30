# lib/learning-recall.md — surface captured learnings at the start of a dev unit

> Shared module. The compounding half that actually pays. Capture is automatic and prolific (a session-end distill files learnings continuously), but measured 2026-06-30 only ~4% of sessions ever cite a prior learning and 54% of learnings are orphans. This makes a dev unit OPEN by pulling the handful of past learnings relevant to the task, so captured insight changes current behavior instead of sedimenting.

## When to load

At the START of a dev unit, right after `capability-probe`, BEFORE planning or executing:

- `sprint` Stage 0 · `review` Step 2 (its "Load Learnings" step) · `debug` opener.

Skip for atomic skills with no plan (`init`, `freeze`, `careful`, `checkpoint`).

## The recall (store-agnostic)

Given the task topic (one line you derive from the request), pull the top **3-5** relevant learnings from whatever learning store the user has. Resolve the store the same way capture does — do NOT hardcode a brain path:

- **gbrain present** (`command -v gbrain`): `gbrain query "<task topic>"`, keep only hits whose path is under `learnings/`, take the top 3-5.
- **Obsidian / plain files**: rank `docs/learnings/**/*.md` (and a vault `learnings/` if present) by topic-token overlap against each file's title + tags; take the top 3-5. A 5-line `grep -rIl` + token-score is enough — no index required.
- **no store**: print `(no learning store found — recall skipped)` and proceed. Not an error.

## Inject + USE (the load-bearing part)

Print one compact RECALL block, then actually use it:

```
== recall (N learnings for: <topic>) ==
- <key> (conf N, <age>): <one-line lesson>  [<path>]
- ...
```

For each surfaced learning, if it bears on the current plan, state in one line **how it changes the approach**. A recall that just lists titles and moves on is the failure mode this exists to kill (that is what review Step 2 did = nothing). Apply confidence decay: `effective = max(0, confidence − floor(days_since_created / 30))`; `user-stated` never decays; skip learnings with effective confidence < 3.

If nothing relevant surfaces, print `(no relevant prior learning)` and proceed — a clean miss is a valid outcome, not a skipped step.

## Why recall, not a recurrence ratchet

Measured 2026-06-30 on the live corpus: clustering 300 learnings by token+ratio overlap yields ~5 dubious near-duplicates at the tightest threshold, and even those are "same topic, different facet", not "same lesson twice". The learnings are distinct insights, not repeated slop, so a "promote on 2nd occurrence" ratchet barely fires. The leverage is resurfacing the distinct insight when it is relevant. Recall is the compound primitive here; recurrence-detection is not.

## Anti-patterns

- ❌ Listing recalled learnings without using them — recall MUST change the plan or be explicitly dismissed. Listing-and-ignoring is why the prior Step 2 was dead.
- ❌ Querying the whole knowledge dump — scope to `learnings/`, top 3-5, confidence-decayed.
- ❌ Treating "no relevant learning" as an error or a reason to skip the step — a clean miss is a result.
- ❌ Hardcoding `~/site/knowledge/brain/learnings` — resolve the store; gbrain is one backend, files are another.
