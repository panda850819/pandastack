---
type: skill-eval
skill: review
bucket: engineering
evaluated_skill_hash: 6a0b0e81b0a96c57efedd3b31635012cccac03a8
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — review

**Verdict: WEAK.** Leading virtue is anti-premature-completion machinery — a fixed 5-command opener, a per-step ran/skipped completion box, and a rationalizations table that pre-empts every shortcut. It is held back by five weak axes: unresolved `{main}`/`{learnings_dir}` template variables that never bind, a description that recaps body identity, the Pass 4-8 conditional checklists sitting hot inline instead of behind a pointer, a 286-line body 3.5x over budget, and a Step 7.5 block duplicated from `ship`.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | weak | L59 — `{learnings_dir}` (also L63, L252, L254) and `{main}` (L54) are used as paths but no step ever binds them; Step 1 reads pstack config (L52) yet never states "resolve {learnings_dir}=docs/learnings, {main}=main", so the same step has no defined value across projects. |
| Description / invocation | weak | L5 — "Parallel 3-pass review (correctness, security, architecture) with cold review, Codex adversarial cross-check, and learning integration" restates body identity; the SSOT (L75) says cut identity already in the body and keep triggers only. The L4 trigger branches are clean; this recap is the lone flaw. |
| Completion criteria | pass | L297 — "If the user aborts mid-review, still print the box. Mark unrun steps as `skipped (user)`." every step ends in a checkable ran/skipped/count cell, killing premature-completion bait even on abort. |
| Information hierarchy | weak | L132-160 — the Pass 4-8 conditional checklists (migration/API/auth/infra/quality, ~29 lines) are reference reached only when a scope signal fires, yet sit hot inline; progressive disclosure is the rule (SSOT L77) and they should push behind a context pointer like the gate-contract one at L172 already does. Heavy work (Step 5 fork, Step 6 worktree, Step 6.5 Codex) does dispatch correctly, so this is a partial miss, not a collapse. |
| Leading words | pass | L176 — "Cold Review (Uncorrelated Context)" / "decorrelated context" (L305) anchors a pretrained concept; "adversarial cross-model" (L200) and "Outside Voice" (L230) likewise carry behaviour in few tokens. |
| Pruning | weak | L260 — Step 7.5 propose-only flaw-routing is near-verbatim duplication of `ship` SKILL.md L155 (same `lib/trigger-first-skill-evolution.md` ref, same `skill-edit candidate:` line, same "never during an autonomous build"); one meaning now lives in two skills, not one SSOT. |
| Granularity | pass | L200 — Step 6.5 splits from Step 6 because it runs a different model in parallel with its own degrade path; the cut earns its load (independent reach), not a gratuitous sequence split. |
| pandastack conformance | weak | L2 — frontmatter `name: review` matches folder and all 5 `lib/` refs resolve to repo-root lib (confidence/gate-contract/learning-format/quality-rubric/trigger-first-skill-evolution), but the body runs 286 lines, ~3.5x the ~<80-line guideline, only partly earned by genuine multi-pass scope. |

## Why it's good
The completion box (L276-295) and the Common Rationalizations table (L299-309) are the load-bearing strengths: together they make "did I actually finish the review?" un-fudgeable and pre-answer every shortcut an agent would otherwise rationalize. The anti-hallucination grounding requirement (L122) and the test-intent verification rule (L114) turn a vibe-review into a deterministic one, and the honest-degrade contract for Codex (L207-209) keeps a missing gate visible rather than silent. The `forbids: git push / gh pr create` frontmatter (L19-20) cleanly holds the review verb on the right side of the ship boundary.

## Top fixes
1. L54 / L59 — bind `{main}` and `{learnings_dir}` once at Step 1 (e.g. "resolve from the pstack config read above; default `{main}=main`, `{learnings_dir}=docs/learnings`"). As written they are dangling placeholders that make the learnings and diff steps run differently or stall per project — the single biggest predictability hole.
2. L260-270 — collapse the Step 7.5 / `ship` L155 duplication: both restate the same propose-only flaw-routing prose. Push the shared rule fully into `lib/trigger-first-skill-evolution.md` and have both skills cite it in one line.
3. L5-6 — strip the body recap from the description; the L4 trigger set already does the invocation work. The 3-pass/cold/Codex detail is COLD body content paying HOT context-load tax every session. (Bonus: pushing the Pass 4-8 conditional checklists at L132-160 behind a pointer cuts the 286-line body toward budget — see conformance L2.)

## Behavioral cases
- trigger `review my code before I open the PR` -> expected process: Step 0 audit (5 commands) -> scope/diff -> load learnings -> brief alignment -> detect scope -> parallel 3-pass + conditional passes -> cold review + Codex in parallel -> write learnings -> route flaws -> print completion box. Stops without pushing (forbids git push).
- trigger `check my code` -> same fixed process; conditional passes (Pass 4-8) activate only on detected diff scope (L90).
- anti-trigger `should I even build this / is the scope right` -> should NOT fire; routes to `office-hours` / `grill` for requirement discovery, not diff review.
- anti-trigger `ship this / create the PR and push` -> should NOT fire as review; routes to `ship` (`git push` / `gh pr create` forbidden here, L18-20).
