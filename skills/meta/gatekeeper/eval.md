---
type: skill-eval
skill: gatekeeper
bucket: meta
evaluated_skill_hash: b90f08e9e3ff654bc40c14dc91b44a33c07b1bd0
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — gatekeeper

**Verdict: WEAK.** Leading virtue is a hard, predictable router — a mandatory STRIDE Step 0 (L31) classifies every artifact the same way before routing to one of seven cold-loaded branches (L21-29). It falls to WEAK on five axes: a description that clusters synonym triggers onto the same branch (L6), no overall run-completion criterion so "Step 0" can be mistaken for the whole job (L52), a hot body that keeps illustrative/essay reference inline instead of cold (L54-71), upstream sediment in an over-budget body, and a `_meta.json` name that contradicts the frontmatter. The hierarchy and conformance weaknesses are one root cause — the 106-line body — seen from two angles.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L31 — "Step 0: STRIDE Classification (mandatory)" forces classify-before-route on every artifact, so the process is identical run to run regardless of artifact type. |
| Description / invocation | weak | L6 — "is this safe to install" / "vet this MCP" both land on the skill-mcp branch and "trust check" renames the skill itself; synonym triggers per the SSOT one-trigger-per-branch rule, collapse them. |
| Completion criteria | weak | L52 — only "Step 0" is numbered and it ends by deferring to "the routed review template (Step 1+)"; the SKILL.md states no checkable end-state for the run, so the agent can stop at a STRIDE table and call the gate done (premature completion). |
| Information hierarchy | weak | L54-71 — the routing table (L23) and 16 pointers are clean, but the "Worked example" (L54-67) and "Why STRIDE before routing" rationale (L69-71) are pure illustration/essay sitting hot, not steps every branch needs; per the SSOT progressive-disclosure rule they belong cold, and they are what keeps the 106-line body from staying legible. |
| Leading words | pass | L31 — "STRIDE" is a strong pretrained threat-model anchor doing real invocation+execution work; "lingua franca" (L71) earns the cross-review aggregation idea in two words. |
| Pruning | weak | L162 — "*Security is not a feature — it's a prerequisite.* 🛡️" is a pure no-op slogan; with L13 ("comprehensive security review framework…") restating the description and the L154-158 Credits block, it pays context load to say nothing. |
| Granularity | pass | L23 — each review branch is split to its own reference file reachable by a distinct artifact trigger, so every cut earns independent reach rather than inflating one body. |
| pandastack conformance | weak | L2 — `name: gatekeeper` matches folder and all 16 lib refs resolve, but the body runs 106 non-blank lines past the ~<80 guidance and `_meta.json` still carries the stale upstream name `slowmist-agent-security`, contradicting the frontmatter. |

## Why it's good
The skill is built as a deterministic gate, not a checklist: STRIDE classification is mandatory and runs before routing (L31-52), and the floor rule makes the rating ratchet only upward (L49-51, "Floors raise, never lower"). The routing table keeps the hot body a single legible dispatcher (L21-29) while seven domain branches, three pattern libs, and six templates stay cold behind pointers that all resolve. Trust never degrades to zero scrutiny (L118) and human authority is reserved for HIGH/REJECT (L91), which keeps the high-stakes path predictable under pressure.

## Top fixes
1. L6 — collapse the synonym triggers: "vet this MCP" duplicates "is this safe to install" (both skill-mcp), and "trust check" renames the skill; keep the leading phrase + one distinct trigger per domain branch, drop the renames.
2. L52 — add an explicit run-completion criterion: the gate is done only when a routed template report exists with a risk rating and (for 🔴/⛔) a human-decision line; without it "Step 0" reads as the whole job.
3. L13 / L54-71 / L154-164 / _meta.json — push the "Worked example" (L54-67) and "Why STRIDE before routing" rationale (L69-71) cold behind a pointer, delete the "comprehensive…framework" restatement, the closing slogan, and the Credits/emoji footer (no-op upstream sediment), and update `_meta.json` `name` to `gatekeeper`; this lands both the hierarchy and conformance fixes by trimming the hot body toward the ~80-line budget.

## Behavioral cases
- trigger `is this MCP safe to install?` -> expected process: run STRIDE Step 0 classification (L31), record none/suspect/confirmed per category, apply the risk floor (L49), route to `reviews/skill-mcp.md`, emit the standardized skill report template (L134) — never a free-form OK.
- trigger `看這個協議的中央化風險` -> expected process: STRIDE classify, route to `reviews/defi-protocol.md` (L27, multi-contract governance scope) not `onchain.md`, emit `templates/report-defi-protocol.md` (L138).
- anti-trigger `review my code before I open this PR` -> should NOT fire; internal-diff correctness/security review routes to `/review` (or `/code-review`), not the external-artifact trust gate.
- anti-trigger `score how well this skill is written` -> should NOT fire; construction-quality scoring routes to `skill-eval`, gatekeeper checks adoption trust not skill writing.
