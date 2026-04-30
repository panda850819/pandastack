---
name: write-ship
version: 0.1.0
status: draft
origin: manual
description: |
  Close the loop on a Blog/_daily draft → publish. Three-stage pipeline:
  Close (mv + frontmatter + reverse-cite) → Extract (thesis / byproducts / voice)
  → Backflow (route to _index, Inbox, memory). Counterpart to /knowledge-ship
  but for the writing side: makes published articles findable, knowledge graph
  denser, and writing voice self-correcting.
  Trigger: /write-ship <draft-or-slug>, "ship this draft", "publish this post".
tags: [vault, writing, lifecycle, ship]
related_skills: [content-write, knowledge-ship, daily]
---

# /write-ship

Close a writing draft's lifecycle: from `Blog/_daily/<date>.md` (or in-progress draft) → `Blog/Published/<slug>.md`.

Run from vault root. Pass draft path or slug as `$ARGUMENTS`. If empty, ask which draft.

## Scope: vault-only

This skill **never publishes to external platforms**. `Blog/Published/` lives in the vault and is downstream-synced by the website repo (separate concern). Twitter thread output is a draft file in `Inbox/x-drafts/`, never posted. Newsletter sync, RSS push, and any external distribution happens later, manually, through other tools.

Translation: running `/write-ship` is safe at any time. Nothing escapes the vault until you push it yourself.

## Anti-ceremony rule

Default to **Close-only** (Stage 1) unless user opts into full ship, OR Stage 1 detects a Backflow trigger (cites ≥2 knowledge notes / surfaces ≥1 byproduct idea / voice deviation noticed).

Open with one question:

> 「Close-only 還是完整 ship（Close + Extract + Backflow）？」

Default Close-only. Skip on `--full` / `--close-only`.

Extract returning "no new insight" is valid. Don't force outputs.

---

## Stage 1: Close (mechanic)

Always run.

### 1.1 Resolve draft path

```bash
DRAFT="$ARGUMENTS"
[ -z "$DRAFT" ] && echo "需要 draft path 或 slug" && exit 1
# Allow slug → glob: Blog/_daily/*<slug>*.md
[ ! -f "$DRAFT" ] && DRAFT=$(ls Blog/_daily/*${ARGUMENTS}*.md 2>/dev/null | head -1)
[ ! -f "$DRAFT" ] && echo "找不到 draft" && exit 1
```

### 1.2 Confirm slug + frontmatter

Prompt user for:

- `slug` (default: derive from filename, ask to override)
- `distribution` (default: `[blog]`; ask if also `twitter`, `newsletter`)
- `published` (default: today)

Add/update frontmatter on the draft:

```yaml
slug: <slug>
published: <YYYY-MM-DD>
distribution: [blog, ...]
```

### 1.3 Move to Published

```bash
git mv "$DRAFT" "Blog/Published/<slug>.md"
```

Use `git mv` so backlinks-aware tooling tracks the rename. Do NOT change slug after this point — vault rule.

### 1.4 Reverse-cite update

Scan the published article for `[[wiki-link]]` references to `knowledge/` notes. For each cited note, append to its frontmatter:

```yaml
cited_in:
  - <slug> (<YYYY-MM-DD>)
```

This is the bidirectional knowledge-graph link. Without it, knowledge/ notes don't know they earned their keep.

### 1.5 Detect Backflow triggers

Scan and report:

- **Knowledge cites**: count of `[[knowledge/...]]` references (or just `[[note-name]]` matched against `knowledge/`)
- **Byproduct potential**: count `<!-- aside: ... -->` or footnote-marked tangents in draft (a convention you can adopt: when writing, mark tangents with `<!-- aside: -->`; this skill harvests them)
- **Voice flag**: any line that triggered content-write slop detection upstream (if available)

### 1.6 (Optional) Twitter thread draft

(moved before Show & Confirm so it's part of the artifact set the user reviews)

### 1.7 Show & Confirm (gate)

Before stopping or moving to Stage 2, show user **everything that was just written**:

```
=== /write-ship 完成（vault 已更新）===

Close 完成: Blog/Published/<slug>.md
  cited knowledge notes: N
  byproduct asides: M
  voice flags: K
  Backflow triggers detected: [<list>]

== 已寫入 ==
1. Blog/Published/<slug>.md (git mv from <draft path>)
   frontmatter added: slug, published, distribution

2. <cited knowledge note 1> (frontmatter)
   + cited_in:
   +   - <slug> (<date>)
   (repeat for each cited note)

3. Inbox/x-drafts/<slug>.md (NEW, only if distribution includes twitter)
   thread preview (first 3 tweets):
   <show first 3 tweets verbatim>

== 接下來 ==
- 一切已寫入 vault，沒有任何發文 / 推送
- Twitter draft 仍是檔案，未發出
- 你可以直接 review 檔案、編輯、或不做任何事
- 要繼續 Stage 2 (Extract) + Stage 3 (Backflow) 嗎？[y/N]
```

If user says no / stops here, write ship-log entry and exit.

If no Backflow triggers AND user picked Close-only at the start, default to "stop here, show summary, exit". Don't ask the Stage 2 question.

If `distribution` includes `twitter`, generate `Inbox/x-drafts/<slug>.md` with:

- 7-12 tweet thread, each <280 chars
- Hook tweet first
- Tail tweet links back to blog post
- DO NOT post — this is a draft for `/tool-bird` to handle later

---

## Stage 2: Extract (semantic)

Three questions, one at a time. Allow skip.

1. **Thesis 一句話？** (這篇文章的單一主張。如果寫不出一句，文章本身可能還沒收斂)
2. **副產品 idea？** (寫的過程中 surface 出哪些「沒寫進來但值得單獨成 note」的想法。允許列 0-N 個)
3. **Voice / 結構 insight？** (這次寫作有什麼 reusable 的寫法、開頭、過渡、收尾值得記下？或是有發現自己又掉進某個 voice 反 pattern？)

Store for Stage 3.

---

## Stage 3: Backflow (system update)

| 條件 | 動作 | 落點 |
|---|---|---|
| Q1 thesis exists | Add entry to `knowledge/<domain>/_index.md` under "我的觀點" or "Published thesis" section. Format: `- [<title>](Blog/Published/<slug>.md) — <thesis> (<date>)` | `_index.md` |
| Q2 lists byproducts | For each, draft a stub note at `Inbox/<slug>-aside-<n>.md` with the aside content + `source: <published-slug>` frontmatter. Daily-distill picks up next cycle. | `Inbox/` |
| Q3 produces voice rule / structural pattern | Draft addition to `<memory-dir>/project_writing_style.md` (show diff, ask) | memory |
| Q3 flags a slop pattern | Draft addition to `~/.claude/rules/voice.md` "Prohibited" list (show diff, ask) | rules |
| Cited ≥3 different knowledge notes from same `knowledge/<domain>/` | Mark this published post as a "synthesizer" — add to `knowledge/<domain>/_index.md` "Synthesizer posts" section | `_index.md` |

**Rule**: Stage 3 NEVER writes destructively without diff + confirm.

---

## Output

Print summary, append to `Inbox/ship-log/YYYY-MM-DD.md`:

```markdown
## /write-ship <slug> @ HH:MM

- Close: ✓ (mv → Published, frontmatter, cited_in updated on N notes)
- Extract: <empty | thesis + N byproducts + voice insight>
- Backflow:
  - <action> → <落點>
- Triggers: [<list>]
- Knowledge cites: N
- Byproduct stubs created: M
```

---

## Failure modes

| 症狀 | 處理 |
|---|---|
| `Blog/Published/<slug>.md` already exists | Abort. Ask if user wants `<slug>-v2` or to update existing (slug rule = no rename after publish) |
| Draft has no body (just frontmatter) | Abort with "draft empty, write something first" |
| `[[wiki-link]]` target doesn't exist | Warn but don't block. Record in output as "broken link" — wiki-lint will catch it later |
| `git mv` fails (not a git repo or untracked file) | Fall back to `mv`, warn that backlinks tooling may miss the rename |
| Slug collision with existing slug | Append `-2` suffix, ask to confirm |

---

## Future use

Two weeks of `/write-ship` gives you:

1. **Findability**: `qmd query "<topic>"` finds your published posts ranked by your own usage signals
2. **Knowledge graph density**: `cited_in:` reverse links mean every published article enriches the notes it stood on. Wiki-lint stops flagging cited notes as "orphan".
3. **Voice self-correction**: voice / slop patterns auto-feed back into content-write next session
4. **Pipeline visibility**: `Inbox/x-drafts/` accumulates Twitter threads waiting for `/tool-bird`; byproduct stubs accumulate in `Inbox/` for daily-distill
5. **Synthesizer index**: `_index.md` "Synthesizer posts" becomes a curated "best-of" list per domain — useful for newsletter / portfolio / handoff

Ship is not the publish moment. Ship is the moment knowledge graph + voice rules + idea backlog all update at once.
