# pandastack on Hermes

Hermes support exists today, but it is not the same shape as Claude Code.

Hermes does not consume the Claude plugin manifest directly.
The practical question is which role Hermes plays in your setup.

There are two valid integration modes.

## Mode A, recommended: Hermes as scheduler or host, `pdctx` as dispatch layer

This is the primary dogfood setup.

In this model:
- Hermes receives the trigger, chat message, cron event, or scheduled job
- Hermes runs a command or workflow that calls `pdctx`
- `pdctx` injects the right context, persona, skill subset, memory namespace, and source policy
- the downstream runtime executes with pandastack discipline

This mode is recommended when the workflow depends on:
- context switching
- per-context memory boundaries
- skill subset restriction
- firewall or source-policy behavior
- reproducible dispatch across runtimes

### Why this is the default

Pandastack is a stack package. `pdctx` is the context and dispatch layer.
Hermes is strong at:
- scheduling
- messaging gateway delivery
- tool hosting
- autonomous runs

`pdctx` is strong at:
- context selection
- prompt injection
- runtime dispatch
- local stack conventions

Use each layer for what it already does well.

### Install

1. Install Hermes normally.
2. Install `pdctx`.
3. Point Hermes jobs or manual tasks at `pdctx call ...`.

Example:

```bash
git clone https://github.com/panda850819/pdctx ~/site/cli/pdctx
cd ~/site/cli/pdctx
bun install
bun link
pdctx init
pdctx use personal:developer
```

Example dispatch:

```bash
pdctx call personal:writer "/morning-briefing"
```

### Good fits for Mode A

Use Mode A when you want:
- morning briefing, evening distill, weekly retro prep
- a Hermes cron job that triggers a pandastack workflow
- the same context recipe reused across Claude, Codex, and scheduled jobs
- a clean separation between orchestration and execution

### Known caveats

- cron or sandboxed environments may restrict writes to dotdirs like `~/.pdctx` or `~/.codex`
- if the downstream runtime version is stale, the dispatch may fail even when pandastack content is fine
- verification should happen on the real scheduled path, not only in an interactive shell

## Mode B, direct Hermes skill import

In this model, Hermes loads pandastack skill content directly from `~/.hermes/skills/`.

This can work when you want:
- selected pandastack skills available as native Hermes skills
- simple reuse without `pdctx`
- a lightweight import path for workflows that do not require context injection

### Install

Copy or symlink selected skill directories from:

```text
plugins/pandastack/skills/
```

to your Hermes skill tree, for example:

```text
~/.hermes/skills/<category>/<skill-name>/
```

This repo does not currently ship a first-class Hermes package manifest.
Packaging for Hermes is manual today.

### Good fits for Mode B

Use Mode B when:
- the skill is mostly host-agnostic
- the workflow does not depend on `pdctx` context recipes
- you want a direct Hermes-native invocation path

Examples that are more likely to fit:
- writing or research workflows with minimal local coupling
- review or planning patterns that do not depend on Claude plugin semantics

### Known caveats

- direct-import skills lose `pdctx` context layering unless you recreate it manually
- categorization under `~/.hermes/skills/` is your responsibility
- skills that assume local Panda-only CLIs may still fail if dependencies are missing
- host-specific wording may need cleanup over time

## Choosing between the two modes

Use this rule:

| Situation | Recommended mode |
|---|---|
| scheduled jobs, cron, cross-runtime dispatch | Mode A |
| context-sensitive workflows | Mode A |
| simple direct reuse of individual skills | Mode B |
| experimenting with portability of one skill | Mode B |

If the workflow touches contexts, memory boundaries, or runtime arbitration, use Mode A.

## What Hermes is responsible for

In pandastack terms, Hermes should usually own:
- cron scheduling
- message delivery
- background execution
- chat or platform triggers
- high-level orchestration

Hermes should not be forced to own every part of pandastack's context model if `pdctx` already does that job.

## What pandastack should not assume in Hermes

Do not assume:
- Claude plugin marketplace exists
- `CLAUDE.md` is the install primitive
- plugin reload semantics match Claude Code
- all direct-import skills have a perfect tool-name match

Document the real Hermes path instead.

## Verification checklist

A Hermes integration is healthy when:
- the chosen mode is explicit
- install steps are reproducible
- update steps are documented
- one real invocation path was tested
- scheduler behavior and local interactive behavior agree

## Updating

### If you use Mode A

Update both the content and the dispatch layer when relevant:

```bash
cd ~/site/skills/pandastack && git pull
cd ~/site/cli/pdctx && git pull
```

Then re-run the target Hermes flow or cron dry-run.

### If you use Mode B

Update the pandastack repo, then re-copy or re-symlink changed skill folders into `~/.hermes/skills/`.

## Support level

Current support level for Hermes is:
- supported as scheduler or host when paired with `pdctx`
- manually supported for direct skill import
- not yet a first-class packaged host in this repo

That should remain the public claim until pandastack ships a dedicated Hermes packaging surface.