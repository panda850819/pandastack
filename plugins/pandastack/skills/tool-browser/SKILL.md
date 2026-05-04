---
name: tool-browser
aliases: [agent-browser]
description: Browser automation CLI for AI agents. Triggers on "open website", "fill form", "click button", "take screenshot", "scrape page", "test web app", "automate browser", or any task requiring programmatic browser interaction.
allowed-tools: Bash(npx agent-browser:*), Bash(agent-browser:*)
version: 2.1.0
user-invocable: true
---

# Browser Automation with agent-browser

Install: `npm i -g agent-browser` or `brew install agent-browser`. Run `agent-browser install` to download Chrome.

## Preferences

Shared references (read before executing):
- `memory/reference_named_sessions.md` — `--session-name` identifiers (panda-x, yei-notion, etc.)
- `memory/reference_trusted_sites.md` — trusted sites (extended timeout) and SKIP (escalate, don't retry)

### Browser-specific
- Screenshot defaults: `--full` for documentation, `--annotate` for audits (unlabeled icons, charts)
- For X/Twitter **text** content: prefer `bird` CLI over browser. Browser only for login-gated, video, or multi-tweet threads.

## Core Workflow (follow every time)

Every browser task follows these 6 steps. Do not skip any.

1. **Open + Wait**: `agent-browser open <url>` then `agent-browser wait --load networkidle`. For auth sites: add `--session-name <name>`.
2. **Snapshot**: `agent-browser snapshot -i` (get refs like `@e1`, `@e2`)
3. **Interact**: Use refs to click, fill, select. Chain with `&&` when output isn't needed between steps.
4. **Re-snapshot**: After navigation or DOM changes, ALWAYS get fresh refs before next interaction
5. **Verify**: `agent-browser screenshot` to confirm the task succeeded
6. **Close**: `agent-browser close` — never leave the browser running

```bash
# Complete example: fill form, verify, close
agent-browser open https://example.com/form
agent-browser wait --load networkidle
agent-browser snapshot -i
# Output: @e1 [input type="email"], @e2 [input type="password"], @e3 [button] "Submit"
agent-browser fill @e1 "user@example.com" && agent-browser fill @e2 "password123"
agent-browser click @e3
agent-browser wait --load networkidle    # Wait after navigation/submit
agent-browser snapshot -i               # Re-snapshot: get fresh refs
agent-browser screenshot                # Verify: evidence of final state
agent-browser close                     # Cleanup: release browser
```

**Waits** — use condition-based waits, never `wait <ms>`:

| After... | Wait with |
|----------|-----------|
| Page open / form submit | `wait --load networkidle` |
| Element should appear | `wait @e1` or `wait "#selector"` |
| Text should appear | `wait --text "Welcome"` |
| URL should change | `wait --url "**/dashboard"` |

**Errors** — every error triggers the same 3-step recovery: (1) re-snapshot, (2) retry with fresh ref, (3) if retry fails, stop and report.

```bash
# Pattern: try → re-snapshot → retry with fresh ref → report
agent-browser click @e3
# If it fails:
agent-browser snapshot -i          # Step 1: get fresh refs
agent-browser click @e5            # Step 2: retry with NEW ref from fresh snapshot
# If retry fails: stop, report error + last snapshot + screenshot to user
```

| Failure | Cause | Recovery |
|---------|-------|----------|
| "Element not found @e3" | Stale ref (DOM changed) | Re-snapshot, find new ref, retry |
| "Timeout waiting for..." | Slow load or element never appears | Check URL is correct, try `wait --load networkidle`, then re-snapshot |
| "Navigation failed" | Bad URL or network error | Verify URL, retry `open` once |
| Click does nothing | Wrong element or JS-driven UI | Re-snapshot with `-C` flag, try alternative ref |

**After one retry fails**: stop and report the error to the user — do not loop. Always include the last snapshot output AND a screenshot so the user can diagnose.

## Quick Reference

```bash
# Navigation
agent-browser open <url>                    # Navigate
agent-browser close                         # Close browser

# Snapshot & Interact
agent-browser snapshot -i                   # Interactive elements with refs
agent-browser snapshot -i -C                # Include cursor-interactive elements
agent-browser click @e1                     # Click element
agent-browser fill @e2 "text"              # Clear and type
agent-browser select @e1 "option"          # Dropdown
agent-browser press Enter                   # Key press
agent-browser scroll down 500              # Scroll

# Wait
agent-browser wait --load networkidle      # Network idle
agent-browser wait @e1                     # Element appears
agent-browser wait --url "**/dashboard"    # URL pattern
agent-browser wait --text "Welcome"        # Text appears

# Capture
agent-browser screenshot                    # Screenshot
agent-browser screenshot --full            # Full page
agent-browser screenshot --annotate        # With numbered element labels

# Info
agent-browser get text @e1                 # Element text
agent-browser get url                      # Current URL
```

See [references/commands.md](references/commands.md) for full command list.

## Authentication

**Default: `--session-name`** — simplest, auto-persists cookies.

```bash
agent-browser --session-name myapp open https://app.example.com/login
# ... fill credentials, submit ...
agent-browser close  # State auto-saved

# Next time: auto-restored
agent-browser --session-name myapp open https://app.example.com/dashboard
```

| Approach | Flag | Best for |
|----------|------|----------|
| Import from user's Chrome | `--auto-connect` | One-off (user already logged in) |
| Persistent profile | `--profile ~/.myapp` | Recurring, keeps full state |
| Auth vault | `auth save/login` | Encrypted credential storage |
| State file | `state save/load` | Manual save/restore |

See [references/authentication.md](references/authentication.md) for details.

## Critical Rules

### Ref Lifecycle

Refs are invalidated on page change. **Always re-snapshot after:**
- Clicking links/buttons that navigate
- Form submissions
- Dynamic content loading (dropdowns, modals)

### Shell Quoting for eval

```bash
# Simple: single quotes OK
agent-browser eval 'document.title'

# Complex: use --stdin (avoids shell escaping issues)
agent-browser eval --stdin <<'EVALEOF'
JSON.stringify(Array.from(document.querySelectorAll("a")).map(a => a.href))
EVALEOF
```

### Annotated Screenshots (Vision Mode)

Use `--annotate` when page has unlabeled icons, canvas/charts, or you need spatial reasoning:

```bash
agent-browser screenshot --annotate
# [1] @e1 button "Submit"  [2] @e2 link "Home"  [3] @e3 textbox "Email"
agent-browser click @e2  # Refs cached from annotated screenshot
```

## Mandatory Cleanup

**Every browser session MUST end with `agent-browser close`.** This is not optional. Before returning any result to the user, verify the browser has been closed. Leaked browser processes consume memory and block future sessions.

## Gotchas

- **Slow pages**: Use `agent-browser wait --load networkidle` after `open`
- **Iframes**: Refs inside iframes work directly — no frame switch needed
- **Concurrent agents**: Use `--session <name>` to isolate sessions
- **Leaked processes**: Always `agent-browser close` when done — even on errors
- **Blocked flows** (auth walls, CAPTCHA): Report to user, don't retry endlessly
- **Content boundaries**: Set `AGENT_BROWSER_CONTENT_BOUNDARIES=1` to mark page-sourced output

## Deep-Dive References

| Reference | When to Use |
|-----------|-------------|
| [commands.md](references/commands.md) | Full command reference |
| [snapshot-refs.md](references/snapshot-refs.md) | Ref lifecycle, troubleshooting |
| [authentication.md](references/authentication.md) | Login flows, OAuth, 2FA |
| [session-management.md](references/session-management.md) | Parallel sessions, state |
| [common-patterns.md](references/common-patterns.md) | Form, data extraction, diff |
| [video-recording.md](references/video-recording.md) | Recording workflows |
| [profiling.md](references/profiling.md) | Performance analysis |
