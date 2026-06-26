---
type: skill-eval
skill: checkpoint
bucket: engineering
evaluated_skill_hash: 9c7f8273ccde701552576e70cc9746b0957931f4
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — checkpoint

**Verdict: WEAK.** A tightly-scoped three-branch save/resume verb whose embedded template and "reference, don't duplicate" rule make the process genuinely predictable; but three axes break: the description omits the List branch (L4), a destructive delete is gated on an undefined "successful resume" (L106), and Resume step 2 re-describes the List branch inline (L94) instead of pointing to it, violating single-source-of-truth.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L13 — "Parse the user's input" routes every run through the same three-branch dispatch (Save/Resume/List); the L23-29 gather block fixes the Save process across projects |
| Description / invocation | weak | L4 — "Save or resume" front-loads only 2 of 3 branches; the `list` branch (L17, L108) is invisible to model-invocation |
| Completion criteria | weak | L106 — "Delete the checkpoint file after successful resume" never defines "successful"; the delete is irreversible, so the vague gate is data-loss-adjacent premature-completion bait |
| Information hierarchy | pass | L69-73 — "Reference, don't duplicate" is co-located inside the Save step it governs, not floated to a distant section; the redaction guard (L75-76) sits with it |
| Leading words | pass | L11 — "Checkpoint" is the load-bearing pretrained concept; "Detect Command"/"Save"/"Resume"/"List" headings each carry their own anchor, no restatement to collapse |
| Pruning | weak | Template SSOT (L33-67) and body are clean of sediment, but L94 ("check all checkpoints and list them") restates the List branch (L108-118) inline rather than pointing to it — one real single-source-of-truth violation, not just no-op prose |
| Granularity | pass | L11-17 — Save/Resume/List kept in ONE skill sharing `docs/checkpoints/` and the `/checkpoint` leading word; correctly NOT split (no independent reach, sequence is short) |
| pandastack conformance | pass | L2 — `name: checkpoint` equals the folder; `project-state` ref (L80) resolves to `~/.local/bin/project-state`; reads <5K tokens so no sub-agent dispatch owed; the embedded template earns the >80-line body |

## Why it's good
Determinism through templates: the gather-state shell block (L24-29) and the verbatim checkpoint-file template (L33-67) leave almost nothing to model improvisation, so two agents checkpointing the same branch produce structurally identical artifacts. The "Reference, don't duplicate" rule (L69-73) and secret-redaction guard (L75-76) are co-located inside the Save step they constrain and encode real correctness invariants (a checkpoint that restates a plan drifts; secrets must never land in the file). Scope is honest and narrow — a save/resume verb that resists growing into a session manager.

## Top fixes
1. L4 — description omits the `list` branch and the focus-arg variant; add a trigger (e.g. "...or to list saved checkpoints") so model-invocation can reach all three branches, not just save/resume.
2. L106 — define "successful resume" before the destructive delete (e.g. "after the RESUMING block at L98 prints AND the file's contents are read into context"); an unmet-but-assumed success deletes the only state record. Consider archiving over deleting so a mis-fired resume is recoverable.
3. L94 — Resume step 2 ("check all checkpoints and list them") restates the List step (L108-118); fold it into a call to List (e.g. "fall through to the List branch") rather than re-describing the listing inline. This is the single-source-of-truth break behind the weak Pruning mark — small in size but a real duplication, not a split decision.

## Behavioral cases
- trigger `/checkpoint "ship the auth refactor"` -> expected process: run the L24-29 gather block, write the L33-67 template to `docs/checkpoints/{branch}-{date}.md` with Remaining/Suggested-Skills/Resume-Hint tilted toward the focus arg, best-effort `project-state append` if a project page exists (L80), print the L84 confirmation.
- trigger `/checkpoint resume` -> expected process: resolve current branch (L90), find matching checkpoint (L92), emit the RESUMING block (L98-104), then delete the file (L106).
- anti-trigger `save this fact about Bob to the brain` -> should NOT fire (routes to `ingest` / brain-ops; "save" here means a brain page, not a git working-state snapshot).
- anti-trigger `pause work and hand this to Codex` -> should NOT fire (routes to `handover`; checkpoint snapshots state for a later same-agent resume, it does not delegate unfinished work).
