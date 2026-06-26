---
type: skill-eval
skill: careful
bucket: engineering
evaluated_skill_hash: 93722d5996ca37af4ba2f1cbccf3faeb55c3fb44
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — careful

**Verdict: WEAK.** Leading virtue is a precise, checkable destructive-action gate; it loses points because a second subsystem (Lopopolo continue-failure logging) is fused in unsplit, pushing the body to 154 lines with audit-narration sediment and a co-location split against the lib it both points at and re-inlines.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L32 — "Before executing any of the following, pause and ask the user for explicit confirmation" plus the fixed L70-75 confirmation format gives the same gate process every run. |
| Description / invocation | weak | L5 — front-loads "Use when working on production code" cleanly, but the description sells only the destructive-gate half; the entire L77-137 stopping-discipline / continue-failure-logging subsystem is invisible to invocation. |
| Completion criteria | pass | L74 — "Proceed? [y/n]" makes each gate end checkable; the L85-90 self-check table and the L57-62 deploy-proof script are each done-vs-not-done. |
| Information hierarchy | weak | L57 — the verify-the-test-loop rules are inlined (L57-66) AND pushed out via `reads:` (L8) AND a `@../../../lib/...` pointer; the concept's rules live in two places, breaking co-location. |
| Leading words | pass | L147 — "The blast radius defines the gate, not the label" anchors behaviour in a strong pretrained concept; "pipeline alarm" (L64), "CAREFUL mode" likewise. |
| Pruning | weak | L122 — the "How this is audited" section (L122-129) narrates retro-week's behaviour inside a gate skill; with "Why this matters" (L115-119) it is ~15 lines of audit sediment that change no in-skill behaviour. |
| Granularity | weak | L77 — the Lopopolo continue-failure subsystem (own log file L97, own format L102-106, audit loop, anti-patterns L131-137) is a second independently-triggered concern fused into the gate skill; the by-invocation/by-sequence cut was never made. |
| pandastack conformance | weak | L154 — body is 154 lines vs the ~<80-line guidance, nearly 2x, and the excess (L115-129 audit narration) is not length that clearly earns itself. Frontmatter valid (name=folder L2), lib refs resolve, hot/cold honoured (lib ~1.3K tokens < 5K, no dispatch needed). |

## Why it's good
The destructive-action gate is the load-bearing strength: the trigger list (L34-54) is concrete, the L46 multi-path exemption logic is unusually precise (keys off artifact basename, not cwd, and re-arms on any foreign path), and the L70-75 confirmation format makes every pause checkable. The Common Rationalizations table (L145-154) is a strong anti-no-op device — each row converts a real bypass excuse into a blast-radius argument, anchoring the gate in pretrained concepts rather than a weak "be careful".

## Top fixes
1. Split the Lopopolo stopping-discipline subsystem (L77-137) out — either into its own skill keyed on its own leading word, or into a lib reached by a context pointer. It is a second independently-triggered concern (own log file L97, own format L102-106, own audit loop L122-129) that doubles the body and is absent from the description (L5).
2. Resolve the co-location split on verify-the-test-loop (L57-66): the rules are inlined here AND declared in `reads:` (L8) AND linked (L57). Keep one source — either the inline 3-bullet summary as the hot copy with no `reads:` claim, or a bare pointer with the rules only in the lib.
3. Cut the audit-narration sediment (L115-129): "Why this matters" and "How this is audited" describe retro-week's behaviour, not careful's; they change no in-skill action and belong in retro-week or a comment, not this gate skill's body.

## Behavioral cases
- trigger `git push --force origin main` -> expected process: fire the gate, print the L70-75 confirmation block (action / target / reversible:no / Proceed? [y/n]), wait for explicit y before executing.
- trigger `rm -rf /anywhere/node_modules` -> expected process: NO gate — basename is a regenerable artifact and the path is explicit (L46 exemption), proceed without confirmation.
- trigger `rm -rf node_modules ../../prod-data` -> expected process: gate re-arms for the whole command because the second path is non-artifact/foreign (L46 multi-path rule).
- anti-trigger `review my PR for correctness` -> should NOT fire (routes to /review); careful adds gates to in-progress work, it is not a code-review pass.
- anti-trigger `should I continue?` after a plan with no destructive command pending -> should NOT pause to ask (L90 self-check: just do it); careful's own stopping discipline forbids that pause.
