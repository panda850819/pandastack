Evaluate a new project idea: $ARGUMENTS

Follow this sequence, pausing at decision gates for user approval:

1. **Diverge** — Help the user explore the idea space:
   - What variations of this idea exist?
   - What adjacent problems could this solve?
   - What would the 10x version look like? The 0.1x version?
   - Capture all ideas without filtering. Bias toward breadth.

2. **Filter** — Narrow to 1-3 candidates worth investigating:
   - Which ideas have the clearest problem-user fit?
   - Which are most feasible given current constraints?
   - Present candidates. User picks which to evaluate.

3. **Define the problem** — For each selected candidate:
   - Who specifically has this problem?
   - How do they solve it today?
   - What happens if we do nothing?

4. **Prior art** — Search for existing solutions:
   - `qmd search` and `qmd vsearch` the vault for related knowledge
   - Web search for competing tools, prior art, blog posts
   - If results are insufficient and the idea warrants deeper investigation, suggest `/deep-research` and pause. User can run it and return to this flow.

5. **Cost estimate** — Rough sizing:
   - Effort to build (days/weeks, not hours)
   - Ongoing maintenance burden
   - Opportunity cost (what doesn't get done)

6. **Go / No-go** — Present a one-page decision summary. User decides.
   - **Go**: Write output to `docs/briefs/` with `type: brainstorm, status: go`. Suggest running `/sprint` to begin.
   - **No-go**: Write output to `docs/briefs/` with `type: brainstorm, status: rejected` and rejection reason.

## Output format

Write to `docs/briefs/YYYY-MM-DD-{slug}.md`:

```markdown
---
type: brainstorm
status: go | rejected
date: YYYY-MM-DD
---

## Idea
{one-sentence description}

## Problem
{who has this problem, how they solve it today}

## Prior Art
{what exists, why it does or doesn't solve the problem}

## Cost Estimate
Build: {days/weeks}
Maintain: {low/medium/high}
Opportunity cost: {what gets delayed}

## Decision
{go or no-go, with reasoning}
```
