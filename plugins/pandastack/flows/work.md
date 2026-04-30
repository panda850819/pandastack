---
name: work-flow
description: Lifecycle for handling Yei / Sommet work execution from alert or ticket triage through vault close and external push proposal.
type: lifecycle-flow
---

# Work Flow

> Triggered by any incoming work signal: a Yei protocol alert, a Linear or Jira ticket, a Slack ask, or a direct assignment from Bob. The flow enforces vault-only writes during execution (external mutations only via ship proposals reviewed by Panda), requires context lookup before acting (never from memory alone), and ends with a decision log in work-vault and a ship proposal ready for manual external push. The goal is not to close a Notion card — it is to produce a work-vault that compounds, so every similar problem the next time is cheaper.

## Trigger

- Incoming `yei-alert` or `yei-alert-triage` signal (protocol risk, treasury event, on-chain anomaly)
- New ticket created in Linear (Sommet/Abyss) or Jira (Yei)
- Slack message from core team that implies a decision or action
- Bob assigns a topic directly (P0: interrupt immediately)
- `/process-decisions` surfaces a `[ ]` item from a prior cron report

## Phases

### Phase 1 — Triage

- **What happens**: Classify the incoming signal by priority (P0/P1/P2/P3 per priority-map), domain (yei / sommet / abyss), and required response speed. P0 items interrupt; P2/P3 batch. Yei protocol risk is always P0 regardless of apparent urgency.
- **Skills used**: `pandastack:yei-alert-triage` (for protocol risk signals); manual priority-map judgment (for tickets and Slack)
- **Output**: Explicit priority label + domain tag on the work item. P0 items trigger immediate context fetch; P2/P3 go to digest queue.

### Phase 2 — Context fetch

- **What happens**: Before acting, search work-vault and personal vault for prior context on this topic. Never act from memory alone. Look for prior decisions, SOPs, stakeholder context, and related meeting distillations.
- **Skills used**: `qmd query "<topic>"` against work-vault first; personal vault for durable frameworks only; `pandastack:tool-notion` (read-only, metadata fetch) if Notion has the canonical page
- **Output**: A 3-5 sentence context summary or a pointer to the relevant prior decision/SOP file. If no prior context exists, note "first occurrence" explicitly.

### Phase 3 — Execute

- **What happens**: Do the actual work — analysis, decision, response drafting, tool calls. Use the appropriate persona for the domain and scope. Vault-only writes during execution; external systems read-only unless explicitly authorized for a one-off.
- **Skills used**: `pandastack:ops` persona (for Yei Ops, HR, Finance scope); `pandastack:product` persona (for Abyss Trade PO scope); `pandastack:ceo` persona (for strategy or Bob-facing decisions); `pandastack:tool-notion` / `pandastack:tool-slack` (read-only reference); `pandastack:misalignment` (if Slack scan reveals team signal misread)
- **Output**: Decision or action documented in a scratch note in work-vault; any external message drafted but not sent

### Phase 4 — Ship (vault close)

- **What happens**: Formalize the decision, write the work-vault decision log, and produce the ship proposal for external systems. The ship proposal contains checkbox items that `/process-decisions` or the user can walk through when ready.
- **Skills used**: `pandastack:work-ship` (Close: decision log + ship-proposal; Extract: decision / cycle waste / counterfactual / scope; Backflow: work-vault SOP, personal knowledge if generalizable, skill candidate, feedback)
- **Output**: `work-vault/decisions/<date>-<slug>.md` (SSOT for this decision); `Inbox/ship-proposals/<date>-<slug>.md` (pending manual push); ship log entry

### Phase 5 — External push (manual)

- **What happens**: Panda or a future authorized session runs `/process-decisions` to walk through the ship proposal checkboxes: update Notion status, close Jira/Linear ticket, send Slack notification. Never automatic.
- **Skills used**: `pandastack:process-decisions`
- **Output**: External systems updated, checkboxes marked `[x]` in ship proposal, daily note records what was pushed

## Exit criteria

- External ticket closed or explicitly deferred with a dated reason
- `work-vault/decisions/` has a new entry for this topic
- Ship proposal in `Inbox/ship-proposals/` either executed (all `[x]`) or explicitly parked
- If a generalizable principle emerged: personal knowledge note or work-vault SOP created

## Anti-patterns

- **Mutate external systems directly during execution**: every Notion page edit or Jira status change on a team-visible system should go through a ship proposal first. Silent mutations break trust and skip Panda's review layer.
- **Skip the context phase**: acting without prior-context lookup is the fastest way to repeat a decision that was already made (badly) three months ago. `qmd query` takes 5 seconds.
- **Mirror full meeting notes into obsidian-vault**: only distilled value crosses over — decisions, durable follow-ups, project/person/company context, reusable insights. Full transcripts stay in Notion.
- **Route all work through ops persona**: use the right persona for scope. Strategy or Bob-facing decisions need `pandastack:ceo`. Abyss PO decisions need `pandastack:product`. Ops persona is for operational execution only.
- **Close work without a counterfactual**: the most valuable part of work-ship Stage 2 Extract is the反事實 (fastest path if done again). Skipping it means the next similar topic costs the same.

## Skill choreography

```
pandastack:yei-alert-triage  [P0 only]
  |
  v
qmd query  (work-vault context fetch first)
  |
  v
pandastack:ops / product / ceo  (persona for domain)
  + pandastack:tool-notion (read)
  + pandastack:tool-slack (read)
  + pandastack:misalignment (if Slack signal scan needed)
  |
  v
pandastack:work-ship
  |── Stage 1: Close (decision log + ship-proposal)
  |── Stage 2: Extract (decision / waste / counterfactual / scope)
  └── Stage 3: Backflow (work-vault SOP, personal knowledge, skill candidate)
  |
  v
pandastack:process-decisions  (manual push, when ready)
```
