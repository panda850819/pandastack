# Installing pandastack for Codex

Enable pandastack skills in Codex via native skill discovery. Just clone and symlink.

## Prerequisites

- Git
- Codex CLI

## Installation

1. **Clone the pandastack repository:**
   ```bash
   git clone https://github.com/panda850819/pandastack.git ~/.codex/pandastack
   ```

2. **Create the skills symlink:**
   ```bash
   ln -s ~/.codex/pandastack/plugins/pandastack/skills ~/.codex/skills/pandastack
   ```

   This points Codex's native skill discovery (`$CODEX_HOME/skills/`) at the pandastack skill directory. Tested with Codex CLI 0.124.0.

   **Windows (PowerShell):**
   ```powershell
   cmd /c mklink /J "$env:USERPROFILE\.codex\skills\pandastack" "$env:USERPROFILE\.codex\pandastack\plugins\pandastack\skills"
   ```

3. **Restart Codex** (quit and relaunch the CLI) to discover the skills.

## Optional: private overlay

Pandastack's `using-pandastack` skill supports a private overlay that adds personal vault paths, private skill triggers, and active experiment windows. To enable:

```bash
export PANDASTACK_OVERLAY=$HOME/site/skills/pandastack-private/overlays/using-pandastack.md
```

The SessionStart hook appends the overlay file to the public contract. If the overlay is missing, the public contract still works on its own.

## Verify

```bash
ls -la ~/.codex/skills/pandastack
codex exec --skip-git-repo-check 'List the pandastack skills you can see.'
```

You should see a symlink pointing to your pandastack skills directory, and Codex should enumerate ~37 skills as `pandastack:<name>`.

## Updating

```bash
cd ~/.codex/pandastack && git pull
```

Skills update instantly through the symlink.

## Uninstalling

```bash
rm ~/.codex/skills/pandastack
```

Optionally delete the clone: `rm -rf ~/.codex/pandastack`.

## Cross-CLI compatibility

Pandastack is designed Claude-Code-first but the lifecycle skills are CLI-agnostic. Compatibility breakdown:

- **Fully portable** (no CLI-specific tools): `careful`, `knowledge-ship`, `write-ship`, `work-ship`, `review`, `ship`, `compound`, `learn`, `checkpoint`, `think-like-naval`, `think-like-alan-chan`, `think-like-karpathy`, `content-write`, `grill`, `brief`, `init`, `freeze`, `done`
- **Needs Codex tool mapping** (uses `Skill` / `Agent` / subagent dispatch): see `skills/using-pandastack/references/codex-tools.md`
- **Local-environment-bound** (depends on Panda's local CLIs like `gbq`, `bird`, `notion-cli`, `slack`, `gog`): `tool-*` skills, `feed-curator`, `wiki-lint`, `process-decisions`, `agent-browser`, `qa`. These will fail with clear "command not found" errors if dependencies are missing — that's intentional, not a bug. (Skills in the private overlay have similar local-CLI dependencies.)

If you want to use only the portable subset, you can symlink individual skill directories instead of the whole `skills/` folder.
