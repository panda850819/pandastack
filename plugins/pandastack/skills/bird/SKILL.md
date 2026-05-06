---
name: bird
aliases: [tool-bird]
description: |
  X/Twitter read/write via bird CLI.

  Trigger on: x.com/twitter.com URL, tweet reference, 推文, /bird.
  Skip when: video transcription needed (use yt-dlp + whisper).
user-invocable: true
---

# bird CLI — X/Twitter

Fast CLI for reading, searching, posting, and browsing X/Twitter. Uses Chrome cookies automatically.

## URL Routing Rule

**Any `x.com/*` or `twitter.com/*` URL → use `bird`, not opencli or playwright.**

## Quick Reference

```bash
# Read
bird read <url-or-id>                    # Read a single tweet
bird read <url> --json                   # JSON output
bird thread <url>                        # Full conversation thread
bird replies <url>                       # List replies to a tweet

# Search
bird search "query" -n 20               # Search tweets
bird search "from:username topic"        # Search specific user's tweets

# Browse
bird home -n 20                          # "For You" feed
bird home --following -n 20              # "Following" feed (chronological)
bird bookmarks -n 20                     # Your bookmarks
bird likes -n 20                         # Your liked tweets
bird mentions -n 10                      # Mentions of you
bird mentions -u someone -n 10           # Mentions of someone else
bird user-tweets <handle> -n 20          # User's timeline
bird news -n 10                          # Trending / AI-curated news
bird news --news-only                    # News tab only
bird lists                               # Your lists
bird list-timeline <list-id-or-url> -n 20 # List timeline

# Write (⚠️ confirm with user before executing)
bird tweet "text"                        # Post a tweet
bird tweet "text" --media image.png      # Post with media (up to 4 images or 1 video)
bird reply <url> "text"                  # Reply to a tweet
bird unbookmark <url>                    # Remove bookmark

# Mute/Unmute (via bird-mute wrapper, ~/.local/bin/bird-mute)
bird-mute mute <username> [username2 ...] # Mute one or more users
bird-mute unmute <username> [...]         # Unmute users
bird-mute mute --delay 1 <usernames>     # Custom delay between requests (default 0.5s)

# Info
bird whoami                              # Current account
bird check                               # Check credentials
```

## Common Flags

| Flag | Description |
|------|-------------|
| `--json` | JSON output (available on most read commands) |
| `--json-full` | JSON with raw API response in `_raw` field |
| `--plain` | Plain text, no emoji, no color |
| `-n, --count N` | Number of results |
| `--all` | Fetch all results (paged) |
| `--max-pages N` | Limit pagination pages |
| `--cursor <str>` | Resume pagination |
| `--media <path>` | Attach media (repeatable, up to 4 images or 1 video) |
| `--alt <text>` | Alt text for media |

## Search Operators

```
bird search "from:username keyword"      # Tweets from specific user
bird search "@username"                  # Mentions of user
bird search "keyword lang:zh"            # Filter by language
bird search "keyword since:2026-01-01"   # Date filter
bird search "keyword min_faves:100"      # Minimum likes
```

## Output Formatting Rules

When displaying tweet results to the user:
1. **Table format** for multi-item results (search, timeline, bookmarks, likes, mentions, lists): `# | 作者 | 內容摘要 | 連結 | 互動`
2. **連結**: `[🔗](url)` — compact clickable icon
3. **Translate English content** to Chinese when displaying to user
4. For single tweet reads: show full content directly, no table needed

Example:
```
| # | 作者 | 內容摘要 | 連結 | ❤️ | 🔄 |
|---|------|---------|------|-----|-----|
| 1 | @user | 推文內容摘要... | [🔗](https://x.com/...) | 42 | 12 |
```

## Error Handling

When `bird read` or other commands fail:
1. Check the error message — common causes: deleted tweet, suspended account, rate limit, network timeout
2. If rate limited (`429`): wait 30 seconds, retry once
3. If tweet deleted/not found: inform user the tweet is unavailable, do not fall back to curl/WebFetch/fxtwitter
4. If network/timeout error: retry once with `BIRD_TIMEOUT_MS=30000 bird read <url>`
5. If persistent failure: report the error clearly, suggest user check the URL manually

**Never fall back to alternative tools (curl, WebFetch, playwright) for X/Twitter URLs.** Bird is the only supported path.

## Write Operation Safety

Before executing any write operation (tweet, reply, mute, unmute):
1. Show the user exactly what will be posted/done
2. Wait for explicit confirmation
3. Warn: automated actions may trigger platform rate limits

## Pagination

For commands supporting `--all` or `--max-pages`:
```bash
bird bookmarks --all --max-pages 5       # Fetch up to 5 pages
bird search "query" --all --max-pages 3  # Search with pagination
```

Use `--cursor` to resume from where you left off (cursor value from previous output).

## Config

- Config file: `~/.config/bird/config.json5`
- Supports: `chromeProfile`, `chromeProfileDir`, `firefoxProfile`, `cookieSource`, `cookieTimeoutMs`, `timeoutMs`, `quoteDepth`
- Env vars: `NO_COLOR`, `BIRD_TIMEOUT_MS`, `BIRD_COOKIE_TIMEOUT_MS`, `BIRD_QUOTE_DEPTH`
