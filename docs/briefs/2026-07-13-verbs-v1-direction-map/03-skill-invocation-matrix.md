# Decision note — Skill invocation matrix

Map: [Verbs v1.0 direction](../2026-07-13-verbs-v1-direction-map.md) · entry 3 ·
resolved 2026-07-13 · issue #234

## Question

Who may trigger each of the 14 skills: user-invocable × model-dispatched, per
skill, as deliberate policy instead of accident.

## Findings

1. **All 14 skills carried `user-invocable: false`** — the entire pack was
   blocked from manual (slash) invocation in Claude Code, not just `wayfinder`.
2. **Root cause was the spec, not the skills.** `maintainer/SKILL-FRONTMATTER.md`
   defined the field as an exclusive binary ("true = user-invoked-only,
   false = model-dispatched"). Real Claude Code semantics
   (code.claude.com/docs/en/skills, "Control who invokes a skill"): two
   independent flags — `user-invocable` gates the human channel,
   `disable-model-invocation` gates the model channel, defaults both open.
   Authors filled in `false` believing it enabled model dispatch; its actual
   effect was to block the human.
3. **Blast radius of the wrong semantics**: the Description cost rule and
   Dependency rule in the spec, plus the Invocation section of
   `writing-great-skills.md`, were all keyed to the nonexistent
   "user-invoked-only via user-invocable: true" class.
4. **Reference policy (mattpocock/skills, 25 active skills audited)**: no skill
   ever sets `user-invocable: false` — the human is never blocked. The only
   flag used is `disable-model-invocation: true` on lifecycle flows (wayfinder,
   implement, to-spec, to-tickets, triage, handoff, teach…): human initiates
   flows, model self-serves knowledge/technique skills.
5. Codex reads neither field; the bug only manifested in Claude Code.

## Decision

**All 14 skills: `user-invocable: true`, none set `disable-model-invocation`.**

Adopt the mattpocock invariant (never block the human) but not his
flow-blocking flag: Verbs' v1.0 destination is dual triggering (human + AI),
and its DISPATCH protocol already routes all 14 skills model-side — blocking
model invocation would break dispatch. Model-side restraint is carried by the
dispatch protocol's announce-the-match discipline, not by closing the channel.

## Applied (issue #234, branch fix/234-invocation-axis)

- 14 × `skills/*/*/SKILL.md`: `user-invocable: false` → `true`.
- Spec rewritten: "Invocation axes" table (two independent flags),
  `disable-model-invocation` documented as optional field, Description cost
  rule and Dependency rule re-keyed to `disable-model-invocation`.
- `writing-great-skills.md` Invocation mechanics corrected.
- Version 0.9.1 → 0.9.2, sync, CHANGELOG.

Not changed: test fixtures using `user-invocable: false` as syntactic filler
(`tests/verbs-sync.sh:70`, `tests/runtime-surface-test.py:47`) — they test sync
determinism, not semantics. `scripts/lint-invocation-axis.sh` still enforces an
explicit declaration per skill; the axis stays a deliberate per-skill decision.
