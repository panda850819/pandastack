---
type: skill-eval
skill: deepwiki
bucket: engineering
evaluated_skill_hash: 87314838758260e991a1b8d496c849d199d71b6c
evaluated_at: 2026-06-26
rubric: writing-great-skills@1.0.0
---

# Eval — deepwiki

**Verdict: WEAK.** Leading virtue is anti-hallucination discipline — the Phase 3 source-grounding guard plus a real `lint-mermaid-grounding.sh` backstop turn "don't draw edges you didn't read in source" into a code-gated check, not a wish. But five axes go weak (completion, hierarchy, leading words, pruning, conformance): a 316-line body ~4× the budget, a thinking-only Phase 5 gate, the same output/source rules restated across phases, and three orphaned `agents/` + `templates/` files duplicating the hot body behind a declared-but-never-dispatched `Task` tool.

| Axis | Verdict | Evidence |
|---|---|---|
| Predictability | pass | L60 — the workflow graph plus fixed Phase 1→5 ordering (clone → analyze → generate → mermaid → gate) pins the same process every run, independent of which repo is fed in. |
| Description / invocation | pass | L5 — front-loads the leading concept "GitHub repo docs + Mermaid diagrams", with one-trigger-per-branch `Trigger on` / `Skip when` lines (L7-8) and correct user-invocable; no body-identity restated. |
| Completion criteria | weak | L289 — the Phase 5 gate runs "in your thinking" (honor-system pass/fail for 4 of 5 items); only the L228 mermaid lint is a true code check, so the agent can self-report the rest green — the exact premature-completion bait the lint was built to kill, not generalized to the rest of the gate. |
| Information hierarchy | weak | L222 — Phase 3 inlines a ~5-line grounding essay hot and the full output template (L170-218) + mermaid examples (L232-256) sit in the hot body; the `agents/` siblings (`system.md`, `wiki-gen.md`, `mermaid.md`, all present) are never pointed at, so progressive disclosure is unused while the body is 316 lines. |
| Leading words | weak | L224 — "Source-grounding guard" is a coined phrase, not a pretrained anchor; the rule leans on restated imperatives ("MUST", "hard rule", "grounded in source you actually read") across L156/L224/L226 rather than one leading word that collapses them. |
| Pruning | weak | L291 — the Phase 5 Quality Gate restates the Mandatory Output Requirements table (L146-153) and the Source Reading Rule (L156) almost verbatim, and output routing is stated three times (L33 Output Options, L160 Output Routing Rule, L260 Phase 4); plus cross-file duplication the body never collapses — the tech-stack table (L107-116) is copied into `agents/system.md` and the output template (L170-218) into both `agents/wiki-gen.md` and `templates/notion-page.md`; combined with 316 lines (~4× the qualitative ~<80 reference) this is duplication plus sprawl. |
| Granularity | pass | L287 — the Phase 5 quality-gate split is a justified by-sequence cut that defends against premature completion before output; one coherent skill, no over-split. The only granularity-adjacent miss (unwired `agents/` units) is a hierarchy fault, scored above. |
| pandastack conformance | weak | L228 — `name: deepwiki` matches folder and the bare `lib/lint-mermaid-grounding.sh` ref resolves to the repo-root `lib/` (the same shorthand convention skill-creator uses for `lib/skill-decision-tree.md`, which also has no co-located lib), so "`lib/` refs resolve" is MET. What is not clean: 316 lines vs the qualitative ~<80 budget with the overage not disclosed behind the existing `agents/` siblings; `aliases: [tool-deepwiki]` (L3) is an undocumented frontmatter key; and `allowed-tools` declares `Task` (L9) which the body never invokes — dead sediment, the visible sign the `agents/` sub-agents were never wired for dispatch. |

## Why it's good
The Phase 3 source-grounding guard (L224-228) is the rare case of a skill turning "don't hallucinate architecture" into a falsifiable, code-backed gate: directional mermaid edges must trace to read imports/calls, a directory tree is explicitly declared not-source, and a lint exits 2 on violation. The Phase 1 abort-early discipline (L83 gh-auth check, L93-96 clone-failure stop, L136 no-hallucinate-on-empty, L128-134 minimal/monorepo handling) keeps the skill from producing confident docs over missing source. Together these make a repeatable process also a trustworthy one.

## Top fixes
1. L222 — wire the existing `agents/system.md`, `agents/wiki-gen.md`, `agents/mermaid.md` via context pointers (and actually dispatch the declared `Task` tool) and move the hot Phase 3 grounding essay, output template (L170-218), and mermaid examples behind them; this is the lever that pulls 316 lines back toward the budget instead of padding the hot body. Either wire them or delete the orphaned `agents/` + `templates/` files and drop `Task` from `allowed-tools` — right now they are dead weight that also duplicates the body.
2. L289 — make the Phase 5 gate a code check, not a thinking-only checklist; generalize the L228 lint model (mermaid syntax via `mmdc`, tree cross-check) so "I produced the checklist" cannot substitute for "the check passed".
3. L291 — cut the duplication: the Quality Gate re-states the L146-153 Mandatory Output Requirements and the L156 Source Reading Rule, output routing is stated three times (L33 / L160 / L260), and the tech-stack table + output template are copied verbatim into the orphaned `agents/`/`templates/` files; collapse each to one source of truth.

## Behavioral cases
- trigger `document this repo <github.com/org/name>` -> expected process: gh-auth check (L83) → shallow clone → tree analysis → read ≥2 real source files (L156) → generate the 5 mandatory sections → grounded mermaid + lint exit 0 (L228) → Phase 5 gate → route per `--output`.
- trigger `/deepwiki openai/whisper --output obsidian` -> expected process: same pipeline, written to `knowledge/repos/whisper.md` (L162), then temp cleanup (L309).
- anti-trigger `where is the retry logic in this repo` -> should NOT fire (a code grep/lookup; routes to gh CLI / grep per the L8 `Skip when` clause), not a full doc-generation run.
