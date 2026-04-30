# pandastack (plugin internal)

Personal AI operator OS for Claude Code, with Codex CLI compatibility. ~37 skills, 5 personas, 7 lifecycle flows, 8 context recipes.

This file is the plugin-internal contract read by skill content. The user-facing README lives at the repo root.

## Skills (top-level surface)

Full catalog in `RESOLVER.md` at the repo root. Dev-workflow primitives:

- `/pandastack:init` — one-time project setup
- `/pandastack:grill` — adversarial requirement discovery (`--mode structured` for the formal-brief flow)
- `/pandastack:review` — parallel 3-pass review + Codex cross-check + learnings
- `/pandastack:qa` — browser-based QA with structured assertions
- `/pandastack:ship` — test + commit + PR
- `/pandastack:freeze` — restrict edits to specific paths (safety)
- `/pandastack:careful` — confirm before destructive actions (safety)
- `/pandastack:checkpoint` — save / resume working state snapshots

Lifecycle skills (knowledge / writing / work / retro / decision / research) listed in `RESOLVER.md`.

## Composite commands

- `/brainstorm` — diverge → filter → define → research → cost → go/no-go
- `/sprint` — full flow: brief → build → review → qa → ship + extract learning via knowledge-ship/work-ship
- `/design` — design-driven: brief → design → build → review → qa → ship + extract
- `/fix` — debug → fix → review → ship + extract
- `/quick` — small change: review + ship

## Agent personas

Read from `agents/` directory. 5 personas: ceo / design / eng / ops / product. Use their Iron Laws and judgment, not generic prompts.

## Learnings

Stored at the path configured in the project's CLAUDE.md under `## pandastack > learnings`. Default: `docs/learnings/`. Format: see `lib/learning-format.md`.

Compound logic (extract a debugging pattern / pitfall / architecture decision) is now part of `pandastack:knowledge-ship` and `pandastack:work-ship` Stage 3 Backflow — it routes to `docs/learnings/<category>/<slug>.md` automatically.

## Goal mapping (new in v1.0.0-rc.3)

`brief` and `grill --mode structured` run a Step 1.5 Goal Mapping pre-step that reads the user's goal hierarchy from memory and maps the current task to L1 (long horizon) / L2 (this season) / L3 (this week) layers. Downstream Clarify and Alternatives steps adapt to the dominant layer. See `lib/goal-mapping.md`.
