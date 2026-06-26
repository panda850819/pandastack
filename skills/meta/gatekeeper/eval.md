---
type: skill-eval
skill: gatekeeper
bucket: meta
evaluated_skill_hash: b90f08e9e3ff654bc40c14dc91b44a33c07b1bd0
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — gatekeeper

**Verdict: SOLID.** A mandatory STRIDE-classify-then-route Step 0 makes the trust check follow the same process every run, and a clean routing table pushes all domain detail behind pointers so the hot body stays a dispatcher.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L31 — "Step 0: STRIDE Classification (mandatory)" forces classify-before-route on every artifact, so the process is identical run to run regardless of artifact type. |
| Description / invocation | pass | L6 — front-loads "Pre-adoption trust check for external artifacts" then lists one trigger per branch (skill/MCP, repo, URL, on-chain, DeFi, product, social) plus the alias and a CN trigger; no body-identity restated. |
| Completion criteria | weak | L52 — only "Step 0" is numbered and it ends by deferring to "the routed review template (Step 1+)"; the SKILL.md states no checkable end-state for the overall run, so the agent can stop at a STRIDE table and call the gate done (premature completion). |
| Information hierarchy | pass | L23 — routing table maps each trigger to a `reviews/*.md` pointer; steps vs reference are cleanly separated and the 16 external pointers all resolve, holding progressive disclosure. |
| Leading words | pass | L33 — "STRIDE" is a strong pretrained threat-model anchor doing real invocation+execution work; "lingua franca" (L71) earns the cross-review aggregation idea in two words. |
| Pruning | weak | L13 — "A comprehensive security review framework for AI agents operating in adversarial environments" is a near-no-op restatement of the description; paired with the L162 slogan ("Security is not a feature — it's a prerequisite.") it is decoration that pays load to say nothing. |
| Granularity | pass | L23 — each review branch is split to its own reference file reachable by a distinct trigger, so every cut earns independent reach rather than inflating one body. |
| pandastack conformance | weak | L11 — frontmatter (L1-9) omits `type:` and the title carries a decorative emoji; the body runs 155 lines, well past the ~<80 guidance, padded by the L73-95 Universal Principles and L154-164 credits/slogan footer. |

## Why it's good
The skill earns its keep as a dispatcher: a single mandatory STRIDE Step 0 (L31) gives every external artifact the same classification spine, then the routing table (L21-29) hands the domain-specific work to seven reference files, all of which resolve. The risk-floor ratchet (L49-51, floors raise never lower) and "False Negative > False Positive" (L93) encode the conservative bias as checkable rules rather than vibes, which is exactly what a trust gate needs to stay predictable under pressure.

## Top fixes
1. L52 — add an explicit completion criterion in the SKILL.md: the gate is done only when a routed template report exists with a risk rating and (for 🔴/⛔) a human-decision line; without it "Step 0" can be mistaken for the whole job.
2. L13 — delete the "comprehensive security review framework…" line and the L162 slogan; the description already says what the skill is, and these pay context load for no behavior change.
3. L11 / L1-9 — trim the body toward the ~80-line budget (fold L73-95 Universal Principles that the templates already enforce, drop the L154-164 credits/emoji footer) and add `type: skill` to frontmatter for spec conformance.

## Behavioral cases
- trigger `is this MCP safe to install?` → expected process: run STRIDE Step 0 classification (L31), record none/suspect/confirmed per category, apply the risk floor, then route to `reviews/skill-mcp.md` and emit the standardized skill report template — never a free-form OK.
- anti-trigger `review my code before I open this PR` → should NOT fire; this is internal-diff correctness/security review, route to `/review` (or `/code-review`), not the external-artifact trust gate.
