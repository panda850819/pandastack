# Skill Context Schema

Pandastack skills may declare static context metadata in `SKILL.md`
frontmatter. `pdctx skill-validate` reads this metadata so a later
PreToolUse firewall can derive a per-skill allowlist before runtime.

## Fields

```yaml
reads:
  - vault: knowledge/**
  - repo: docs/briefs/**
  - cli: gbq
writes:
  - vault: Blog/_daily/*.md
  - repo: docs/briefs/*.md
  - cli: stdout
forbids:
  - vault: work-vault/**
  - cli: git push --force
domain: personal
classification: hybrid
```

`reads` lists paths, tools, or resources the skill may inspect.

`writes` lists paths, tools, or resources the skill may mutate or emit to.

`forbids` lists resources the skill must not touch even if the active
context would otherwise permit them.

`domain` is one of `personal`, `work`, or `shared`.

`classification` is one of:

- `read`: reads only, no intentional mutation.
- `write`: writes files or external records.
- `exec`: executes commands or external actions as the primary behavior.
- `hybrid`: mixes read, write, and command behavior.

## Access Entries

Each `reads`, `writes`, and `forbids` item must use:

```text
<source>: <target>
```

Known sources:

- `vault`: a vault-relative glob, for example `Blog/_daily/*.md`.
- `repo`: a repository-relative glob, for example `docs/briefs/**`.
- `file`: an explicit filesystem path outside repo or vault, for example
  `/tmp/morning-briefing-smoke.md`.
- `cli`: a command name or command prefix, for example `git` or
  `git push --force`.
- `mcp`: an MCP tool name or glob.
- `runtime`: a runtime capability such as `subagent`.

Path targets must not contain `..`, NUL bytes, or a leading `~`. Absolute
paths are only allowed for `file:` entries. Quote `**` in YAML when needed:

```yaml
reads:
  - repo: "**"
```

## Defaults

All fields are optional for backward compatibility. A skill with no context
metadata is still valid. `pdctx` treats it as:

```yaml
domain: shared
classification: read
reads: []
writes: []
forbids: []
```

`pdctx skill-validate` warns on missing metadata instead of failing.

## Migration

Backfill high-use skills first. Do not guess: list only resources the skill
body explicitly reads, writes, executes, or forbids. If a resource is unclear,
omit it and leave the skill in a less restrictive state until the owner
reviews it.

## Track D Link

Track D Layer 5 will consume `SkillFrontmatter.{reads,writes,forbids}` at
PreToolUse time to enforce tool-argument allowlists. The schema is intentionally
static so the firewall can decide before the tool call happens.
