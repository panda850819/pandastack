---
name: decision-flow
description: Lifecycle for reviewing and executing accumulated cron-proposed decisions — from report accumulation through Panda review to external push.
type: lifecycle-flow
---

# Decision Flow

> Triggered when `Inbox/cron-reports/` has accumulated pending items from background cron agents. The cron agents (private overlay: harness-audit, yei-alert-triage; retro auto-scan via retro-week) produce structured reports with ticked `[ ]` proposal items — they never mutate systems directly. This flow is the human review + execution layer: Panda reads the reports, marks `[x]` on items to act on, then walks the `[x]` items manually using whichever skill matches each item. Vault hygiene checks (orphans / stale / dead redirects) are now gbq queries against the brain index, not a separate cron. The design principle is cron proposes, Panda decides, Panda executes. Nothing in this flow is automatic past the cron-report stage.

## Trigger

- Morning review: `Inbox/cron-reports/` has new files since last check
- A harness-audit cron (private overlay, optional) deposited a report
- `retro-week` auto-scan deposited a pre-retro summary
- Panda notices two or more reports sitting unread for more than 2 weeks (warning threshold)

## Phases

### Phase 1 — Accumulate (cron writes reports)

- **What happens**: Background cron agents run on their schedules and write structured reports to `Inbox/cron-reports/<agent>-<YYYY-MM-DD>.md`. Each report contains `[ ]` checkbox items representing proposed actions. This phase is fully automated — no human action required.
- **Skills used**: `pandastack:retro-week` auto-scan mode (pre-retro raw data); `pandastack:<harness-slim>` (private overlay, optional — harness audit proposals); `pandastack:<your-alert-triage>` (private overlay, optional — protocol risk proposals). Vault hygiene queries (orphan / stale / dead redirect) are now gbq queries run on demand, not a cron.
- **Output**: `Inbox/cron-reports/<agent>-<date>.md` files with unchecked `[ ]` proposal items. Each file is self-contained: agent name, run date, what it scanned, what it found, what it proposes.

### Phase 2 — Panda review (triage the reports)

- **What happens**: Panda reads each report, evaluates each `[ ]` item, and marks the ones to act on with `[x]`. Items to skip get a strikethrough or explicit `[-]` to indicate "seen, not actioning". This is a human judgment step — no automation. The review should take 5-15 minutes per report.
- **Skills used**: Read tool (read each report); Edit tool (mark `[x]` or `[-]` inline)
- **Output**: Reports with `[x]` marked on items Panda wants executed. Any item that cannot be decided on in this session gets a `[?]` with a note for why it's deferred.

### Phase 3 — Execute (manual walk)

- **What happens**: Walk through all `[x]` items across all pending reports. For each item: execute the proposed action with whichever skill matches (`/sprint`, `/grill`, `/inbox-triage`, etc.), confirm the result, mark the checkbox as done in the report file. For items that require external system updates (Notion, Linear, Jira), create ship proposals in `Inbox/ship-proposals/` rather than mutating directly.
- **Skills used**: `pandastack:inbox-triage` for low-stakes vault edits; `pandastack:sprint` for items that need a focused execution session; ad-hoc skill invocation per item
- **Output**: All `[x]` items executed; report checkboxes updated to reflect done state; external-push items captured in `Inbox/ship-proposals/` for manual push

### Phase 4 — External push (when decision requires it)

- **What happens**: If executing a decision requires updating Notion, Linear, Jira, or sending a Slack message, that proposal routes through the work flow's external push phase rather than being executed directly here.
- **Skills used**: `pandastack:notion` / `pandastack:slack` (if user authorizes direct push in this session)
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
- **Mark everything `[x]` without reading**: the human review step exists to filter cron noise. Marking `[x]` on items you haven't evaluated turns the cron into a silent mutation channel.
- **Let reports accumulate beyond 2 weeks**: two or more unreviewed weeks of cron reports is a signal that the system is producing noise faster than it can be consumed. Stop adding cron agents and prune existing ones first.
- **Open a new session per report**: all pending reports from the same review window should be processed in one walk. Context switching per report wastes 3x the time.
- **Skip the daily note summary**: the daily log is how retro-week knows what decisions were made during the week. A decision flow that doesn't produce a daily note entry is invisible to the retro layer.

## Skill choreography

```
[cron agents, async]
pandastack:retro-week  (auto-scan)
pandastack:<harness-slim>          [private overlay, optional]
pandastack:<your-alert-triage>     [private overlay, optional]
  → Inbox/cron-reports/<agent>-<date>.md  ([ ] items)

[Panda review, manual]
Read each report
Edit: mark [x] / [-] / [?]

[execute, manual walk]
For each [x] item, invoke matching skill:
  vault edits      → pandastack:inbox-triage
  focused work     → pandastack:sprint
  external push    → write proposal to Inbox/ship-proposals/

[external push, optional]
pandastack:notion / pandastack:slack  (if authorized)

[daily note]
pandastack:daily  (append session summary)
```
