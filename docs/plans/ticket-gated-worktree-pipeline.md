---
slug: ticket-gated-worktree-pipeline
date: 2026-06-19
type: plan
source: office-hours
brief: docs/briefs/2026-06-19-ticket-gated-worktree-pipeline.md
execution: code
status: todo
---

# Ticket-gated worktree pipeline — executable plan

> WHAT only. WHY 在 brief。dogfood 先於編碼：先用一張真票跑完流程學到東西，再把驗證過的規則硬寫進 AGENTS.md。per-task status 由 git 推導，勿手改。

## Tasks

### twp-T01 — Dogfood 票 #1：checkpoint 四項補強，走完整 Linear→worktree→PR
- scope: 在 pandastack（private）開 Linear issue；`git worktree add` branch=`PRO-XX-checkpoint-foldfirst`；在該 worktree 改 `plugins/pandastack/skills/checkpoint/SKILL.md`；開 PR 連 issue
- 補強內容（四項全做）:
  - `argument-hint`：checkpoint 收參數「下個 session 要做什麼」
  - 結構化 suggested-skills 段：取代現行 1-line Resume Hint，明列 resume agent 該叫的 skill
  - reference-don't-duplicate：引用 brain 頁/commit hash/sprint 檔路徑，不重抄
  - redaction 行：明文禁輸出 API key/密碼/PII
- acceptance: checkpoint/SKILL.md 的 Detect Command 收 optional focus arg（`grep -E "next-session focus" plugins/pandastack/skills/checkpoint/SKILL.md` 命中）AND SKILL.md 含 suggested-skills 段 + reference-don't-duplicate 句 + redaction 句（三項可 grep）AND PR 描述含 issue 連結 AND branch 名含 issue id
- amended(twp-T02 finding, 2026-06-19): 原 acceptance 寫死「grep argument-hint」= 把借自 Matt 的 Claude-command-ism 當驗收；Stage 4 review 證實它違 pandastack runtime-agnostic frontmatter 契約（SKILL-FRONTMATTER.md），故移除 frontmatter argument-hint、改驗「Detect Command 收 focus arg」（意圖未變，機制改對）。Panda approved.
- depends-on: none
- status: todo

### twp-T02 — Dogfood retro：記錄流程哪裡卡、要調什麼
- scope: dogfood 跑完後，把摩擦點（worktree 開法、issue↔branch 命名、main commit 怎麼擋、哪步多餘）寫成短 retro
- acceptance: brief 末尾新增 `## Dogfood retro (T02)` 段，至少列 3 條觀察 + 每條一個「保留/調整/砍」決定
- depends-on: twp-T01
- status: todo

### twp-T03 — 把驗證過的規則編碼進 AGENTS.md（agnostic 行為契約）
- scope: 在 `~/.agents/AGENTS.md` Coding Discipline 或 Dispatch 節加規則：code repo 的 code 開發只在 issue-keyed worktree；無 issue 不開 worktree；main 不直接 commit code；private=Linear-only / public=GitHub→Linear。**走 careful + 4-step pre-ship check（goal/integrity/prereq/reversibility）**
- acceptance: `grep -iE "issue-keyed worktree|無 issue 不|issue.*worktree" ~/.agents/AGENTS.md` 命中 AND 版本號 bump + `_changelog.md` 新增一筆
- depends-on: twp-T02
- status: todo

### twp-T04 — Claude 專屬 belt-and-suspenders 強制（CLAUDE.md + 可選 hook）
- scope: `~/.claude/CLAUDE.md` 加 Claude-delta：引用 T03 規則 + 可選 PreToolUse/pre-commit hook 擋「code repo main 上的直接 code 編輯」。**走 careful**
- acceptance: `grep -iE "issue-keyed worktree|ticket-gate" ~/.claude/CLAUDE.md` 命中 AND（若做 hook）hook 檔存在且 settings.json 有 wire
- depends-on: twp-T03
- status: todo

### twp-T05 — [DEFER] public repo 的 Linear↔GitHub 原生整合
- scope: 等第一個 active public repo 出現時，啟用 Linear 的 GitHub 整合（PR 連結 + 自動狀態），單向 GitHub issue → Linear 鏡像
- acceptance: Linear GitHub integration enabled（手動驗證）AND 一個測試 GitHub issue 出現在 Linear
- depends-on: none（獨立，等觸發條件）
- status: deferred
