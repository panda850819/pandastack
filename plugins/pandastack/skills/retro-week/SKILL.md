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

Two-phase flow:
- **Phase 1 (Auto-scan)** — run git log, learnings health, daily note highlights; produce a raw scan block
- **Phase 2 (Interview)** — show raw scan to user, conduct interview ONE question at a time
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

Then say: **"掃完了。要開始 interview 嗎？"** — wait for user.

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
