---
name: decision-flow
description: Lifecycle for reviewing and executing accumulated cron-proposed decisions — from report accumulation through Panda review to external push.
type: lifecycle-flow
---

# Decision Flow

> Triggered when `Inbox/cron-reports/` has accumulated pending items from background cron agents. The cron agents (wiki-lint, harness-audit, retro-prep, yei-alert-triage) produce structured reports with ticked `[ ]` proposal items — they never mutate systems directly. This flow is the human review + execution layer: Panda reads the reports, marks `[x]` on items to act on, then runs `/process-decisions` to execute the marked items. The design principle is cron proposes, Panda decides, `/process-decisions` executes. Nothing in this flow is automatic past the cron-report stage.

## Trigger

- Morning review: `Inbox/cron-reports/` has new files since last check
- `pandastack:wiki-lint` weekly cron deposited a report
- A harness-audit cron (private overlay, optional) deposited a report
- `retro-prep` cron deposited a pre-retro summary
- Manual `/process-decisions` run on a backlog of reports
- Panda notices two or more reports sitting unread for more than 2 weeks (warning threshold)

## Phases

### Phase 1 — Accumulate (cron writes reports)

- **What happens**: Background cron agents run on their schedules and write structured reports to `Inbox/cron-reports/<agent>-<YYYY-MM-DD>.md`. Each report contains `[ ]` checkbox items representing proposed actions. This phase is fully automated — no human action required.
- **Skills used**: `pandastack:wiki-lint` (weekly: stale/orphan/superseded notes); `pandastack:retro-week` auto-scan mode (pre-retro raw data); `pandastack:<harness-slim>` (private overlay, optional — harness audit proposals); `pandastack:<your-alert-triage>` (private overlay, optional — protocol risk proposals)
- **Output**: `Inbox/cron-reports/<agent>-<date>.md` files with unchecked `[ ]` proposal items. Each file is self-contained: agent name, run date, what it scanned, what it found, what it proposes.

### Phase 2 — Panda review (triage the reports)

- **What happens**: Panda reads each report, evaluates each `[ ]` item, and marks the ones to act on with `[x]`. Items to skip get a strikethrough or explicit `[-]` to indicate "seen, not actioning". This is a human judgment step — no automation. The review should take 5-15 minutes per report.
- **Skills used**: Read tool (read each report); Edit tool (mark `[x]` or `[-]` inline)
- **Output**: Reports with `[x]` marked on items Panda wants executed. Any item that cannot be decided on in this session gets a `[?]` with a note for why it's deferred.

### Phase 3 — Execute (process decisions)

- **What happens**: Walk through all `[x]` items across all pending reports. For each item: execute the proposed action, confirm the result, mark the checkbox as done in the report file. For items that require external system updates (Notion, Linear, Jira), create ship proposals in `Inbox/ship-proposals/` rather than mutating directly.
- **Skills used**: `pandastack:process-decisions` (walks through all `[x]` items, one by one, with explicit confirm per item); produces ship proposals for external-push items
- **Output**: All `[x]` items executed; report checkboxes updated to reflect done state; external-push items captured in `Inbox/ship-proposals/` for manual push

### Phase 4 — External push (when decision requires it)

- **What happens**: If executing a decision requires updating Notion, Linear, Jira, or sending a Slack message, that proposal routes through the work flow's external push phase rather than being executed directly here.
- **Skills used**: `pandastack:process-decisions` (cross-references to `Inbox/ship-proposals/`); `pandastack:tool-notion` / `pandastack:tool-slack` (if user authorizes direct push in this session)
- **Output**: External systems updated; ship proposals marked `status: pushed` in their frontmatter

### Phase 5 — Log to daily note

- **What happens**: After processing, append a summary to today's daily note: which reports were reviewed, how many items were actioned, how many were skipped, and any carry-forwards.
- **Skills used**: `pandastack:daily` (append to today's note)
- **Output**: Daily note entry: "Processed N cron reports, actioned X items, skipped Y, deferred Z"

## Exit criteria

- All `Inbox/cron-reports/` files from the current review session have been read
- Every `[ ]` item is either `[x]` (actioned), `[-]` (skipped with intent), or `[?]` (explicitly deferred with a date note)
- No report file is older than 2 weeks without at least a triage pass
- Daily note records what was processed

## Anti-patterns

- **Cron agents that mutate directly**: cron must only write to `Inbox/cron-reports/`. Any cron that modifies vault files, calls external APIs, or closes tickets without human review is violating the design contract. Surface immediately and fix.
- **Run `/process-decisions` without reviewing first**: `/process-decisions` walks through `[x]` items. If nothing is marked `[x]`, the command is a no-op — and if you marked everything `[x]` without reading, you are executing proposals you haven't evaluated.
- **Let reports accumulate beyond 2 weeks**: two or more unreviewed weeks of cron reports is a signal that the system is producing noise faster than it can be consumed. Stop adding cron agents and prune existing ones first.
- **Open a new session per report**: all pending reports from the same review window should be processed in one `/process-decisions` run. Context switching per report wastes 3x the time.
- **Skip the daily note summary**: the daily log is how retro-week knows what decisions were made during the week. A decision flow that doesn't produce a daily note entry is invisible to the retro layer.

## Skill choreography

```
[cron agents, async]
pandastack:wiki-lint
pandastack:retro-week  (auto-scan)
pandastack:<harness-slim>          [private overlay, optional]
pandastack:<your-alert-triage>     [private overlay, optional]
  → Inbox/cron-reports/<agent>-<date>.md  ([ ] items)

[Panda review, manual]
Read each report
Edit: mark [x] / [-] / [?]

[execute, manual trigger]
pandastack:process-decisions
  → executes all [x] items
  → creates Inbox/ship-proposals/ for external-push items

[external push, optional]
pandastack:tool-notion / pandastack:tool-slack  (if authorized)

[daily note]
pandastack:daily  (append session summary)
```
