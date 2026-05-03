# Layer 5 Firewall

Track D implementation. Consumes `reads`, `writes`, `forbids`, and `classification`
from skill frontmatter to enforce a per-skill tool-argument allowlist at PreToolUse time.

## How it works

When a Skill tool is invoked, `pdctx-skill-track/hook.sh` writes the active skill name
to `~/.pdctx/state/active-skill.json`. On every subsequent tool call, `pdctx-l5-allowlist/hook.sh`:

1. Reads the active skill name from that state file.
2. Parses the skill's SKILL.md frontmatter for `reads`, `writes`, `forbids`, and `classification`.
3. Extracts the path or command from the tool call arguments (Read/Edit/Write file_path, Bash command).
4. Applies the decision tree:
   - `forbids` → deny regardless of classification.
   - `classification: read` → permissive (only forbids checked).
   - `classification: write | exec | hybrid` → strict: allow if path/command matches `reads + writes`, deny otherwise.
   - Bash commands not in any list → permissive (too many implicit CLIs to enumerate).
5. Logs every decision to `~/.pdctx/audit/timeline-YYYY-MM-DD.jsonl` as `firewall_decision`.

## Sample deny output

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Layer 5: '/etc/passwd' not in skill allowlist for 'morning-briefing'"
  }
}
```

## Opt-out

```bash
export PDCTX_L5_DISABLED=1
```

Set in shell or as an env override in `settings.json` if you need to bypass during skill backfill.

## Trade-offs

- Skills with no frontmatter metadata are treated as permissive with a warning to stderr. This is intentional — blocking during the metadata backfill phase causes false denials.
- Bash commands are permissive even in strict mode. Extracting meaningful paths from arbitrary shell commands would require a full shell parser; the risk of false-positives outweighs the security gain at this stage.
- `vault:` entries resolve against the personal vault root (`~/site/knowledge/obsidian-vault/`). The work-vault lives at a separate path, so a `forbids: [vault: work-vault/**]` entry matches the obsidian-vault-relative path, not the actual `~/site/knowledge/work-vault/`. Use `file:` entries for absolute paths outside the primary vault.

## Known schema gaps

- `vault:` prefix assumes a single vault root. Multi-vault setups need explicit `file:` entries for secondary vaults.
- Wildcards are glob-style (`*` = single segment, `**` = any depth). Complex patterns (character classes, alternation) are not supported.
- `mcp:` and `runtime:` entries are not yet enforced by L5 (handled by the existing L3 MCP deny list).
- `active-skill.json` is session-global state. If a test or outer agent writes it without cleanup, it poisons the allowlist for subsequent tool calls. The session tracker should clear it on Stop.

## Layer map

| Layer | Mechanism | Status |
|-------|-----------|--------|
| L1 | Prompt-level persona / voice / banned-phrases | On |
| L2 | Filesystem chmod on memory namespace | On |
| L3 | MCP deny list (`pdctx-mcp-firewall`) | On |
| L4 | Context recipe (`pdctx use`) | On |
| L5 | Per-skill allowlist on tool args + paths | **This document** |
| L6 | JIT prompt — marginal decision cached | Future |
