---
name: atomize
description: |
  Distill a docs/learnings/ note into one or more atomic principles in
  docs/learnings/atoms/atoms.jsonl. Interactive: AI proposes candidate
  claims, Panda confirms which to lock and what skill scope they apply to.
  Authorship rule: AI never writes a claim Panda has not ratified.
  Trigger on /atomize, /atomize <path>, /atomize --supersede A-xxx <path>,
  "atomize this learning", "蒸餾這條 learning".
reads:
  - file: docs/learnings/**/*.md
  - file: docs/learnings/atoms/atoms.jsonl
  - file: docs/learnings/atoms/README.md
writes:
  - file: docs/learnings/atoms/atoms.jsonl
  - file: docs/learnings/**/*.md (frontmatter atomized_to only)
forbids:
  - cli: any auto-write to atoms.jsonl without per-claim user confirmation
domain: personal
classification: lifecycle
---

# atomize — distill learnings into atoms

Companion to `pandastack:knowledge-ship`. Where knowledge-ship closes a knowledge note, atomize closes a learning by extracting its declarative principle so skills can load it at runtime.

## Why

`docs/learnings/` accumulates faster than `/retro-week` clears. Free-form markdown is invisible to skills at runtime. atomize converts a learning into one line of JSONL that gets auto-loaded by scoped skills, citable by stable ID. See `docs/learnings/atoms/README.md` for schema and citation contract.

## Authorship rule (calibrated)

Default: **AI proposes 1-3 candidates with a recommendation, decides + writes by default**, asks Panda only when:

1. Source learning has 2+ candidates that conflict philosophically (not just narrow vs wide)
2. A candidate would touch substrate (`~/.agents/AGENTS.md`, `~/.claude/rules/`, vault Authorship Model) directly — not just be loaded by a skill
3. Multiple legit interpretations of the source learning exist and you genuinely don't know which Panda would pick
4. The source learning itself is incomplete / has a hole worth flagging (see `schema-vault-prefix-single-root` 2026-05-04 case — surface the gap, defer locking)

For everything else (narrow technical patterns, well-scoped domain rules, clear strongest candidate): just write. Atoms are guidance loaded into prompts, not runtime gates — they don't directly affect Panda's UX. The cost of an imperfect atom is low (Panda can supersede later); the cost of asking on every learning is high (Panda's attention).

If Panda says "skip this one" or `none`, drop it; do not retry from a different angle.

Origin: 2026-05-04 user feedback — interactive per-claim confirmation was burning Panda's time on detail-level decisions that don't shape current behavior.

## Modes

### Default: `/atomize`

Scan `docs/learnings/` for notes that have no `atomized_to:` frontmatter. Show count by bucket (patterns / pitfalls / architecture). Ask Panda to pick one to start. Then enter Single mode.

### Single: `/atomize <path>`

Atomize one specific learning file.

### Supersede: `/atomize --supersede A-xxx <path>`

A new learning replaces an existing atom. Mark old as `superseded`, write new line, update old line's `superseded_by` field.

## Single-file flow

When invoked with a path (or after Panda picks one in Default mode):

### Step 1: Read

Read the full learning file. Note its slug (filename without .md), date (from frontmatter `created` / filename prefix / git log), bucket (patterns / pitfalls / architecture).

### Step 2: Propose 1-3 candidate claims

Each candidate is one declarative sentence. Strongest first.

**Language rule**: claim 用中文為主，技術名詞（API, schema, validator, GIN, tsvector 等翻成中文會失真的）保留英文。不要逐句中翻英 ABC 風，也不要全英文。Voice 跟 Panda 對話一致。

**Recommendation rule**: after listing candidates, give a one-line recommendation ("我建議鎖 1+2，3 太窄") so Panda has a default to react to instead of starting from blank. Recommendation is your judgment, Panda overrides freely.

Format:

```
Candidate 1（最強）:
  claim: 「<一句中文 declarative，技術詞英文 OK>」
  scope: ["careful", "execute-plan"]
  tags: ["dependency", "supply-chain"]

Candidate 2:
  claim: 「<另一個角度>」
  scope: ["careful"]
  tags: ["dependency"]

我建議：1+2（1 是核心，2 補實作細節）。3 太窄，可考慮放掉。
```

Stop. Wait for Panda.

### Step 3: Panda decides

Panda responds with one of:

- `1` / `1,3` — lock these candidates and write immediately (no second-stage confirm)
- `1, 改 scope=[...]` / `2, 改 claim=...` — lock with inline edit
- `none` — skip this learning entirely (still mark `atomized_to: []` so scan does not re-surface)
- `redo with <hint>` — propose new candidates with hint
- `quit` — exit, no writes

Do NOT re-display a "Lock summary" table after selection. The candidates from Step 2 are the contract; selection means write. Two-stage confirmation with identical content is friction without value.

### Step 4: Compute IDs and write

For each locked atom:

1. Compute id: `A-` + first 4 hex of `sha1(<slug>:<date>)`. If collision exists in atoms.jsonl, append `-2`, `-3` etc.
2. Append one JSONL line with `strength: draft` (Panda promotes to `validated` later via separate flow or manual edit).
3. Edit source learning frontmatter to add `atomized_to: [A-xxx, A-yyy]`. If frontmatter missing, add minimal frontmatter (date, type, atomized_to).

### Step 5: Confirm

Print:

```
Atomized:
  source: docs/learnings/patterns/<slug>.md
  → A-xxx: <claim first 60 chars>...
  → A-yyy: <claim first 60 chars>...

Run again with /atomize to continue queue, or /atomize <path> for next single.
```

Stop. Do not auto-continue to next learning.

## Supersede flow

`/atomize --supersede A-xxx <path>`:

1. Find A-xxx in atoms.jsonl. If missing, error and stop.
2. Read new learning, propose 1 claim that replaces A-xxx (not multiple — supersede is 1:1).
3. Panda confirms claim.
4. Compute new id from new learning slug+date.
5. Edit old line: set `strength: superseded`, add `superseded_by: <new-id>`.
6. Append new line with `strength: validated` (supersede implies confidence).
7. Edit new learning frontmatter `atomized_to: [<new-id>]` and `supersedes: docs/learnings/.../<old-slug>.md`.

## Promotion (draft → validated)

Not part of this skill v0. To promote, Panda manually edits `strength: draft` → `strength: validated` in atoms.jsonl after seeing the atom hold across 2-3 real skill invocations.

Future: `/atomize --promote A-xxx` automates this with a confirm gate.

## What this skill does NOT do

- Does not auto-scan and atomize unattended. Always interactive.
- Does not propose claims for learnings flagged `atomize: skip` in frontmatter.
- Does not edit existing atom claims (only id stable, claim immutable post-lock; use supersede for changes).
- Does not call gbrain or any external service.
- Does not commit to git. Atoms are vault-only artifacts; commit through normal vault flow.

## Failure modes to refuse

- "Atomize all 27 learnings in batch" — refuse. Authorship requires per-claim confirmation. Loop one at a time.
- "Make the claim more general" — only if Panda asks. AI proposing generalization is exactly the slop atomize exists to prevent.
- "Skip the source field, the corpus is small" — refuse. Source is the audit trail; phantom quotes start when source is missing.
- "Atomize this Inbox/feeds/raw/ note" — refuse. Atom corpus is for `docs/learnings/` only (Panda's distilled observations), not raw fetched content.

## Vault paths

Resolved relative to the active vault root (`<vault>` = your personal vault, e.g. set via `PANDASTACK_VAULT` or detected by `pandastack:init`):

- Source learnings: `<vault>/docs/learnings/{patterns,pitfalls,architecture}/`
- Atom corpus: `<vault>/docs/learnings/atoms/atoms.jsonl`
- Schema doc: `<vault>/docs/learnings/atoms/README.md`

## Pre-loaded sample atoms (2026-05-04 v0 ship)

3 draft atoms ship with the corpus from the most recent learnings. Run `/atomize --promote A-2afc` (or manual edit) once Panda confirms each holds:

- `A-2afc` vendor-vs-install (2026-05-04)
- `A-7b3f` coordinator-never-delegate (2026-04-02)
- `A-c78f` skill-symlink-cleanup (2026-03-31)

These are seeded as `strength: draft` — skills will load but cite as hypothesis until Panda promotes.
