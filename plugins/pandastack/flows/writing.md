---
name: writing-flow
description: Lifecycle for drafting, refining, and shipping a blog post, thread, or newsletter from raw capture to published artifact.
type: lifecycle-flow
---

# Writing Flow

> Triggered when a piece of writing moves beyond a raw capture and needs to become a publishable artifact — a blog post in `Blog/Published/`, a thread draft in `Inbox/x-drafts/`, or a newsletter section. The flow enforces slop detection (3-layer check is mandatory), preserves reverse-citations so the knowledge graph stays connected, and routes extracted byproducts back into the vault. Publishing to external platforms (X, Substack, etc.) is always a manual step; this flow prepares the material, never pushes it.

## Trigger

- A `Blog/_daily/` section has grown into a full draft worth publishing
- User says "let's turn this into a post" or "write a thread on X"
- A `Blog/_drafts/` file has been sitting with `status: draft` for more than a week

## Phases

### Phase 1 — Capture (raw draft)

- **What happens**: The initial rough draft lands in `Blog/_daily/` as a section or stand-alone entry. No structure imposed. Write the core idea in one continuous pass.
- **Skills used**: `pandastack:daily` (append to today's note); direct file creation in `Blog/_drafts/` for longer pieces that won't fit inline
- **Output**: Raw draft with no frontmatter requirements, no headings forced, no word count target

### Phase 2 — Structure + slop detection

- **What happens**: Run the draft through the 3-layer slop detection check. Layer 1: first-principles signal (does the core claim hold up?). Layer 2: voice consistency (would Panda say this out loud to a colleague?). Layer 3: hedging and filler audit (banned phrases, em dash, sycophantic openers). Restructure headings and paragraph order after the check, not before.
- **Skills used**: `pandastack:content-write` (structure coach + slop detection mode)
- **Output**: Annotated draft with slop flags cleared and structure skeleton confirmed

### Phase 3 — Full draft

- **What happens**: Expand the structured skeleton into a complete draft. This is the main writing pass. Stay in `Blog/_drafts/` or daily note — do not move to `Blog/Published/` yet.
- **Skills used**: `pandastack:content-write` (drafting and voice-aware editing mode); `pandastack:grill` (optional — adversarial mode to stress-test the central argument before committing)
- **Output**: Complete draft at intended word count, saved in `Blog/_drafts/<slug>.md` or daily note section

### Phase 4 — Ship

- **What happens**: Move the draft to its permanent published location, set frontmatter, add reverse-citations to any `knowledge/` notes the post references, and route extracted byproducts (thesis statement, sub-arguments, voice patterns, new knowledge fragments) back into the vault.
- **Skills used**: `pandastack:write-ship` (Close: mv + frontmatter + reverse-cite; Extract: thesis / byproducts / voice; Backflow: route to `_index`, `Inbox/`, memory)
- **Output**: File at `Blog/Published/<slug>.md` with complete frontmatter; reverse-citations updated in referenced knowledge notes; ship log entry

### Phase 5 — Distribute (manual)

- **What happens**: Thread drafts accumulate in `Inbox/x-drafts/`. Long-form pieces accumulate in a newsletter staging area. Human pushes to X, Substack, or other platforms when ready. No automation here.
- **Skills used**: `pandastack:tool-bird` (when manually posting threads to X); direct platform UI for newsletter
- **Output**: Published URL, recorded back in the Blog/Published frontmatter as `published_url:`

## Exit criteria

- File exists at `Blog/Published/<slug>.md` with complete frontmatter including `date` and `tags`
- Reverse-citations written back to all referenced `knowledge/` notes
- Byproducts extracted: thesis noted in ship log, any new fragments routed to `Inbox/` for next distill cycle
- If a thread was planned: draft exists in `Inbox/x-drafts/` (not auto-pushed)

## Anti-patterns

- **Skip slop detection**: the 3-layer check is mandatory. Publishing without it produces content that sounds like a press release or a hedge-stacked memo. Run `pandastack:content-write` before moving to full draft.
- **Change slug after publishing**: `Blog/Published/` slugs are permanent. The website repo symlinks to them and search indexes the URL. Use a redirect if you must rename.
- **Auto-push threads directly to X without a draft in `Inbox/x-drafts/`**: always leave a local draft. External publish is a one-way door — you cannot un-send a thread.
- **Write the full draft before running structure check**: you will write 600 words of prose that needs to be reordered. Skeleton first, prose second.
- **Treat every post as a standalone artifact**: every post should cite at least one `knowledge/` note it draws from, and those notes should get reverse-citations. Writing that doesn't feed the knowledge graph is entropy.

## Skill choreography

```
pandastack:daily  (capture to _daily/ or _drafts/)
  |
  v
pandastack:content-write  (structure coach + slop detection)
  |
  v
pandastack:content-write  (full draft + voice editing)
[optional: pandastack:grill --adversarial to stress-test argument]
  |
  v
pandastack:write-ship
  |── Stage 1: Close (mv to Published/, frontmatter, reverse-cite)
  |── Stage 2: Extract (thesis, byproducts, voice pattern)
  └── Stage 3: Backflow (_index, Inbox/, memory)
  |
  v
pandastack:tool-bird  (manual X post, when ready)
```
