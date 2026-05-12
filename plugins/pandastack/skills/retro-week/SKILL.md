---
name: retro-week
description: Interactive weekly retro — read the prep brief, conduct an interview, write the final retro. Triggers on "/retro-week", "weekly retro", "weekly review".
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
user-invocable: true
tags: [retro, weekly, reflection]
related_skills: [retro-month, ship]
source: manual
---

# /retro-week — Interactive Weekly Retro

Multi-phase flow:
- **Phase 1 (Auto-scan)** — run git log, learnings health, daily note highlights; produce a raw scan block
- **Phase 1.5 (Brain synthesis)** — auto-generated thesis / contradictions / gaps from gbrain (skipped if gbrain absent)
- **Phase 1.6 (GC sweep)** — scan past 7d `memory/feedback_*.md` across all `~/.claude/projects/*/memory/`, propose categorical fixes (lint / hook / skill / CLAUDE.md rule). Inspired by Lopopolo OpenAI Garbage Collection Day — convert observed slop into mechanism so it can't recur.
- **Phase 2 (Interview)** — show raw scan + synthesis + GC proposals to user, conduct interview ONE question at a time
- **Phase 3 (Write)** — write final retro to docs/retros/

Run AFTER the cron-driven `personal-weekly-retro` skill has produced a prep brief, OR run standalone (Phase 1 will generate the raw data itself).

---

## Phase 1: Auto-scan (raw data, no interpretation)

Run all commands. Print the raw scan block to user before moving to Phase 2.

### 1a. Git activity — obsidian-vault (past 7 days)

```bash
SINCE="7 days ago"
VAULT="<personal-vault>"
cd "$VAULT" && git log --since="$SINCE" --oneline --no-merges
cd "$VAULT" && git shortlog --since="$SINCE" -sn
```

Also scan additional repos if user has active work there this week:

```bash
# Scan additional active repos. Default scan locations follow Panda's setup
# (~/site/skills/, ~/site/apps/, ~/site/cli/, ~/site/trading/) — adjust to
# your own layout in a private overlay if different.
for d in "$HOME/site/skills/"* "$HOME/site/apps/"* "$HOME/site/cli/"* "$HOME/site/trading/"*; do
  [ -d "$d/.git" ] && echo "--- $d ---" && cd "$d" && git log --since="$SINCE" --oneline --no-merges 2>/dev/null | head -5
done
```

Summarize: total commits across repos, key deliverables by repo name.

### 1b. Learnings health — vault learnings/ dir

```bash
LEARNINGS_DIR="<personal-vault>/docs/learnings"
# Count total
ls "$LEARNINGS_DIR"/*.md 2>/dev/null | wc -l
# Count new this week (created in last 7 days)
find "$LEARNINGS_DIR" -name "*.md" -newer <(date -v-7d +%Y-%m-%d) 2>/dev/null | wc -l
# Check for stale (files not modified in 90+ days)
find "$LEARNINGS_DIR" -name "*.md" -not -newer <(date -v-90d +%Y-%m-%d) 2>/dev/null | wc -l
```

If `$LEARNINGS_DIR` does not exist, note "learnings/ dir not found — skip health check" and continue.

### 1c. Daily note highlights — past 7 days

```bash
DAILY_DIR="<personal-vault>/Blog/_daily"
SINCE_DATE=$(date -v-7d +%Y-%m-%d)
for f in $(ls "$DAILY_DIR"/*.md 2>/dev/null | sort -r | head -7); do
  echo "=== $(basename $f) ===" && grep -E "^##|^- \[x\]|P0|decision|ship" "$f" | head -10
done
```

Capture: action items marked `[x]`, any P0 events, key decisions mentioned.

### 1d. Print raw scan block

Format as:

```
=== WEEK SCAN: $YEAR-W$WEEK_NUM ===

GIT ACTIVITY (past 7 days)
[repo: obsidian-vault]  N commits
[repo: ...]             N commits
Key deliverables: ...

LEARNINGS HEALTH
Total: N | New this week: N | Stale (90d+): N

DAILY NOTE HIGHLIGHTS ($SINCE_DATE → today)
[list of closed action items + P0 events + decisions from daily notes]

===
```

Then say: **"掃完了。要開始 brain synthesis 嗎？"** — wait for user.

---

## Phase 1.5: Brain Synthesis (auto-generated, awaiting user validation)

Skip entirely if `gbrain` CLI is not on PATH. Print `(brain synthesis unavailable: gbrain not installed)` and proceed to Phase 2.

This is the brain looking at itself across 7 days. It is **auto-generated** — Phase 2 interview is where the user accepts / rejects each finding. Never auto-write recommendations from this section.

### 1e. Pull synthesis inputs from gbrain

```bash
SINCE_7D=$(date -v-7d +%Y-%m-%d)

# Salient pages updated this week — input for THESIS
gbrain query "salient pages updated since $SINCE_7D" --limit 30

# Anomalies / contradictions across recent + older pages — input for CONTRADICTIONS
gbrain find_anomalies --window 30d

# Topic distribution this week vs prior baseline — input for KNOWLEDGE GAPS
gbrain get_stats --topic-histogram --window 7d
gbrain get_stats --topic-histogram --window 90d --exclude-recent 7d

# High-salience pages with low typed-link count — input for ONE ACTION
gbrain find_orphans --min-salience 0.7 --window 30d
```

### 1f. Generate 4-block synthesis

Print as:

```
=== BRAIN SYNTHESIS: $YEAR-W$WEEK_NUM (auto · awaiting validation) ===

EMERGING THESIS
你這週在 build 但還沒明講的觀點是: <one sentence — extract from the salient-pages cluster>
證據:
- [[slug-1]] — "<verbatim quote that hints at the thesis>"
- [[slug-2]] — "<verbatim quote that hints at the thesis>"
- [[slug-3]] — "<verbatim quote that hints at the thesis>"

CONTRADICTIONS
<for each anomaly returned by find_anomalies, format as:>
- 新: [[slug-new, $DATE]] — "<quote>"
  舊: [[slug-old, $OLDER_DATE]] — "<quote>"
  衝突點: <one sentence>
  狀態: 待 user 在 Phase 2 決定 (重新想 / retire 舊的 / 兩者各管一段 context)

(If no anomalies surfaced, print: "沒有 surface 矛盾。可能 brain 還在累積、可能你這週都在同一條軌道上。")

KNOWLEDGE GAPS
本週 obsess 的 topic distribution: <topic-A: N pages, topic-B: M pages, ...>
但你 brain 完全沒有: <missing perspective inferred from gap analysis>
建議下週讀方向 (具體，不是書名): <direction>

(Discipline: do not invent specific books/articles. Just direction.)

ONE ACTION
這週最高槓桿一件事 (從 brain 推，不是憑空):
<concrete action grounded in find_orphans + salience output>
槓桿來源: <which slugs / which pattern made this the highest-leverage>

===
```

Then say: **"synthesis 出來了。要繼續看 prep brief 還是直接進 interview？"** — wait for user.

User has 3 options:
- "進 interview" → go to Phase 2 with synthesis as starting questions
- "重來" → re-run Phase 1.5 with different gbrain queries (user can specify focus)
- "skip synthesis" → drop the synthesis block, run plain Phase 2 from raw scan only

---

## Phase 1.6: Garbage Collection Sweep (skill-gap detection)

> Origin: [[brain/media/videos/lopopolo-harness-engineering-talk-personalized|Lopopolo, OpenAI 2026-05]] — "Take every bit of slop we had observed over the course of the week that was making a PR difficult to merge and figure out ways to **categorically eliminate** it from ever happening." Solo-operator translation: every `memory/feedback_*.md` file is evidence that a forcing function did NOT fire. GC mode proposes converting recurring corrections into mechanism (lint / hook / skill / CLAUDE.md rule) so the same correction is not needed again.

**Discipline (load-bearing):** Phase 1.6 only **proposes**. Never auto-write a lint / hook / skill change. Each proposal becomes a discussion item in Phase 2 interview; user decides yes / no / defer.

### 1g. Pull GC inputs

```bash
# Single find walks all ~/.claude/projects/*/memory/ dirs in one pass.
# Use -mtime -7 (BSD-compat). Do NOT use `-newer <(date ...)` because
# process-sub temp files have mtime = NOW, so the test never matches.
# Do NOT capture into a var and re-loop with `for d in $VAR` — zsh and bash
# word-split that expression differently and zsh treats it as one token.

RECENT_FEEDBACK=$(find "$HOME/.claude/projects" -mindepth 3 -maxdepth 3 \
  -path "*/memory/feedback_*.md" -mtime -7 2>/dev/null)

ALL_FEEDBACK=$(find "$HOME/.claude/projects" -mindepth 3 -maxdepth 3 \
  -path "*/memory/feedback_*.md" 2>/dev/null)
```

### 1h. Build GC proposal table

For each file in `RECENT_FEEDBACK`:

1. **Extract `name:` and `description:`** from frontmatter — the rule headline
2. **Extract `Why:` line and `How to apply:` line** from body (per CLAUDE.md feedback memory schema) — the trigger context
3. **Classify trigger surface** by keyword heuristic:

```
filename / body keyword               → propose mechanism
─────────────────────────────────────────────────────────
"file format", "frontmatter", "yaml" → lint (PreToolUse:Write hook)
"voice", "language", "phrasing"      → CLAUDE.md rule line
"workflow", "before X", "after X"    → hook (settings.json)
"never X", "always X" + content       → skill update (anti-pattern table)
"second time", "Nth time"             → already covered by skill-gap rule, leave
                                        (do NOT propose — flag as already-mechanized)
recurring pattern across 3+ files     → propose new skill
```

4. **Cross-check MEMORY.md** — if the feedback is already indexed, mark `indexed:yes` (passive). If body has a `[[wikilink]]` to an existing skill, mark `linked:<skill>` (already partially mechanized).

### 1i. Print GC block

Format:

```
=== GC SWEEP: $YEAR-W$WEEK_NUM (auto · awaiting Phase 2) ===

RECENT CORRECTIONS (past 7d): N files

| feedback file                          | trigger                | propose                                  |
|----------------------------------------|------------------------|------------------------------------------|
| feedback_no-wikilinks-in-h1            | brain page H1 with [[]]| lint: PreToolUse:Write `^# .*\[\[`       |
| feedback_voice-rules                   | voice/phrasing slop    | CLAUDE.md §voice line addition           |
| feedback_xxx                           | ...                    | leave-alone (already linked to [[skill]])|

PATTERN ACROSS FILES
- N feedback files this week mention "<keyword>" → candidate new skill: <name>
  (or: no cross-file pattern detected)

ALREADY-MECHANIZED (no proposal needed)
- <list of files matching "second time" / "Nth time" rule — already covered>

===
```

Empty-week handling:

```
=== GC SWEEP: $YEAR-W$WEEK_NUM ===

RECENT CORRECTIONS (past 7d): 0 files

System stable this week — no new corrections fed back. Either:
  - Forcing functions are working
  - You weren't pushing edge cases
  - You weren't writing down corrections (check: did /done run this week?)

(skipping proposal table)

===
```

Then say: **"GC sweep 完了。Phase 2 會把每個 proposal 變成 yes/no/defer 問題。準備好聊嗎？"** — wait for user.

### 1j. Discipline — what NOT to do here

- ❌ Do NOT write any lint / hook / skill file in Phase 1.6 — proposals only
- ❌ Do NOT propose mechanisms for one-off corrections (single occurrence, no pattern signal) — those stay as memory feedback
- ❌ Do NOT propose duplicating an already-linked mechanism — check `linked:<skill>` first
- ❌ Do NOT silently skip the table when 7d window is empty — print empty-week block so user sees the discipline ran

---

## Phase 2: Interview (conversation, not template)

### Step 2a: Locate the prep brief

```bash
WEEK_NUM=$(date +%V)
YEAR=$(date +%Y)
TODAY=$(date +%Y-%m-%d)
# Cron writes prep to Inbox/cron-reports/$DATE-retro-week-prep.md (most recent Sunday)
PREP=$(ls -t "<personal-vault>/Inbox/cron-reports/"*-retro-week-prep.md 2>/dev/null | head -1)
```

If prep file exists: read and print a compressed summary (Traditional Chinese, max 30 lines):
- Action items closed/open ratio
- Top 3 sessions of the week
- Candidate observations (verbatim from prep)
- Open questions (verbatim from prep)
- Active feedback patterns to cross-check

If prep file missing: use Phase 1 raw scan block as the data source instead. Skip straight to interview using scan observations as starting questions.

End with: **"準備好聊嗎？"** — wait for user.

### Step 2b: Interview flow

Walk through open questions ONE AT A TIME. Don't dump all questions at once.

For each question:
- State the question
- Cite relevant data from scan/prep ("我看到 X，所以想問...")
- Wait for user's actual answer
- Push back if answer is hand-wavy ("具體是哪一個？")
- Capture user's exact words verbatim — don't paraphrase aggressively

For each candidate observation (from prep OR from Phase 1 scan anomalies):
- "我注意到 [observation]。對嗎？還是我看錯了？"
- Wait for user
- If user disagrees: drop, don't argue
- If user agrees: ask "這是個 pattern 還是這週的特殊情況？"

For feedback patterns from feedback-log.md:
- "feedback-log 裡有 [pattern] 從 [date]，這週你覺得有再出現嗎？"
- If yes: increment counter in feedback-log.md
- If user thinks pattern resolved: ask if status should change to `resolved`

### GC proposal review (one pass through Phase 1.6 table)

For each row in the GC sweep proposal table (Phase 1.6):

- Cite: "GC sweep 提了 [feedback file] → propose [mechanism]. 要 action 嗎？"
- Three options: **yes** / **no** / **defer**
  - **yes**: capture as TODO in retro output (Phase 3 GC Decisions section). Do NOT auto-write the lint / hook / skill in this skill — user runs `/sprint` separately for each approved mechanism
  - **no**: capture decision + reason ("這條 feedback 留在 memory 就好，不值得升級成 lint")
  - **defer**: re-surface next week
- If user wants to discuss the underlying feedback (not just yes/no on mechanism), follow them — the slop story matters more than the proposal

If 7d window was empty (no proposals): skip this section entirely, do not invent.

### Obsolete-yourself check (one question, always ask)

Ask exactly once at the end of the interview:

> **「這週有哪件事我還在手動做，但其實該是 skill/agent/cron 的工作？」**

- If user names something: capture verbatim, flag whether it's already a two-strike candidate for `skill-discovery`
- If user says "沒有" / "想不到": accept, don't push. Negative weeks are data.
- Do NOT auto-create skills from the answer — just capture. Two-strike rule still applies.

---

## Phase 3: Write final retro

After interview, write `docs/retros/weekly/$YEAR-W$WEEK_NUM.md`:

```markdown
---
date: $SUNDAY
type: weekly-retro
week: $YEAR-W$WEEK_NUM
range: $MONDAY..$SUNDAY
status: complete
prep_source: $(basename "$PREP")
scan_data: true
---

# Weekly Retro $YEAR-W$WEEK_NUM ($MONDAY → $SUNDAY)

## Git Activity Summary
- [from Phase 1 scan: repos + commit counts + key deliverables]

## Learnings Health
- Total: N | New this week: N | Stale (90d+): N

## Decisions This Week
- [decision] — context, what was chosen, why (from interview)

## Validated Observations
- [observations user agreed with, with their nuance]

## Rejected / Reframed Observations
- [things I surfaced that user pushed back on — useful for next prep]

## Feedback Pattern Status
- [pattern X]: count N → N+1 / status changed to resolved / no recurrence
- (only list patterns discussed in interview)

## Recommendation for Next Week
> One concrete action — from the interview, not invented. Use the user's exact phrasing.

## What I'm Sitting With
> User's open questions or unresolved tensions, in their words.

## Obsolete-yourself Candidate
> The manual work user named that should be a skill/agent/cron. Verbatim. Empty if none this week.

## GC Decisions (Garbage Collection Sweep)
> One row per Phase 1.6 proposal that user approved or rejected.
> Format: `[feedback file] → [mechanism] | decision: yes/no/defer | next: [/sprint topic if yes, reason if no, re-surface date if defer]`
> Empty if 7d window had no recent corrections.
```

Ensure `docs/retros/weekly/` directory exists before writing:

```bash
mkdir -p "<personal-vault>/docs/retros/weekly"
```

### Step 3b: Updates to other files

- Update `feedback-log.md` for any pattern counter changes or status changes (use `Edit` tool, don't rewrite the file)
- Update prep brief frontmatter `status: complete` if prep file exists
- `git add + commit "chore(personal): weekly retro $YEAR-W$WEEK_NUM (interactive)" + push`

---

## Rules

- This is a **conversation**, not a template fill. If the user wants to talk about something not in the prep, follow them.
- Phase 1 data is raw input — don't interpret it before the interview. Let user validate.
- Don't invent observations. Only validate what's in prep/scan, or surface what user says.
- Keep the interview under 15 minutes — if it's running long, ask user "繼續還是先停在這裡？"
- If user says "短版" or "快速版": still run Phase 1 fully, then skip interview, write retro directly from scan + prep with minimal commentary
- **Never auto-write recommendations** — every recommendation must trace to a user statement during interview
