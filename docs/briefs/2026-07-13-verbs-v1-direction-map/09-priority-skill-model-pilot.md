# Priority skill-model pilot

Date: 2026-07-16
Entry: Priority skill-model pilot
Status: resolved

## Runtime identity

- Foreground Codex task: `gpt-5.6-sol`, effort `high`, desktop session metadata
  reports CLI `0.144.2`.
- Reproducible eval transport: `codex exec 0.144.1`, model `gpt-5.6-sol`, effort
  `low`, commit `68203b6ea029b8b5bf3494183bad7d251ff6c14b`.
- Routing lane: full installed Verbs plugin and dispatch, read-only, ephemeral.
- Behavior lane: read-only, ephemeral, `/tmp`, user config and rules ignored,
  `project_doc_max_bytes=0`; baseline and treatment shared the same remaining
  global contract. The treatment injected the target `SKILL.md`; `grill` also
  received its declared four lib resources.
- No run required an effort escalation. Every treatment followed its target
  contract at `low`. This proves only the pilot cases; it does not show that
  `high` is globally unnecessary.

The desktop and CLI versions differ. These results are Codex CLI evidence, not
desktop-host parity proof.

## Routing lane

Eight classifier probes tested one positive and one neighboring negative case
for each target. All eight matched the expected route at `low`:

| Target | Positive | Neighboring negative |
|---|---|---|
| `grill` | fuzzy billing idea → `grill` | exact README typo → `NONE` |
| `wayfinder` | multi-session fog → `wayfinder` | approved plan → `sprint` |
| `review` | pre-PR diff → `review` | live UI verification → `qa` |
| `sprint` | concrete build-to-PR → `sprint` | hypothetical no-tools outline → `NONE` |

Each full-pack classification carried about 26.8K total input tokens. This is a
context observation, not the marginal cost of any one skill description.

## Behavior lane

### `grill` — EDIT

Case 1 started fuzzy team-permissions discovery. Baseline asked two question
groups in one turn. The complete treatment asked one deletion-first question.
Output fell from 190 to 32 tokens.

Case 2 supplied a vague answer. Baseline already asked one concrete real-case
question. Treatment applied the prescribed `Push [3]` reverse-premise prompt.
Output fell from 76 to 36 tokens, but the treatment was not clearly more useful
than the baseline.

Decision: keep deletion-first, fact-vs-decision, and named pushback. Re-test the
hard one-question-at-a-time rule against a batch mode before preserving it as a
universal interaction contract. Current evidence proves predictability, not
better discovery per human turn.

### `wayfinder` — KEEP

Case 1 supplied evidence for the first of two frontier entries. Baseline closed
both entries and invented retry semantics. Treatment closed only the first,
graduated multi-writer fog into a typed entry, left the second open, and stopped.

Case 2 used the real Verbs v1 map shape with three unblocked entries and no
tools. Baseline touched all three and started answering the human side of a
grilling entry. Treatment claimed only the first research entry, reported the
missing evidence/tool boundary, left it open, and stopped.

Decision: the existing-map mode prevents repeatable scope and authorship
failures even on `sol/low`. Keep it. The separate charting-composition question
remains map Entry 4; this pilot does not settle it.

### `review` — EDIT

On the high-risk auth fixture, baseline and treatment both found the missing-key
authentication bypass and missing regression test. Treatment added risk lane,
scope, coverage, cold-review gap, and self-refutation; output increased from 146
to 319 tokens.

On the low-risk rename fixture, both approved correctly. Treatment added the
full process envelope; output increased from 39 to 247 tokens.

Decision: native `sol/low` already reached both primary outcomes. Retain the
skill's provenance, high-risk, evidence, and cold-review delta, but narrow the
automatic path so trivial low-risk review does not pay the full envelope. Two
real repository diffs are still required before implementing that cut.

### `sprint` — UNPROVEN

On the concrete hypothetical fixture, baseline produced a safe execution plan;
treatment added `Execution: NOT_RUN` and explicit delivery-state boundaries.
On the ambiguous migration fixture, baseline correctly stopped and listed four
decisions; treatment added `Execution: NOT_RUN`, routed to `grill`, and asked one
load-bearing question.

Decision: routing correctly excluded planning-only tasks, and the body preserved
the honesty boundary when forced. Neither case exercised real edits,
post-final-edit acceptance, bounded review correction, or delivery evidence.
The lifecycle value is therefore UNPROVEN on this transport, not KEEP or CUT.

## Pilot decision

The method distinguishes routing lift from body lift, but a four-verdict-only
scheme forced unsupported conclusions when the fixture missed the claimed
outcome. `UNPROVEN` is now a required pre-verdict status.

Do not expand to the remaining skills yet. First close two evidence gaps:

1. run `review` on two real repository diffs, including one low-risk and one
   trust-boundary change;
2. run `sprint` in a disposable write-enabled repo through acceptance, review,
   and the expected no-remote `PAUSED` delivery boundary.
