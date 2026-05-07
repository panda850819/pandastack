---
name: retro-flow
description: Rhythm-based retrospective lifecycle covering daily close, weekly interview retro, and monthly synthesis — all feeding forward into the next period's priorities.
type: lifecycle-flow
---

# Retro Flow

> Triggered on a fixed cron rhythm (daily at 23:00, weekly on Sunday, monthly at month-end) or manually via `/retro-week` and `/retro-month`. The flow is a discipline infrastructure, not a task list — its purpose is to convert raw activity into reflected learning, and to ensure the next period starts with explicit priorities rather than inertia. Each layer feeds the next: daily close feeds weekly material; weekly retros feed monthly synthesis. Skipping Phase 1 auto-scan (the raw signal pull) and going straight to interview produces retros driven by recency bias and feeling rather than evidence.

## Trigger

- **Daily**: `pandastack:done` cron at 23:00, or manual `/done` at end of any session
- **Weekly**: Cron on Sunday, or manual `/retro-week`
- **Monthly**: Cron on last day of month, or manual `/retro-month`
- **Manual override**: any time Panda wants to check in on a week or month mid-cycle

## Phases

### Phase 1 — Daily close (session end)

- **What happens**: At the end of each work session, write what was done to today's daily note, commit session-produced vault files, and persist memory updates. This is the raw signal layer that all subsequent retro phases depend on.
- **Skills used**: `pandastack:done` (session end: commit + memory persist + daily note summary); `pandastack:daily` (if daily note needs updates before close)
- **Output**: Updated `Blog/_daily/YYYY-MM-DD.md` with session summary; any session-produced files committed to vault; memory updated if new patterns or feedback emerged

### Phase 2 — Weekly auto-scan (raw signal pull)

- **What happens**: Before any interview or reflection, pull the objective raw signal for the week: `git log` across relevant repos, `learnings/` new entries, and the past 7 daily notes. Output is a structured raw summary — what was shipped, what was started but not finished, what came up repeatedly. This phase absorbs the logic of the retired standalone `pandastack:retro` skill.
- **Skills used**: `pandastack:retro-week` (Phase 1: auto-scan mode — git log + learnings/ + daily notes)
- **Output**: `Inbox/retro-prep/<YYYY-WNN>-raw.md` — structured raw data for the interview phase. Do not start the interview without this.

### Phase 3 — Weekly interview (reflection)

- **What happens**: Interactive retro against the raw data produced in Phase 2. Interview-style: one question at a time, adversarial where useful, surfacing the pattern behind the week rather than recapping it. This is where insight happens.
- **Skills used**: `pandastack:retro-week` (Phase 2: interview mode against raw)
- **Output**: `docs/retros/week-<YYYY-WNN>.md` — the week's retro note with explicit P0 carry-forwards for next week

### Phase 4 — Monthly synthesis

- **What happens**: Pull and synthesize the 4 (or 5) weekly retro-week files for the month. Look for patterns that span weeks: themes that kept appearing, decisions made under pressure that need revisiting, skill gaps that emerged repeatedly. Reference each weekly retro explicitly — do not synthesize from memory.
- **Skills used**: `pandastack:retro-month`
- **Output**: `docs/retros/month-<YYYY-MM>.md` — monthly synthesis with 3 strategic carry-forwards for next month

### Phase 5 — Priority feed-forward

- **What happens**: The retro's output is not just reflection — it must produce explicit next-period priorities. Weekly retro produces next week's P0 list (max 3). Monthly retro produces next month's 3 strategic focuses. These get written to the next day's daily note or a scratch priority file.
- **Skills used**: `pandastack:daily` (write priorities to next daily note); `pandastack:inbox-triage` (if retro surfaced deferred decisions that now need action)
- **Output**: Explicit P0 items for the next period, written to a dated file — not left as notes inside the retro doc

## Exit criteria

- **Daily**: today's `Blog/_daily/YYYY-MM-DD.md` has a session summary; vault files committed
- **Weekly**: `docs/retros/week-<YYYY-WNN>.md` written; next week's P0 list (max 3) extracted to daily note
- **Monthly**: `docs/retros/month-<YYYY-MM>.md` written; references at least 3 of the month's weekly retros explicitly; 3 strategic focuses for next month written

## Anti-patterns

- **Skip Phase 2 auto-scan and go straight to interview**: without raw data, the interview produces recency-biased impressions. The week you just had is always more vivid than what happened Monday. Pull the git log first.
- **Treat retro-week as a task list**: retro is reflection, not planning. The output should be patterns, insights, and counterfactuals — not a to-do list for next week. If you find yourself listing tasks, stop and ask "what does this pattern tell me?"
- **Write monthly retro without referencing the 4 weekly retros**: a monthly synthesis that doesn't pull from weekly retros is just a monthly journal entry. The synthesis value comes from the cross-week pattern scan.
- **Skip daily close because "nothing important happened"**: the days where nothing important happened are exactly where the pattern of drift lives. Daily close is a 3-minute discipline, not a ceremony for big days only.
- **Leave retro P0 carry-forwards inside the retro doc**: priorities buried in a retro file don't get acted on. They must be pulled out and written to the next period's daily note or priority scratch file where they will be seen.

## Skill choreography

```
[daily, 23:00 cron or /done]
pandastack:done
  + pandastack:daily
  → Blog/_daily/YYYY-MM-DD.md updated + vault committed

[weekly, Sunday cron or /retro-week]
pandastack:retro-week  Phase 1: auto-scan
  → Inbox/retro-prep/<YYYY-WNN>-raw.md
pandastack:retro-week  Phase 2: interview
  → docs/retros/week-<YYYY-WNN>.md

[monthly, month-end cron or /retro-month]
pandastack:retro-month  (reads 4x retro-week files)
  → docs/retros/month-<YYYY-MM>.md

[all periods]
pandastack:daily  (write P0 carry-forwards to next daily note)
pandastack:inbox-triage  (if deferred decisions surfaced as Inbox/cron-reports/ items)
```
