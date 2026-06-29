---
type: skill-eval
skill: review
bucket: engineering
evaluated_skill_hash: 1b2cafbb5e7f64cc6aae9d7d5e2a6d650b730ca7
evaluated_at: 2026-06-29
rubric: writing-great-skills@1.0.0
---

# Eval — review

**Verdict: SOLID.** A fixed, decorrelated review pipeline (Step 0 audit -> parallel lenses -> cold review -> cross-model Codex) with every gate forced into a verifiable completion box; the #106 slim landed two prior fixes (description anti-triggers, rationalizations table out of the body) but the relocated table still re-states inline gates, so Pruning is improved-not-resolved.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L27 — "Run these 5 commands. **Do not skip.**" fixes the opener; Step 0->8 runs the same shape every run, `{main}`/`{learnings_dir}` are bound explicitly at L50 so no placeholder drifts, and conditional passes gate on detected `SCOPE_*` (deterministic), not model whim. |
| Description / invocation | pass | L4 — front-loads the leading word and now reciprocates boundaries: "NOT UI/browser (qa), plan critique (boardroom), or correctness-bug hunting (code-review)." The #106 edit closed the prior bare-one-liner weakness; only the `verify` (runtime-behavior) sibling boundary is still unstated. |
| Completion criteria | pass | L238 — Step 8 ASCII box forces a per-step accounting (audit ran/skipped, P0-P3 counts, COLD/CODEX catches, OPEN_QUESTIONS, CRITICAL_GAPS); abort still prints the box with unrun steps marked `skipped (user)`. Every "skip silently" is gated on a checkable condition. |
| Information hierarchy | pass | L128 — Pass 4-8 checklists sit cold behind `lib/conditional-passes.md` ("Skip the file entirely when no scope signal fired"); the #106 edit moved the rationalizations catalog the same way (L267), so the body now carries steps hot and pushes both rule catalogs behind pointers. |
| Leading words | pass | L120 — strong pretrained anchors: "Grounding requirement (anti-hallucination)", "AUTO-FIX | ASK", "COLD-CATCH", "CROSS-MODEL CONFIRMED", "needs-trace"; restatements collapsed into merge tags, not re-prose. |
| Pruning | weak | L267 — the 7-row Common Rationalizations table was relocated to `lib/rationalizations.md`, not deduped: its row "Step 0 audit takes too long, skip it" still re-states the inline gate at L27 ("Do not skip"), so single-source-of-truth is unmet, now across two files. Body is also 267 lines (~3x the ~80 guideline); earned as a flow orchestrator, but L103 Model-routing prose stays soft with no anchor. |
| Granularity | pass | L168 — the Step 6 / Step 6.5 split earns its load: cold-context (same model, no intent) and cross-model (GPT, different reasoning) are distinct decorrelation axes, and the `.5` numbering signals run-in-parallel-with-6, not a gratuitous sequence split. |
| pandastack conformance | pass | L70 — name=folder (`review`); all 6 `lib/` refs resolve (`confidence`/`conditional-passes`/`rationalizations` skill-local, now using the explicit `skills/engineering/review/lib/` path; `gate-contract`/`learning-format`/`trigger-first-skill-evolution` to repo-root `lib/`); hot/cold honoured via `context: fork` / `isolation: "worktree"` subagent dispatch. |

## Why it's good
The decorrelation architecture is the asset: in-session passes, a zero-context cold reviewer, and a cross-model Codex pass each attack a different blind-spot class, and the merge tags (COLD-CATCH / CROSS-MODEL CONFIRMED / needs-trace) keep their signals separable instead of mushed. The anti-hallucination grounding requirement (L120) is unusually disciplined: it demands a named, traced exploit path and adds the third `needs-trace` outcome so a real-but-untraced vuln is never silently dropped. The Completion Summary box (L238) turns "did I finish?" from vibe into a checkable artifact, abort included.

## Top fixes
1. L267 — the rationalizations relocation cleared the body bloat but duplicated meaning across files. Cut the rows that merely echo an inline gate (Step 0 skip vs L27, Codex skip vs L177) and keep in `lib/rationalizations.md` only the 2-3 with no inline enforcement behind them, so the catalog stops re-arguing the SKILL.md.
2. L4 — add the missing `verify` boundary to the anti-trigger list ("NOT runtime-behavior verification (use `verify`)"); `qa`'s own description already draws the review/verify/qa triangle, so review should reciprocate the third edge it currently omits.
3. L103 — "Model routing" still defers model choice to per-dispatch judgment with no example; one concrete anchor (mechanical pattern pass -> cheaper model, architectural-reasoning pass -> reasoning model) would make the routing predictable without reintroducing a fixed model-name table.

## Behavioral cases
- trigger `review my branch before I open the PR` -> expected process: Step 0 system audit (5 cmds, no skip) -> Step 1 scope/diff (binds {main}/{learnings_dir}) -> Step 2 load learnings w/ confidence decay -> Step 3 brief drift+coverage -> Step 4 detect SCOPE_* -> Step 5 parallel correctness/security/architecture + conditional passes -> Step 6 cold review -> Step 6.5 Codex (or mark unavailable) -> Step 7/7.5 learnings + flaw routing -> Step 8 completion box; stops without pushing (`git push` / `gh pr create` forbidden, L17-18).
- anti-trigger `QA this page / check the UI flow` -> should NOT fire (routes to `qa`, browser-based UI testing; review is code-diff only — now stated at L4).
- anti-trigger `poke holes in this plan / red-team this approach` -> should NOT fire (routes to `boardroom`, plan critique; review needs a diff, not a plan — stated at L4).
