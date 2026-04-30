---
name: persona-pipeline
description: Sequential multi-lens review for large feature / product / architecture decisions. Runs product-lead → design-lead → eng-lead → ceo as a pipeline where each persona sees the previous stage's output and adds its own lens. Triggers on "/persona-pipeline", "pipeline review", "multi-lens review", or large feature decisions needing cross-functional critique.
---

# Persona Pipeline

Run a decision through sequential personas so each lens builds on the last, instead of four independent consultations the user has to synthesize alone.

Based on Alex Ker's subagent pipeline pattern (2026-04-17): "pipelines enforce depth where fan-out explores breadth."

## When to Use

- Large feature decision (new product surface, new user flow, architectural shift)
- Strategic proposal before presenting to Bob
- "I have an idea, want a real critique before building"
- User explicitly says "run the pipeline", "multi-lens review", or `/persona-pipeline`

## When NOT to Use

- Simple code change → use single persona or no persona
- Pure research question → use a research subagent or handle directly
- Already know the answer, just want validation → don't ask the pipeline to rubber-stamp
- Parallel investigation (3 hypotheses about a bug) → use parallel fan-out, not pipeline

## Default pipeline

1. **product-lead** — user value, growth logic, PMF check, prioritization vs roadmap
2. **design-lead** — user experience, interaction model, accessibility, anti-slop
3. **eng-lead** — feasibility, complexity budget, delivery risk, data model
4. **ceo** — devil's advocate: what's the strongest argument against, what's Bob going to ask, is this actually strategic or busywork

Override the order (or drop stages) if the user names a different lineup. The ceo devil's advocate seat is valuable last — give it the full stack to attack.

## How to run

For each stage:

1. Use `Agent` tool with `subagent_type` = the persona name.
2. Pass the original proposal + every previous stage's response. Each persona must see the full chain, not just the prompt.
3. Ask the persona to do **two things**: (a) evaluate from its lens, (b) explicitly flag where it disagrees with prior stages.
4. After stage completes, surface a one-line summary to the user before launching next stage. User can abort if a stage flags a kill.

## Prompt template per stage

```
Original proposal: <user's proposal>

Previous stage responses:
<stage 1 output>
<stage 2 output>
...

Your task from <persona> lens:
1. Evaluate the proposal from your domain (product value / UX / feasibility / strategic fit).
2. Flag any disagreements with prior stages — name them specifically.
3. State clearly: support / support with changes / kill. If support with changes, name the changes.

Be direct. Panda prefers terse critique over hedged consensus.
```

## Final synthesis

After all stages, produce a ≤200-word synthesis:

- **Verdict**: overall recommendation (ship / modify / kill)
- **Highest-signal disagreement**: where do personas diverge, and whose lens should win on that axis
- **Open questions**: what Panda still has to decide that no persona can decide for him

Do NOT paste all four persona responses in full into the main context. Each Agent call returns to the main session — summarize each in 2-3 bullets before moving to the next. This is the "keep main context clean" discipline.

## Anti-patterns

- Running all four in parallel and asking user to reconcile → that's fan-out, not pipeline
- Pipeline on a trivial change → ceremony cost > value
- Letting each persona repeat the proposal summary → wastes context; tell them "do not restate the proposal"
- Treating ceo as a rubber-stamp → if ceo never kills anything, the seat is broken

## Related

- `~/.claude/ARCHITECTURE.md` — persona agents are L2 on-demand
- `memory/project_agent_teams_candidates.md` — the broader agent-teams direction this fits
- Alex Ker's harness optimization post (2026-04-17) — source of the pipeline pattern
