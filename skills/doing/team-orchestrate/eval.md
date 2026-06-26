---
type: skill-eval
skill: team-orchestrate
bucket: doing
evaluated_skill_hash: 23943ee2c3f979091910fb81e1f0d576717b25e5
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — team-orchestrate

**Verdict: SOLID.** One leading word ("conductor") anchors a hard isolation invariant (dispatch, never edit), and a non-optional independence audit gates the whole dangerous N-writer operation before any subagent fires.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L51 — `## Protocol` runs the same fixed phases 0 → 0.5 → 1 → 2 → 3 every run, and the gate loop (verify → approve/edit/reject/skip) is identical per branch; the process is invariant even though outputs differ |
| Description / invocation | weak | L4 — "run these in parallel", "fan out", "N branches independent" are three near-synonym triggers for one branch (parallel-fanout); the spec says collapse synonyms that rename a single branch |
| Completion criteria | pass | L62 — the independence audit is sharply checkable ("If any two branches touch the same file, ABORT and route to N sequential sprints"); Phase 2 verify (L117-120) is equally falsifiable with read-the-worktree proof |
| Information hierarchy | weak | L83 — persona-inlining mechanics correctly point out to `lib/persona-frame.md`, but the Phase-2 gate block (L122-135) and full Inbox template (L156-189) are inlined verbatim instead of pushed behind the `lib/gate-contract.md` pointer the skill already cites at L122 |
| Leading words | pass | L26 — "Conductor-driven" anchors the entire behaviour region (dispatch/review/merge, no editing during dispatch) in one pretrained concept, reinforced at L33 ("Main session is the conductor … does NOT edit during dispatch") |
| Pruning | weak | L214 — the `## Origin` section is changelog sediment (Q2/Q3 history, v2.0.0 cut, two-strike rationale); it pays load without changing any runtime behaviour and helps push the body to 218 lines |
| Granularity | pass | L218 — cleanly the sole parallel-dispatch skill after execute-plan was cut, with the sequential case owned by `/sprint` (L45); the split earns independent reach by a distinct leading word |
| pandastack conformance | weak | L17 — `capability_required` + the `reads`/`writes`/`domain`/`classification` block (L5-16) are advisory-only audit metadata that nothing enforces per SKILL-FRONTMATTER.md L59-68 (firewall retired); combined with a 218-line body (~2.7x the ~<80 axis-8 budget), conformance is partial despite `name` matching folder and all four `lib/` refs resolving |

## Why it's good

The skill makes a genuinely dangerous operation (N parallel writers, silent merge corruption on file overlap) safe by front-loading a non-optional gate: the Phase 0 independence audit aborts before dispatch if any two branches share a file (L62), and the "conductor does NOT edit during dispatch" rule (L33) protects worktree isolation. The verify-don't-trust gate ("read worktree files, don't trust the report", L120) is the correct defence against subagent self-report drift, and the When-to-use / When-to-skip split (L35/L42) plus the contrast table (L28) make the route boundary against `/sprint` legible. The persona-inlining detail is rightly delegated to `lib/persona-frame.md` rather than bloating the body further.

## Top fixes

1. L4 — collapse the three parallel-fanout synonyms ("run these in parallel" / "fan out" / "N branches independent") to one trigger; they rename a single branch and inflate HOT context load every session.
2. L214-218 — cut or move the `## Origin` changelog to a CHANGELOG / commit trail; it is sediment that changes no behaviour and is a main driver of the 218-line body over the ~80 budget.
3. L122-189 — push the verbatim gate block and Inbox synthesis template behind the `lib/gate-contract.md` pointer already cited at L122; both are mechanical output shapes that belong in a reference file, not hot in the body.

## Behavioral cases

- trigger `/team-orchestrate on these 4 independent audit branches, plan is approved` → expected process: Phase 0 intake numbers the branches and runs the independence audit (ABORT on any file overlap, L62), Phase 0.5 routes a persona per branch and waits for confirm (L79), Phase 1 dispatches all in one message with N worktree-isolated Agent calls (L88), Phase 2 gates each return with read-the-worktree verification (L120), Phase 3 writes the Inbox synthesis page (L156).
- anti-trigger `parallelize this — branch 2 needs branch 1's output` → should NOT fire (the inter-branch dependency fails the independence precondition; routes to N sequential `/sprint` runs per L45/L199).
