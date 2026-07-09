# Instruction-corpus defect classes

> The six defect classes for auditing an always-loaded instruction corpus for rules that no longer earn their place. Migrated from the retired `instruction-audit` skill; run on a cadence (e.g. retro-week) or before adding a new rule. Read-only discipline: produce a candidate delete/rewrite/merge list, the human applies it. This is a lib, not a skill — the audit is a periodic pass, not an independently-triggered verb.

## Surfaces

1. `~/.agents/AGENTS.md` — the agent-agnostic contract (growth budget: ~200 lines)
2. `~/.claude/CLAUDE.md` — the Claude shim
3. `~/.agents/judgment-compact.md` — the judgment block
4. pandastack skill bodies (`skills/<bucket>/<skill>/SKILL.md`) — class (d) only; single-skill construction quality routes to `skill-eval`

## Defect classes

| Class | Hunt for | Test |
|---|---|---|
| (a) model-era compensation | rules hand-holding behavior a current strong model has natively | would deleting it change today's model's output? |
| (b) overtrigger language | CRITICAL / ALWAYS / NEVER on rules that have exceptions | a known exception exists — absolutism the model learns to discount |
| (c) step-list bloat | numbered procedures replaceable by one principle | can one sentence regenerate the same steps? |
| (d) cross-layer duplicate | same rule in two always-loaded files | near-match greppable across surfaces |
| (e) admission-test failure | rule that cannot name a failure mode prevented or a behavior changed | "what goes wrong without this line?" has no answer |
| (f) growth-budget breach | AGENTS.md over its ~200-line target | `wc -l` |

## Discipline

Walk surfaces 1-3 once per class (a)-(e); walk surface 4 (skill bodies) for class (d) only; run (f) on AGENTS.md. For every hit, quote the exact rule line — the quote must be greppable in the source file. Report every class explicitly, including "no hits": an unexamined class is not a clean class. Output a candidate delete/rewrite/merge list; the human applies it, never the audit.
