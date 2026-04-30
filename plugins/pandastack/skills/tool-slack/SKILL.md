---
name: tool-slack
description: Slack search/send/read via slack-cli. Trigger on Slack task or slack.com URL.
allowed-tools: Bash(slack:*), Bash(rtk:*), Bash(security:*), Bash(python3:*)
---

# Slack CLI

Interact with Slack using the `slack` CLI tool (installed via pipx from `<slack-cli-dir>`).

## Auth Bootstrap (run this first if `slack` fails)

If any `slack` command returns `Slack token not found. Set SLACK_CLI_TOKEN environment variable.`, the env var didn't propagate from `.zshrc` into claude's non-interactive shell. The token lives in Keychain — pull it explicitly and run:

```bash
# Export for a batch of slack calls in the same Bash block
export SLACK_CLI_TOKEN=$(security find-generic-password -s SLACK_CLI_TOKEN -w ~/Library/Keychains/login.keychain-db)
slack channel info "#general"     # Verify auth works
```

**Non-negotiable rules:**
- The explicit keychain path (`~/Library/Keychains/login.keychain-db`) is required. Without it, `security find-generic-password -s SLACK_CLI_TOKEN -w` may return empty depending on keychain search list state. Do NOT conclude the entry is missing from a path-less call alone.
- Do NOT declare Slack broken, fall back to `agent-browser`, or ask the user for the token before running this bootstrap. Exhaust this recovery path first.
- Only if bootstrap still returns empty AND `security dump-keychain ~/Library/Keychains/login.keychain-db | grep SLACK_CLI_TOKEN` shows no entry, escalate to user.
- Never `echo` the token or leak it to output. Command substitution (`$(...)`) only.

## Commands Reference

```bash
# Search messages
slack search "keyword"                    # Search workspace
slack search "keyword" -c #channel        # Search in specific channel
slack search "keyword" -n 50              # Limit results (default: 20)

# Send messages
slack send "#channel" "message"           # Send to channel (name or ID)
slack send "@<your-handle>" "message"             # Send DM to yourself
slack send "@username" "message"          # Send DM to any user
slack send "#channel" "reply" -t 1234.56  # Reply in thread (thread_ts)

# Reply to a thread by URL
slack reply "https://workspace.slack.com/archives/C0123ABC/p1769571017954789" "My reply"

# Channels
slack channel list                        # List public channels
slack channel list -p                     # Include private channels
slack channel list -t private             # Only private channels
slack channel history "#general"          # Recent messages (default: 50)
slack channel history "#general" -n 100   # More messages
slack channel info "#general"             # Channel details (members, topic, etc.)

# Direct Messages
slack dm list                             # List all DM conversations
slack dm history "@username"              # DM history with a user (default: 50)
slack dm history "@username" -n 100       # More messages

# TUI (interactive)
slack tui                                 # Launch interactive terminal UI
```

## Common Tasks

### Search for context

```bash
# Find what someone said about a topic
slack search "deployment from:@alice" -c #engineering

# Find recent discussions
slack search "budget Q2" -c #people-ops -n 10
```

### Send a message

```bash
# To a channel
slack send "#people-ops" "Sprint update: all tasks on track"

# DM to yourself (preview before posting to channel)
slack send "@<your-handle>" "Draft message to review"

# DM to any user
slack send "@<user>" "Hey, can you update your cards?"

# Multi-line messages — use heredoc
slack send "#channel" "$(cat <<'EOF'
First line
Second line
*Bold text* and _italic_
EOF
)"
```

### Read channel history

```bash
# Check recent activity
slack channel history "#general" -n 20

# Check DM with a specific person
slack dm history "@<user>" -n 20
```

### Reply to a thread

```bash
# By URL (from Slack "Copy link" on a message)
slack reply "https://<your-workspace>.slack.com/archives/C0123/p1769571017" "Got it, will fix"

# By thread timestamp in a channel
slack send "#engineering" "Fixed in latest deploy" -t 1769571017.954789
```

### Read a thread (API fallback — CLI has no command for this)

`slack` CLI does not expose `conversations.replies`. Call the Slack API directly via `rtk proxy curl` (raw curl is token-summarized by rtk and returns schema not data).

Parse the URL into `channel` + `ts`: `https://<ws>.slack.com/archives/C0AEFAE73R7/p1776324257910239` → `channel=C0AEFAE73R7`, `ts=1776324257.910239` (insert `.` before the last 6 digits of the `p`-id).

```bash
export SLACK_CLI_TOKEN=$(security find-generic-password -s SLACK_CLI_TOKEN -w ~/Library/Keychains/login.keychain-db)

rtk proxy curl -s -H "Authorization: Bearer $SLACK_CLI_TOKEN" \
  "https://slack.com/api/conversations.replies?channel=C0AEFAE73R7&ts=1776324257.910239" \
  > /tmp/slack-thread.json

python3 <<'PY'
import json
d = json.load(open('/tmp/slack-thread.json'))
for m in d.get('messages', []):
    user = m.get('user') or m.get('bot_id', 'bot')
    text = m.get('text', '')
    att = '\n  '.join(a.get('text','') or a.get('fallback','') for a in m.get('attachments', []))
    print(f"[{user}] {text}" + (f"\n  {att}" if att else ""))
    print("---")
PY
```

Bot messages put content in `attachments[].text` (and/or `.fallback`), not top-level `text` — extract both or you'll see blank messages.

## Key Channel IDs

| Channel | ID |
|---------|-----|
| #people-ops (example) | C0XXXXXXXXX |

## Gotchas

### Sending DM to yourself

`slack dm` has no send command. Use `slack send "@<your-handle>"` (your own Slack handle) to send to your own DM:

```bash
slack send "@<your-handle>" "Draft message to review"
```

`slack send` accepts `@username` format — the Slack API resolves it to the user's DM channel automatically. This works for any user, not just yourself.

**Do NOT use `@slackbot`** — that sends to the Slackbot DM, not your own self-DM.

### Installation

Installed via pipx from `<slack-cli-dir>`. If broken (e.g. Python version upgrade):

```bash
pipx reinstall slack-cli  # may fail if path changed
pipx install <slack-cli-dir>  # reinstall from source
```

If symlink conflict exists at `~/.local/bin/slack`:

```bash
rm ~/.local/bin/slack
ln -s ~/.local/pipx/venvs/slack-cli/bin/slack ~/.local/bin/slack
```

## Limitations & Workarounds

The `slack` CLI does not support every Slack feature. Handle gaps with available commands:

| Missing Feature | Workaround |
|----------------|------------|
| Thread replies | `rtk proxy curl` → `conversations.replies` API (see "Read a thread" above) |
| Unread messages | `slack channel history` on key channels + `slack dm list` to scan recent activity |
| Reactions/emoji | Search for the message, read context from history |
| Pinned messages | `slack channel info` may show pins; otherwise search |
| File uploads | Not supported — tell user to upload manually |

**Fallback priority**: `slack` CLI first → Slack Web API via `rtk proxy curl` for gaps the CLI doesn't cover (thread replies, reactions, pins). Do NOT use `agent-browser` for Slack — headless login is flaky and the profile isn't authenticated. The `references/slack-tasks.md` file contains legacy browser-based patterns that are **deprecated and must not be used**.

## Output Rules

Never dump raw CLI output to the user. Always:

1. **Summarize** — extract key info (who said what, when, channel context)
2. **Format** — use tables, bullet lists, or quotes for readability
3. **Highlight** — call out action items, mentions, or answers to the user's question

Example: if user asks "what did Alice say about the deploy?", search → read results → reply with a concise summary like:

> Alice in #engineering (Mar 27): "Deploy is blocked by the DNS migration — ETA Friday"

Do NOT paste the full `slack search` or `slack channel history` output.

## Quick Reference

| Task | Command | Key Flags |
|------|---------|-----------|
| Doctor (auth) | `SLACK_CLI_TOKEN=$(security find-generic-password -s SLACK_CLI_TOKEN -w ~/Library/Keychains/login.keychain-db) slack channel info "#people-ops"` | Verifies token works end-to-end |
| Search | `slack search "keyword"` | `-c #channel`, `-n 50`, `from:@user` in query |
| Send to channel | `slack send "#channel" "msg"` | `-t <thread_ts>` for thread reply |
| DM to self | `slack send "@<your-handle>" "msg"` | NOT `@slackbot`, NOT `slack dm send` |
| DM to user | `slack send "@username" "msg"` | |
| Reply by URL | `slack reply "<url>" "msg"` | |
| Channel history | `slack channel history "#channel"` | `-n 100` for more |
| Channel info | `slack channel info "#channel"` | Shows members, topic, pins |
| DM history | `slack dm history "@user"` | `-n 100` for more |
| Read thread | `rtk proxy curl ... conversations.replies` | See "Read a thread" section |
| Reinstall | `pipx install <slack-cli-dir>` | Fix with `rm ~/.local/bin/slack` if conflict |

## Tips

- Channel args accept both `#name` and `C0123ID` formats
- DM args accept both `@username` and `U0123ID` formats
- Slack formatting: `*bold*`, `_italic_`, `~strikethrough~`, `` `code` ``, `> quote`
- Links: `<https://url|display text>`
- For long messages, use heredoc syntax to avoid shell escaping issues
