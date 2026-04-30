---
name: tool-summarize
description: Summarize/transcribe URLs, YouTube, podcasts, files. Trigger on "summarize", "transcribe", "TL;DR".
homepage: https://summarize.sh
version: "1.0.0"
metadata:
  {
    "openclaw":
      {
        "emoji": "🧾",
        "requires": { "bins": ["summarize"] },
        "install":
          [
            {
              "id": "brew",
              "kind": "brew",
              "formula": "steipete/tap/summarize",
              "bins": ["summarize"],
              "label": "Install summarize (brew)",
            },
          ],
      },
  }
user-invocable: true
---

# Summarize

Fast CLI to summarize URLs, local files, and YouTube links.

## When to use (trigger phrases)

Use this skill immediately when the user asks any of:

- “use summarize.sh”
- “what’s this link/video about?”
- “summarize this URL/article”
- “transcribe this YouTube/video” (best-effort transcript extraction; no `yt-dlp` needed)

## Quick start

```bash
summarize "https://example.com" --model google/gemini-3-flash-preview
summarize "/path/to/file.pdf" --model google/gemini-3-flash-preview
summarize "https://youtu.be/dQw4w9WgXcQ" --youtube auto
```

## YouTube: summary vs transcript

Best-effort transcript (URLs only):

```bash
summarize "https://youtu.be/dQw4w9WgXcQ" --youtube auto --extract-only
```

If the user asked for a transcript but it’s huge, return a tight summary first, then ask which section/time range to expand.

## Model + keys

Set the API key for your chosen provider:

- OpenAI: `OPENAI_API_KEY`
- Anthropic: `ANTHROPIC_API_KEY`
- xAI: `XAI_API_KEY`
- Google: `GEMINI_API_KEY` (aliases: `GOOGLE_GENERATIVE_AI_API_KEY`, `GOOGLE_API_KEY`)

Default model is `google/gemini-3-flash-preview` if none is set.

## Useful flags

- `--length short|medium|long|xl|xxl|<chars>`
- `--max-output-tokens <count>`
- `--extract-only` (URLs only)
- `--json` (machine readable)
- `--firecrawl auto|off|always` (fallback extraction)
- `--youtube auto` (Apify fallback if `APIFY_API_TOKEN` set)

## Fallback strategy

If `summarize` returns empty, truncated, or "could not extract" output:

1. **Retry with `--firecrawl always`** — works for paywalled, Cloudflare-blocked, and JS-heavy sites
2. If firecrawl also fails, fall back to `defuddle parse <url> --md` or WebFetch, then pass content to the LLM yourself

Always add `--firecrawl auto` proactively for known paywall domains (nytimes, wsj, bloomberg, ft, etc.).

## Model provider format

When the user requests a specific provider, use the format `provider/model-name`:

```bash
summarize <url> --model openai/gpt-5.2
summarize <url> --model anthropic/claude-sonnet-4
summarize <url> --model google/gemini-3-flash-preview  # default
```

## Execution Rules

1. **Match user length requests**: When the user asks for a short/brief/detailed summary, map to `--length short|medium|long|xl|xxl` accordingly. Always include the flag when length preference is stated or implied.
2. **Never expose API keys**: Reference keys by env var name (`$GEMINI_API_KEY`, `$OPENAI_API_KEY`, etc.) in commands. Never print, echo, or hardcode actual key values.
3. **Summarize before dumping**: For large transcripts or long content, return a concise summary first. Offer to expand specific sections or time ranges — never dump raw multi-page output unprompted.
4. **Quote all file paths**: Always wrap local file paths in double quotes in the command: `summarize "/path/to/my file.pdf"`. This prevents breakage on paths with spaces or special characters.
5. **Clean output by default**: Present the summary as readable text (markdown). Do not include raw CLI JSON, metadata, or wrapper output unless the user explicitly requested `--json`.

## Config

Optional config file: `~/.summarize/config.json`

```json
{ "model": "openai/gpt-5.2" }
```

Optional services:

- `FIRECRAWL_API_KEY` for blocked sites
- `APIFY_API_TOKEN` for YouTube fallback
