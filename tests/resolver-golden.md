---
date: 2026-05-04
type: test
tags: [resolver, regression, b-test]
---

# Resolver Golden Test — pandastack v1.1

> 30 prompts × expected skill mapping. Run before merging B5 / B6 changes. Catches regressions when prompts → skill matching changes due to renames, new skills, or description tweaks.

## How to run

For each test case:

1. Inject prompt into a fresh Claude Code or Codex session with pdctx context loaded as specified.
2. Observe which skill fires (via Skill tool invocation log or PreToolUse hook trace).
3. Compare to expected. Mark pass / fail.
4. If fail: examine which skill fired instead, decide if it's a description fix, a missing trigger, or an actual regression.

Automated runner is a follow-up — manual eval acceptable for v1.1 cut.

## Test cases

### Direct slash invocation (12 cases)

```
T01  /sprint fix hermes cron                    pdctx: personal:developer  → sprint
T02  /sprint --quick rename one var             pdctx: personal:developer  → sprint (quick mode)
T03  /office-hours abyss dry run kill or pivot  pdctx: -                   → office-hours
T04  /boardroom plans/abyss-q2.md               pdctx: -                   → boardroom
T05  /dojo "fix hermes weekly retro cron"       pdctx: personal:developer  → dojo
T06  /prep "ship the rename batch"              pdctx: personal:developer  → dojo (alias /prep)
T07  /grill 想做一個 points system              pdctx: -                   → grill (default mode)
T08  /grill --mode structured points system     pdctx: -                   → grill (structured)
T09  /review                                    pdctx: personal:developer  → review
T10  /ship                                      pdctx: personal:writer     → write-ship (route by context)
T11  /ship                                      pdctx: personal:developer  → ship (route by context)
T12  /retro week                                pdctx: -                   → retro-week
```

### Old-name aliases — 90-day grace (7 cases)

```
T13  /morning-briefing                          pdctx: personal:writer     → brief-morning (alias)
T14  /weekly-retro-prep                         pdctx: personal:writer     → retro-prep-week (alias)
T15  /feed-curator                              pdctx: personal:knowledge-manager  → curate-feeds (alias)
T16  /content-write                             pdctx: personal:writer     → write (alias)
T17  /agent-browser open https://example.com    pdctx: -                   → tool-browser (alias)
T18  /slowmist-agent-security check this repo   pdctx: -                   → gatekeeper (alias)
T19  /harness-survey scan public ecosystem      pdctx: -                   → scout (alias)
```

### Natural language triggers (8 cases)

```
T20  "is this MCP safe to install"              pdctx: -                   → gatekeeper
T21  "check this github repo for me"            pdctx: -                   → gatekeeper
T22  "I want to think out loud about X"         pdctx: -                   → office-hours
T23  "let me prep before I start"               pdctx: personal:developer  → dojo
T24  "review this plan with all the leads"      pdctx: -                   → boardroom
T25  "what would the staff engineer say about"  pdctx: -                   → eng-lead (skill mode)
T26  "scout other harnesses for ideas"          pdctx: -                   → scout
T27  "morning briefing into today's note"       pdctx: personal:writer     → brief-morning
```

### Capability-probe degradation (3 cases)

```
T28  /sprint <topic>     env: gbq broken (pglite locked)
                                                                          → sprint runs, capability-probe outputs `gbq: broken`,
                                                                            stage 1 dojo falls back to rg, stage proceeds
T29  /office-hours <topic>  env: ~/.agents/AGENTS.md missing
                                                                          → office-hours ABORTS with capability-probe error,
                                                                            does NOT silently degrade
T30  /boardroom <plan>      env: skills/eng-lead/ deleted
                                                                          → boardroom ABORTS at Stage 2 voice scope detection,
                                                                            error: "voice eng-lead missing"
```

## Expected pass/fail tracking

```
| Case | Expected | Actual | Pass/Fail | Notes |
|---|---|---|---|---|
| T01 | sprint | _ | _ | _ |
| T02 | sprint (quick mode) | _ | _ | _ |
... fill in during run ...
```

## Acceptance criteria for v1.1 cut

- ≥27 / 30 pass (90%) on direct slash + alias + capability-probe (T01-T19, T28-T30 = 22 cases). Allow 2 failures in this set if they're documented and fixable in v1.2.
- ≥6 / 8 pass on natural language triggers (T20-T27). Description match is fuzzier; 75% threshold acceptable.
- 0 silent failures (every fail must produce error message, not wrong skill firing without notice).

## Failure response protocol

For each fail:

1. Run `gbq smoke` to confirm substrate is healthy at test time.
2. Read the skill's frontmatter `description:` — does it contain triggering keywords from the prompt?
3. If description gap: patch description, re-run that case only.
4. If actual skill is wrong: this is a real regression; examine the resolver's matching logic.
5. If silent failure (no skill fires): substrate or registration broken; check plugin manifest.

Log all fails to `Inbox/cron-reports/2026-05-04-resolver-test-results.md` with verdict + patch action.

## Origin

- codex Blind Spot 2 (2026-05-04 review) — pandastack has no resolver regression test, all dogfood is manual
- v1.1 cut introduces 7 renames + 4 new flow skills + Layer 1/2/3 split — high regression surface
- 30 cases is enough to catch obvious breaks; not exhaustive (a v1.2 follow-up may automate to 100+)
