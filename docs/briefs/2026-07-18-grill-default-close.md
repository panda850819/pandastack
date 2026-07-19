---
date: 2026-07-18
type: brief
source: grill
topic: Collapse grill to one skill with a default structured close
tags: [brief, grill]
---

# Collapse grill to one skill with a default structured close

## Problem

Panda's real friction is invocation recall, not skill coverage. Getting the
brief he wants ~80% of the time requires remembering `grill --brief`, and he
does not. The mode lives in the SKILL.md body, which only loads after the skill
is invoked, so dispatch routes to `grill` but never to the `--brief` mode — the
model leaves it at atomic and the human has to type the flag.

## Original premise

Adopt Matt Pocock's `grill-with-docs` — maybe drop the local grill entirely.
Secondary premise: split grill into two named skills so the name carries intent
and no flag is needed.

## Revised premise (after grill)

`grill-with-docs` is a one-line wrapper (`Run a /grilling session, using the
/domain-modeling skill`) — the exact skill-wrapping anti-pattern Panda rejected,
and its only delta over the local grill is domain-modeling, which the personal
brain (`decisions/` + `concepts/` pages) already covers. So: adopt nothing from
Matt. The local grill's drilling core is already stronger. The one real problem
is the `--brief` mode being unreachable from natural language. Since ~80% of
grill uses want the brief, the fix is not a flag and not a second skill — it is
to make the structured close the DEFAULT and let the rare chat-only case opt out
in natural language.

## Alternatives considered

- A: Split into `grill` (chat-only) + `grill-brief` (drill + close), drilling shared via `lib/` — Reject (user reversed; still asks the human/dispatch to route between two entries)
- B: `grill` (drill) + a distinct `brief`/`spec` verb that does not drill — Reject (forces two invocations for the 80% brief case)
- C: Collapse to ONE `grill`; default = drill + structured close (Stage A/B/C, writes brief + plan); a natural-language "quick / don't write files" signal short-circuits the whole close; remove the `--brief` flag entirely — Add

## Chosen approach

C — Default-close absorbs the 80% with zero flag and zero recall; the 20%
chat-only case is a cheap verbal opt-out; removing `--brief` erases both the
mode-routing gap (dispatch cannot route to a body-only mode) and the flag-recall
burden that was the original pain. No second skill, no new feature.

## Scope

In:
- grill's default behaviour becomes drill → structured close (the current
  `--brief` Stage A/B/C path).
- Remove the `--brief` flag and its "mode" framing from the SKILL.md.
- Stopping rule gains a chat-only opt-out: a "quick grill / don't write files"
  signal at the stop point short-circuits Stage A/B/C and leaves only the chat
  log.
- Sweep every `grill --brief` reference to `grill` (DISPATCH.md, RESOLVER.md,
  wayfinder SKILL.md, wayfinder manifest description).
- manifest description + version bump, RESOLVER row, sync regen, CHANGELOG.

Out:
- No change to the drilling protocol itself (8 axes, push-once, delete-first,
  escape-hatch, facts-vs-decisions all unchanged).
- No docs-engagement / domain-modeling feature — brain covers ADR + glossary.
- No second grill skill, no replacement flag.
- wayfinder's map-exit branch (too-big-AND-foggy → decision map) is unchanged
  in logic; only the `grill --brief` label in its prose is renamed to `grill`.

## Seams

The change passes through the existing `tests/run-all.sh` seam — sync
determinism, structural lint, and doctor parity. The sync-determinism check is
the guard that catches an un-regenerated loader JSON or a stale vendored lib. No
new seam.

## Next skill (recommended)

```
Shape: single-target-iterative
Reasoning: focused prose + config edits across one repo, needing judgment on the
SKILL.md rewrite and verification that sync stays deterministic and tests pass.

Recommended skill:
  → /sprint grill-default-close
```

## Gotchas surfaced

- `grill --brief` is referenced in at least 7 spots outside the grill SKILL.md
  (DISPATCH.md ×3, RESOLVER.md ×4) plus wayfinder. A missed reference is drift;
  the sync suite catches generated-file drift but NOT stale prose in a hand-
  written .md, so the sweep must be manual and complete.
- wayfinder charts by delegating to grill's map-exit, not the brief. After the
  rename, confirm wayfinder still reaches the map-exit (it is triggered by
  too-big-AND-foggy detection, independent of the brief path).
- The brain already studies "ADR discipline + re-evaluation trigger" in
  `topics/ai/tolaria-ai-coding-workflow-2026-04` — the accepted glossary/ADR
  hygiene note attaches there, it is not a new skill.

## Gate Log

- Stage 1 (load context): read Matt's full 41-skill repo; confirmed grill-with-docs is a 1-line wrapper; grounded brain `decisions/`+`concepts/` page types via query.
- Stage 2 (premise challenge): premise reversed twice (adopt grill-with-docs → split into two → collapse to one).
- Stage 3 (alternatives): chose C (collapse).
- Stage 4 (premise refresh): load-bearing premise = 80% of uses want the brief; default-close is correct only while that holds.
- Stage 5 (output): brief saved to docs/briefs/2026-07-18-grill-default-close.md

## OPEN_QUESTIONS

- Exact natural-language triggers for the chat-only opt-out (e.g. "quick",
  "just talk", "不用寫檔") — enumerate in the SKILL.md stopping-rule edit.
