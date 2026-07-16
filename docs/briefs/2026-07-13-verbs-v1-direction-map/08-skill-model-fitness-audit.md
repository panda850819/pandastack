# Skill-model fitness audit

Date: 2026-07-16
Entry: Skill-model fitness audit
Status: resolved

## Decision

Adopt an event-triggered **Current-Model Fitness Audit** for Verbs. Its unit is
`skill × host × exact model × effort × skill commit`. It combines matched
with-skill / without-skill runs with field evidence from real use. Start every
new model at its lowest useful effort and increase effort only on a demonstrated
quality miss.

The existing
[`current-model-recut`](../../../evals/2026-07-12-current-model-recut.md) is
seed evidence, not the v1.0 quality gate. It covers only `review` and `sprint`,
one model/effort pair, and hypothetical fixtures. It does not test routing,
false-positive invocation, host parity, or low-effort behavior.

Run the full audit when the default model family, effort default, or host skill
semantics change. A material edit to one skill runs only that skill's canary.
An ordinary Verbs release does not rerun all 14 skills.

## What the recent Matt Pocock evidence changes

- **Model names are incomplete without effort.** Matt explicitly says every
  frontier model behaves differently at each effort level. Audit records must
  treat the pair as one runtime identity
  ([source](https://x.com/mattpocockuk/status/2077373581932081654)).
- **Search effort from low to high.** His recommendation is to begin at the
  lowest effort and climb only after observing a quality dip; benchmark gains
  otherwise hide token, latency, and attention cost
  ([source](https://x.com/mattpocockuk/status/2077329609381581156)).
- **Correction time is an outcome metric.** A weak-model experiment on a complex
  build cost him 90 minutes of debugging. A cheap run that creates expensive
  repair work is a failed configuration
  ([source](https://x.com/mattpocockuk/status/2077024507420668349)).
- **Usage telemetry reveals contract drift.** In a non-final X poll snapshot,
  `/grill-with-docs` had 1,055 substantive votes, `/wayfinder` 833, and
  `/grill-me` 735. Matt separately reported that `wayfinder` was not producing
  enough shared-language work
  ([poll](https://x.com/mattpocockuk/status/2077081524474630227),
  [follow-up](https://x.com/mattpocockuk/status/2076996976525054246)). This is a
  routing/composition signal, not proof that one skill is better.
- **The interaction contract is part of fitness.** Matt's local experiment with
  asking all grill questions at once reduced repetitive "I agree" turns and
  changed his own preference
  ([source](https://x.com/mattpocockuk/status/2077385093027340382)). A skill can
  preserve its goal while its turn protocol becomes stale.
- **Context load must be measured, then cut.** His system-prompt audit starts
  with the actual payload and removes features that do not earn their recurring
  cost
  ([article](https://www.aihero.dev/how-to-kill-the-bloat-in-claude-codes-system-prompt)).
  The v1 skills release applied the same pressure to descriptions and reported
  a 63% reduction
  ([release note](https://www.aihero.dev/skills/skills-changelog-v1-announcement)).

The reusable pattern is a loop: observed failure or usage signal → smallest
contract change → controlled comparison → keep only the measured delta.

## Audit protocol

### 1. Freeze the runtime identity

Record host, exact resolved model, effort, CLI version, skill commit, tool
permissions, and repo snapshot. Never pool different effort levels into one
result.

### 2. Run the canary triplet

Each skill begins with three cases, each in a fresh session:

1. **Positive route:** a task that must invoke the skill.
2. **Negative route:** a nearby task that must not invoke it.
3. **Known failure:** a real incident or regression the skill claims to prevent.

Keep two evidence lanes separate:

- **Routing lane:** run the positive and negative cases against the full current
  pack without forcing an invocation. This tests the real catalogue + dispatch
  surface and records which skill, if any, fired.
- **Behavior lane:** run the known-failure case as a matched pair. The baseline
  removes the target skill and its dispatch row; the treatment adds only that
  skill back and invokes it. Keep prompt, model, effort, tools, and repository
  state identical. This isolates body lift from routing lift.

The triplet is triage evidence; a keep/cut decision needs the same behavior
effect on at least two independent real cases. Add a second matched case first;
add two more only when the result remains inconclusive.

### 3. Judge five gates

| Gate | Passing evidence |
|---|---|
| Invocation | Fires on the positive case and stays absent on the negative case. |
| Outcome | Changes a primary task result the skill explicitly claims to own. |
| Harm prevention | Prevents a critical failure such as fake-green evidence, unsafe action, wrong scope, or premature completion. |
| Interaction | Does not add unnecessary questions, handoffs, fan-out, or correction work. |
| Cost | Added input/output tokens, wall time, tool calls, human turns, and repair minutes are justified by the outcome or prevented harm. |

Do not collapse these into one weighted score. A severe harm regression fails
the skill even if an average score looks good.

### 4. Assign one verdict

- **UNPROVEN:** the cases do not exercise the skill's claimed primary outcome.
  This is a pre-verdict status, not a softer KEEP. Add the missing case before
  changing or deleting the skill.
- **KEEP:** repeatable outcome lift or critical-failure prevention on at least
  two independent real cases, with no severe regression.
- **EDIT:** useful delta exists, but the body, invocation surface, or turn
  protocol adds avoidable cost.
- **PIN:** useful only on a named host/model/effort combination; encode that
  boundary instead of claiming general applicability.
- **CUT:** the baseline matches the primary outcome and treatment prevents no
  critical failure, or treatment creates a severe regression.

### 5. Escalate effort only on evidence

Run the canary at the lowest supported effort. If baseline or treatment misses
the acceptance gate, rerun only the failing case one effort level higher. This
locates the cheapest passing frontier and distinguishes a skill problem from an
underpowered runtime.

## Initial Verbs assessment

| Surface | Current evidence | Status before pilot |
|---|---|---|
| `review` | The latest recut found the same toy auth defect with and without the skill; treatment added about 1.8K input tokens and process discipline. | Highest cut/slim pressure; needs real diffs. |
| `sprint` | The first treatment fabricated delivery evidence, and the revised skill stopped doing so. | Retained on harm-prevention evidence; needs a real delivery case. |
| `grill` | Matt's serial-versus-batched experiment shows the turn protocol is model/UX sensitive. | Re-evaluate interaction cost and unknown discovery first. |
| `wayfinder` | Poll usage and the shared-language complaint show unsettled routing/composition. | Re-evaluate invocation and charting composition first. |
| `advisor`, `handover` | Verbs already pins model and effort through `lib/model-anchors.md`. | Test exact pinned pairs and fail-loud behavior; do not pool models. |
| Remaining eight skills | Structural tests exist, but no paired current-model behavior evidence is stored in `evals/`. | Unknown, not green. |

All 14 skills are model-dispatched today. Therefore the audit must test both
invocation and execution. A body-level A/B result cannot prove that the model
will reach the skill at the right time.

## Consequence for the v1.0 gate

G-D should require a non-stale audit, where "stale" means the default model
family, effort default, host invocation semantics, or a load-bearing skill
contract changed after the recorded run. The gate does not require a full sweep
after unrelated documentation or packaging releases.
