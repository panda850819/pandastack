---
type: skill-eval
skill: dojo
bucket: productivity
evaluated_skill_hash: 937c55a4ca031d0c48771e57c6b12555d0ee8ae1
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — dojo

**Verdict: WEAK.** Leading virtue: a clean, fixed 5-stage Stage-0 spine that runs the same process every invocation; costing it points are a trigger-stuffed/body-restating description, a no-op Origin block, and a 146-line body that overruns the ~80-line discipline without earning it.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L42 — "## Stages" opens a fixed 0a→0e sequence (probe → past-case → lib-load → gotcha → output) that runs identically every invocation; output varies by topic, process does not. |
| Description / invocation | weak | L6 — front-loads "Pre-action prep" well, but stacks 5 triggers plus "any non-trivial work session" and restates body identity ("Scans past similar cases (filename + grep), loads relevant lib/ refs, surfaces gotchas") the Stages already own — duplication the description should cut. |
| Completion criteria | pass | L59 — "Take top 5 hits across both. De-dup. Read the matched file's first 200 chars" is bounded and checkable; the lib-load step (L65) anchors the soft word "relevant" with a required 1-line-per-lib print so done-vs-not-done stays observable. |
| Information hierarchy | pass | L46 — `@../../../lib/capability-probe.md` pushes the probe behind a resolving context pointer; steps inline, reference externalized, each stage co-located under one heading. |
| Leading words | pass | L26 — the dojo/ring metaphor ("Before stepping into the ring, you walk into the dojo … Then you fight") + "Stage 0" anchor prep-before-action in one pretrained concept the agent runs the skill with. |
| Pruning | weak | L142-146 — the "## Origin" block (Codex Q6 review, 2026-05-04 provenance + naming note) plus L28's "Replaces the implicit 'I'll just start working'" clause are no-ops that change no run behaviour; sediment that pads the body. (The L26 epigraph is NOT a no-op here — it is the leading-word anchor credited below, so it earns its lines.) |
| Granularity | pass | L146 — `/prep` alias and the 0a→0e split each earn their load: alias = Layer-1 typing reach, and the sequential stages split to block rushing past-case lookup (premature completion). |
| pandastack conformance | weak | Frontmatter is VALID: `name=dojo` matches folder, `description` present, and `mode: skill` is an extra key the spec explicitly permits (SKILL-FRONTMATTER.md L57 "Other top-level keys are not warned and not blocked"; `type:` is optional with `skill` as default, so its absence is fine — and the lint passes). All 4 `@`/lib refs resolve and hot read ≈3.8K tok < 5K (no dispatch needed). The sole weak ground is length: the body is 146 lines vs the ~80-line discipline, and the Origin block + verbose output template are unearned padding. |

## Why it's good
The five-stage spine (L42-122) is the load-bearing strength: each stage has a concrete action and most end on a checkable result (top-5 + de-dup, first-200-char read, 1-line-per-lib, 1-3 gotchas), so the agent runs the same process every time. The dojo leading word (L26) and the resolving `@`-imports (L46, L138) keep the prep contract legible without bloating the description, and the anti-fabrication guard (L86, L131) plus escape-hatch handling (L140) close the two ways a prep flow most often goes wrong.

## Top fixes
1. L6 — prune the body-identity restatement ("Scans past similar cases (filename + grep), loads relevant lib/ refs, surfaces gotchas") from the description; keep only the triggers and the `/sprint`+`/office-hours` auto-invoke reach clause, which are the parts doing invocation work.
2. L142-146 — delete "## Origin" (and fold the `/prep` naming note into the description); provenance is a no-op that changes no runtime behaviour and pads the body past the ~80-line line. Move it to a commit message or CHANGELOG.
3. L92-122 — collapse the 31-line `Inbox/prep-*.md` output template toward the ~80-line discipline: the section headers (Capability probe / Past cases / Lib loaded / Gotchas / Suggested entry point) are already named by Stages 0a-0e, so the inline markdown skeleton is largely restated structure. Trimming it (plus fix #2) is what pulls the 146-line body back under the line. Leave `mode: skill` alone — the frontmatter spec permits it (L57) and the lint passes; there is no `type:` violation to fix.

## Behavioral cases
- trigger `/sprint on the payments refactor` -> expected process: dojo auto-fires at Stage 0 (L33), runs capability-probe (0a), scans `docs/sessions`/`learnings`/`knowledge` for "payments refactor" (0b), loads the sprint flow's declared libs (0c), surfaces real gotchas (0d), writes `Inbox/prep-*.md` and prints the path (0e), then STOPS — does not auto-continue into Stage 1 (L124).
- anti-trigger `fix this one-line typo in the config` -> should NOT fire; the "When to skip" gate (L38, "Trivial fix (1-line typo, single config)") routes it straight to the edit, no prep brief.
