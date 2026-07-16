# Close pilot evidence gaps

Date: 2026-07-16
Entry: Close pilot evidence gaps
Status: resolved

## Runtime identity

- Eval transport: `codex exec 0.144.1`, model `gpt-5.6-sol`, effort `low`.
- Verbs commit under test: `68203b6ea029b8b5bf3494183bad7d251ff6c14b`.
- Every baseline and treatment used a fresh ephemeral session. Baselines did
  not read the target skill. Treatments read the current skill and its declared
  resources.
- Review cases were read-only. Sprint cases used disposable write-enabled git
  repositories with no remote, so neither arm could commit, push, open a PR,
  publish a release, or mutate GitHub.
- The foreground desktop host used `gpt-5.6-sol` at `high`; these results are
  Codex CLI evidence and do not prove desktop-host parity.

## `review` — EDIT

Two historical Verbs diffs supplied real repository context rather than a
synthetic defect:

| Case | Baseline | Treatment | Cost |
|---|---|---|---|
| Low-risk README cleanup, `8831798^..8831798` | Correctly returned no findings. | Also returned no findings, with explicit scope, risk, and self-refutation. No outcome lift. | 14,811 vs 45,671 tokens. |
| Trust-boundary guard change, `5bdee55^..5bdee55` | Found three substantive guard weaknesses and residual bypasses. | Produced three grounded findings with observed exit codes: `cd` / quoted `git -C` bypass, false blocking of an explicit issue-branch push from `main`, and an unquoted-safe-data false positive. It also flagged unrelated dispatch changes as scope drift. | 39,029 vs 56,599 tokens. |

The treatment's first and third trust-boundary findings correspond to defect
classes later fixed by historical commits `7e922fb` and `56f68b0`. Native review
already found the primary risk class; the skill improved provenance, executable
evidence, risk adaptation, and scope control. On the low-risk diff, that same
envelope tripled input cost without changing the result.

Decision: retain the high-risk contract and evidence-ranked reporting. Add a
fast path for a clearly bounded low-risk diff so it can stop after provenance,
one correctness pass, and self-refutation when no risk trigger fires. This is a
skill-body implementation task; the decision map records it separately rather
than treating this evaluation entry as delivery.

Cold-context escalation could not run inside the nested read-only Codex
session because that process attempted to write its state database. The
high-risk verdict therefore rests on the primary treatment review, executable
checks, and historical-fix correspondence, not a cold-review comparison.

## `sprint` — KEEP

Two independent real write-enabled cases exercised implementation, acceptance,
bounded review, correction, and the expected no-remote delivery boundary.

### Case 1: ASCII slug CLI

Both arms implemented a working CLI. The baseline passed five tests but left a
generated `__pycache__` directory and did not name a lifecycle state. The
treatment's first bounded review found that digits were retained contrary to
acceptance, fixed the defect, added a regression case, and passed its second
review. It finished with six tests, a clean diff check, and `State: PAUSED`
with the missing commit/push/PR evidence named explicitly.

- Baseline: 33,727 tokens, 5 tests passed.
- Treatment: 29,689 tokens, 6 tests passed after one review correction.

### Case 2: GitHub issue #219 release assets

The real issue acceptance criteria were applied to disposable copies of Verbs.
Both arms transferred the release archive and checksum into the publish job,
attached them while the release remained draft, and failed closed on zero,
missing, or multiple archives before any `gh` call.

- Baseline: 72,831 tokens, independently verified at 18 passed. It added the
  workflow regression suite and reported the absent delivery actions.
- Treatment: 60,759 tokens, independently verified at 19 passed. It added a
  separate producer regression suite, performed one medium-risk review with no
  actionable finding, self-refuted the artifact edge cases, and ended at
  `State: PAUSED` with an exact resume boundary.
- Both passed `git diff --check`; neither had a remote or changed the real
  Verbs repository or GitHub issue.

Issue #219 was subsequently closed as superseded by the personal-first slim in
`df1b6a1` / #221, which intentionally removed custom release assets. Its
acceptance criteria remain useful as a real implementation fixture; they no
longer describe current Verbs product direction and the disposable patch must
not be promoted into the repository.

Decision: keep the current sprint lifecycle contract for
`Codex CLI × gpt-5.6-sol × low`. Across both cases it repeatedly enforced the
delivery-state boundary, and in one case its bounded review prevented an
acceptance defect. It did not add measured token cost in either case. This does
not prove the remote `ship` path or other host/model/effort tuples; those remain
separate canaries.

## Audit-method verdict

The Current-Model Fitness Audit distinguished three outcomes that the earlier
fixture pass blurred:

1. native outcome parity with avoidable process cost (`review` low risk);
2. useful evidence and scope lift without exclusive defect discovery (`review`
   high risk);
3. repeatable lifecycle harm prevention (`sprint`).

The pilot gates are stable enough to proceed to the remaining skill-model
matrix. Keep every conclusion keyed to the exact runtime identity, and retain
`UNPROVEN` whenever a case does not exercise the skill's primary claim.
