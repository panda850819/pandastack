---
type: skill-eval
skill: init
bucket: engineering
evaluated_skill_hash: 52974238711ec5757f487d5f64f5dbf8a12bfbbb
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — init

**Verdict: WEAK.** A tight, single-branch bootstrap with a clean Detect → Confirm → Write → mkdir spine, dragged below SOLID by a back end that asserts "initialized" without ever verifying the write landed (premature-completion fail). The same final step (Step 5) is also a doubled "Confirm" leading word, a no-op print, and a gratuitous over-split — it costs three weak axes at once. The description further claims "ship preferences" the body never asks.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L11 — five named, ordered steps (`Step 1: Detect` …); one branch, no forks, same process every run. |
| Description / invocation | weak | L4 — front-loads "Use once per project to initialize pandastack" well, but carries no quoted trigger branch (no `/init`, no "set up pandastack"), so model-invocation rests on paraphrase match alone. L5 also claims the skill "asks ship preferences" yet no step asks them: Step 2 only confirms detected values and tag/release/deploy ship fields are fixed defaults (L26-28 `none`/`false`/`none`), never asked — a description-vs-body mismatch. |
| Completion criteria | fail | L59 — the skill ends by *printing* "pandastack initialized…" with no check that Step 3 appended the config block or Step 4's dirs exist; the closing step asserts done instead of verifying it. Step 1 (L13) likewise has no checkable done-state. |
| Information hierarchy | pass | L37 — config block inlined where Step 3 writes it; flat, all-inline, no external pointer, correct for a ~59-line single-branch skill. |
| Leading words | weak | L57 — "Step 5: Confirm" reuses the bare imperative from L19 "Step 2: Confirm"; neither is a pretrained anchor, and the collision sticks one weak word on two differently-purposed steps. |
| Pruning | weak | L57 — Step 5 "Confirm" is near no-op: it neither confirms nor verifies, just emits a fixed string, duplicating the "Confirm" label and barely earning its own step number. |
| Granularity | weak | L57 — Step 5 does not earn its load: it is a single fixed-string print that the Pruning axis flags as a near no-op, and Top-fix #2 recommends folding it into Step 4. A split that should be folded is a gratuitous cut. Steps 1-4 (L11/L19/L33/L50) are clean independent cuts; Step 5 is the lone over-split. |
| pandastack conformance | pass | L2 — `name: init` matches folder; 59 lines < 80; no `lib/` refs to resolve; no >5K-token read, so hot/cold dispatch is not triggered; `version`/`type` are spec-optional so their absence is valid. |

## Why it's good
The skill is tight (59 lines, well under the ~80-line budget) and does exactly one thing: a once-per-project bootstrap with a deterministic order that survives across runtimes (L35 handles the CLAUDE.md-vs-AGENTS.md split explicitly). The Step 2 AskUserQuestion gate (L19-L31) is the load-bearing choice, forcing human confirmation between auto-detect and the irreversible append. Predictability and information hierarchy are genuinely strong for a skill this small.

## Top fixes
1. **L59 — replace the print-only finish with a real completion criterion.** Make Step 5 verify: assert the `## pandastack` block exists in the target file and the four `docs/learnings/*` + `docs/checkpoints` dirs were created, then print success. As written, a failed Step 3/4 still reports "initialized". Give Step 1 (L13) a done-state and a test-not-found miss path too.
2. **L57 — rename or fold Step 5.** Two steps named "Confirm" (L19, L57) for different jobs is a leading-word collision; the final one is a no-op label and an unearned split (it costs the leading-words, pruning, and granularity axes at once). Rename to "Verify" (and give it teeth per fix 1) or fold the success string into Step 4.
3. **L4-5 — add explicit trigger branches and drop the false "ship preferences" claim.** Quote the invocation phrases (`/init`, "initialize pandastack", "set up this project") so model-invocation anchors on triggers, not paraphrase. Remove "asks ship preferences" — Step 2 only confirms detected values; tag/release/deploy are fixed defaults the skill never asks about. Trim the remaining step-recap clauses that restate body identity.

## Behavioral cases
- trigger `set up pandastack in this repo` → expected process: Step 1 auto-detect (lang/test/branch/CI), present detected values via AskUserQuestion (Step 2), append the config block to CLAUDE.md or AGENTS.md (Step 3), mkdir the learnings/checkpoints tree (Step 4), confirm.
- anti-trigger `update the pandastack config` → should NOT fire (init is once-per-project bootstrap, L4); reconfiguring an already-initialized repo is not this skill's job.
- anti-trigger `re-run review to refresh my learnings` → should NOT fire; routes to `/review`, which is what Step 5's own closing line (L59) points the user at post-init.
