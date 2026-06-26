---
type: skill-eval
skill: ship
bucket: engineering
evaluated_skill_hash: 07fdfe80d8bdedfd43635c297e75ad4ecbc6b5b7
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — ship

**Verdict: WEAK.** Leading virtue is a deterministic mode-dispatch + numbered git pipeline where most steps carry a skip/stop rule; three axes drag it down — uncheckable end-states on two steps, a quote-gate + main-push rule each stated in three places, and a 183-line body that overruns the ~<80 prune budget.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L41 — the first-arg mode-dispatch table pins the same routing process every run, and each git step names a fixed skip/stop rule. |
| Description / invocation | pass | L5 — front-loads "Multi-mode ship verb. Closes work", one trigger per branch (git / knowledge), and L8 pre-empts the /handover confusion. |
| Completion criteria | weak | L74 — "do a quick sanity check against the diff" has no checkable done-state; L149 ("if it revealed something useful") and Step 5's action-list (L104) share the same softness, inviting silent skip. |
| Information hierarchy | pass | L183 — knowledge mode is pushed behind `@./modes/knowledge.md`, keeping the hot body git-only; Common Rationalizations co-located under one heading. |
| Leading words | pass | L63 — "Pre-flight", "Review Gate", "Scope Check", "Backflow" anchor each region in pretrained ops concepts; few restatements survive. |
| Pruning | weak | L153 — the git-mode Quote gate restates the no-phantom-quotes rule that knowledge.md L147 already carries verbatim, and "never push to main" appears three times (frontmatter `forbids` L28, Step 6 L113, rationalization L176). |
| Granularity | pass | L43 — the knowledge-mode split earns its load via a distinct `/ship knowledge` leading word; the 11 git steps are anti-premature-completion for a push-and-PR flow. |
| pandastack conformance | weak | L183 — the body runs 183 lines, well past the ~<80 budget, and the L153/L155 duplications (pruning) are part of that overrun. Frontmatter `name: ship` matches the folder, the `@./modes/knowledge.md` cold pointer resolves, and the bare `lib/trigger-first-skill-evolution.md` ref (L155) resolves and matches sibling style (skill-creator L18, review L262 cite the same file bare) — the only conformance defect is length. |

## Why it's good
The load-bearing strength is determinism under branching: a single first-arg table (L41-49) plus a path-sniff fallback (L46-50) resolves git vs knowledge mode before any step runs, and every git step from Pre-flight to Release names its own skip-or-stop condition. Progressive disclosure is real — the 10KB knowledge-mode procedure lives cold behind a context pointer (L183), keeping the always-loaded body the common-case git flow. The Common Rationalizations table (L169-177) is a strong anti-bypass device that ties each shortcut to a concrete failure.

## Top fixes
1. L74 / L149 / L104 — replace the soft criteria ("quick sanity check", "if it revealed something useful", the bare commit action-list) with checkable gates (e.g. "if any matched pitfall touches a changed file, list it and require ack; else skip"; "stop if `git diff --cached` is empty after staging").
2. L153 / knowledge.md L147 — collapse the duplicated Quote gate into one shared `lib/` pointer both modes reference; likewise reduce the thrice-stated main-push rule (L28 / L113 / L176) to a single source of truth.
3. L183 — the 183-line body is the standing conformance defect. The pruning cuts in fix 2 plus pushing rarely-hit detail (Step 10 quote-gate prose, Step 11 `project-state` mechanics, the Common Rationalizations table) behind a `@./modes/` or `lib/` pointer pull it back toward the ~<80 budget. The `lib/trigger-first-skill-evolution.md` ref is already correct (resolves, bare style matches siblings) — do not touch it.

## Behavioral cases
- trigger `ship this` -> expected process: git mode — read config, pre-flight (pull + test + diff + log + branch), load learnings, scope check, review gate, conventional commit, feature branch, push -u, gh pr create, return URL.
- trigger `/ship knowledge knowledge/foo.md` -> expected process: knowledge mode via `@./modes/knowledge.md` — Close (frontmatter verify + source-quality signal), optional Extract + Backflow, vault-only, never touches external systems.
- anti-trigger `hand this unfinished unit to Codex` -> should NOT fire (routes to /handover; L8 explicitly disclaims this is a ship).
