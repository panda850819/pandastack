---
type: skill-eval
skill: freeze
bucket: engineering
evaluated_skill_hash: 2c1d203ec2c8aa8e63baa0206fd0191de0373c41
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — freeze

**Verdict: WEAK.** Leading virtue: a tight, co-located, well-pruned ~40-line guard that reads cleanly and fails loud (L33). It loses points because its core mechanism is an unbacked self-policing promise (L30), the "falls under" check is under-specified (L30), and it advertises `/unfreeze` as a peer command in the HOT description (L6) and Usage block (L17) while implementing it inline (L37) — a description restatement and a granularity straddle. Frontmatter is clean (name=folder, lint passes); the missing `user-invocable` is spec-OPTIONAL (SKILL-FRONTMATTER.md L48-54) and the pandastack norm omits it, so it is not a defect.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | weak | L30 — "For the remainder of this session, before any file edit ... Check if the target file falls under an allowed path." Enforcement is a voluntary per-edit re-check with no hook/state behind it (confirmed: no script/hook references `freeze`). Over an unbounded session this is exactly the stochastic drift skills exist to remove; the invoke steps (L21-33) are deterministic but the standing guarantee is best-effort. |
| Description / invocation | weak | L6 — "Run /unfreeze to remove restrictions" pushes body usage (duplicated at L17) into the HOT description, which should carry triggers + reach, not restate the mechanism. (The missing `user-invocable: true` is NOT the defect: SKILL-FRONTMATTER.md L48-54 marks it OPTIONAL and 11/12 engineering slash-skills omit it.) |
| Completion criteria | weak | L30 — "Check if the target file falls under an allowed path" defines no matching rule (prefix vs glob vs symlink vs path normalization), so two runs can disagree on an edge path; "remainder of this session" is open-ended with no re-anchor. The refusal string at L32 is checkable, but the gate that triggers it is not. |
| Information hierarchy | pass | L30 — the standing per-edit rule is correctly placed after the ordered On-Invoke steps; one file, nothing over-pushed, usage/invoke/unfreeze co-located. |
| Leading words | pass | L11 — "Lock editing scope" anchors the behaviour in the pretrained freeze/lock concept in the fewest tokens; no restatement sprawl that a stronger word must collapse. |
| Pruning | pass | L33 — "Never silently skip — always surface the block" is load-bearing (overrides the default fail-soft); 40-line body, no sediment or no-ops. |
| Granularity | weak | L37 — "When the user says `/unfreeze`" folds unfreeze inline, yet L6 advertises it as its own command; the split is neither made (distinct `/unfreeze` leading word, its own skill) nor cleanly avoided (don't present it as a peer command). It straddles. |
| pandastack conformance | pass | L2 — `name: freeze` matches the folder; body is 39 lines, well under 80; no lib/ refs to resolve; reads no reference so no hot/cold sub-agent dispatch is owed; `lint-manifest-sync.sh` passes with no warning. The missing `user-invocable` is spec-OPTIONAL (SKILL-FRONTMATTER.md L48-54) and the pandastack norm (11/12 engineering slash-skills omit it), so it is not a conformance defect. |

## Why it's good
The skill is small, co-located, and aggressively pruned: every line is live, the announce block (L24-29) and the fail-loud rule (L33) are load-bearing, and the freeze/lock leading word does its anchoring work cheaply. As a human-readable contract for "lock my edit scope to these paths" it reads exactly right, and unfreeze sits where you would look for it.

## Top fixes
1. L30 — back the enforcement or state its limit honestly. The skill promises to refuse every out-of-scope edit "for the remainder of this session" with nothing enforcing it (no PreToolUse guard, no state file — confirmed absent). Point the check at a guard/state file, or mark inline that enforcement is best-effort agent-side, so the agent does not over-promise determinism it cannot deliver.
2. L30 — define "falls under an allowed path": prefix-match on normalized absolute paths, directory args cover their subtree, file args match exactly, reject symlink escapes. Without this the gate is not reproducible across runs.
3. L6 / L37 — resolve the `/unfreeze` framing (fixes both the Description restatement and the Granularity straddle): either split unfreeze into its own user-invocable skill with its own leading word, or drop the "Run /unfreeze" advertisement from the HOT description (L6) and keep it only as the inline branch it already is (L37). Do NOT add `user-invocable: true` to chase this — the field is spec-OPTIONAL and the pandastack norm omits it.

## Behavioral cases
- trigger `/freeze src/api/ tests/api/` -> expected process: parse both paths as the allowlist (L21), announce FREEZE active listing both (L23-29), then for every subsequent Edit/Write/NotebookEdit check membership and refuse with the exact FROZEN string if outside (L30-33).
- trigger `/freeze` (no args) -> expected process: ask the user which paths to freeze to before activating (L22).
- anti-trigger `careful mode for this prod repo` -> should NOT fire; routes to pandastack `careful` (confirmation gates on destructive commands, not path-scoped edit blocking).
- anti-trigger `save my working state before I switch context` -> should NOT fire; routes to pandastack `checkpoint` (state snapshot, not edit-scope locking).
