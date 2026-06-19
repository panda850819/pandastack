---
date: 2026-06-19
type: brief
source: office-hours
topic: Ticket-gated worktree pipeline：agent「無 issue 不准動 code」結構閘
tags: [brief, office-hours, ticket-gate, worktree, linear, github, agent-guardrail, harness]
---

# Ticket-gated worktree pipeline

## Problem

AI agent 預設 build-first、ticket-after：先寫 code 再補文件。solo 時「還好」，但開發失去**依據** — 沒有「為什麼動這塊」的可追溯來源，無法規模化到團隊。正序應是 idea → doc → develop，開發由 issue 驅動，而非事後補票。要管的對象是 **AI agent**（不是寫給人看的 SOP），所以這是一道 agent 結構閘，不是流程文件。

## Original premise

要一套 ticket-gated 流程：先開 GitHub Issues → 同步 Linear → 依票 worktree 開發，並把「沒票不准動 + worktree-default」寫成 CLAUDE.md/AGENTS.md 強制規則。隱含假設：兩套票（GitHub + Linear）、範圍未定、寫給流程紀律。

## Revised premise (after grill)

1. **執法對象是 AI agent**，不是人。團隊 legibility 是副產品。→ 這是 harness 硬閘，不是人 SOP。premature-structure 疑慮消除（solo 也要這道閘）。
2. **閘只管 code repo**（有 worktree+PR 的）。brain 寫入走 auto-resolve、harness live config 走 careful/4-step，都豁免。理由：brain 是 append-heavy 知識流，逐篇開票會自卡死。
3. **ticket-gate 與 worktree-default 是同一機制**：把閘設在 worktree 邊界 —「沒 issue 號就不能開 code worktree」。一個機制滿足兩個願望。
4. **GitHub vs Linear 不是二選一，按 repo 可見性切**（撞車修正：06-13 `scheduler-wbs-linear` 已鎖 Linear 為唯一 WBS store，三層分工 brain/Linear/scheduler；新 ask 的 GitHub 層只在 public repo 才有理由）。

Premise still load-bearing: **partial** — 原 premise（兩套票 + 人流程 + GitHub-first 預設）作廢；新 premise（agent 結構閘 + repo-visibility 分流 + issue-keyed worktree）成為主軸。但無需重跑 Stage 3：C 在新 premise 下仍是對的，只是 issue 來源由可見性決定。

## Alternatives considered

- A: Convention-only 軟閘（issue 即 doc，靠 CLAUDE.md 規則）— **Reject**（軟閘靠 agent 自律，沒解到「AI 會繞」的根）
- B: 完整 Pocock pipeline + Claude PreToolUse hook 硬攔每筆編輯 — **Defer**（過度建設；hook 只覆蓋 Claude，Codex 裸奔；/to-prd 留作超大工作的升級路徑）
- C: issue-keyed worktree 結構閘（沒 issue 不能開 worktree，branch=issue 自帶可追溯）— **Add（chosen）**

## Chosen approach

**C + repo-visibility 分流。** 把閘設在 worktree 邊界，用 git/PR 機制強制（runtime-agnostic，優於 Claude-only hook）：

- **核心閘**：code repo 的 code 開發只能在 **issue-keyed worktree** 裡發生。沒 issue → 不開 worktree → 無 branch → 無 PR。`main` 不准直接 commit code（補洞規則）。PASS 只開 PR，不 push main（沿用 autonomy-rungs rung-0）。
- **issue 來源按可見性**：
  - **Private repo（pandastack、個人 code）**：Linear-only，是唯一真相源（吃 06-13 既有設計）。branch = `PRO-XX-slug`，scheduler 本來就讀 Linear，零新增層。
  - **Public repo（開源、收外部 issue）**：GitHub Issues 當公開介面，Linear 用原生 GitHub 整合當私下規劃鏡像（Linear↔GitHub auto-link）。branch keyed to GitHub issue。
- **doc 層**：一般工作 doc = issue body；工作大到值得才升級 `/to-prd`（= Defer 的 B，不是現在）。
- **harness 編碼**：行為規則寫 **AGENTS.md**（agnostic substrate，Coding Discipline / Dispatch 層）；Claude 專屬 hook 當 belt-and-suspenders 放 CLAUDE.md。**先 dogfood 再編碼** — 規則驗證過才硬寫進 harness。

Executable plan: docs/plans/ticket-gated-worktree-pipeline.md

## Scope

In:
- issue-keyed worktree 慣例（branch = issue id；無 issue 不開 worktree）
- `main` 不准直接 commit code 的補洞規則
- repo-visibility 分流：private = Linear-only / public = GitHub→Linear 鏡像
- dogfood 票 #1 = pandastack checkpoint 四項 fold-first 補強（argument-hint + 結構化 suggested-skills + reference-don't-duplicate + redaction），走完整 Linear issue → worktree → PR
- 驗證後將規則編碼進 AGENTS.md（careful + 4-step pre-ship check）

Out:
- brain repo 與 harness live config（`~/.agents`、`~/.claude` 的 runtime 檔）— 豁免，各走 auto-resolve / careful
- PreToolUse 逐筆 hook 硬攔（B，defer）
- /to-prd PRD 流（超大工作才升級）
- GitHub Issues 強制用於 private repo（冗餘，砍掉）
- 自主 merge 進 main（autonomy-rungs 已鎖：永久人類 promote）
- scheduler/autonomy 改動（正交，autonomy-rungs PRO-30 另案）

## Next skill (recommended)

```
Shape: N-sequential-sprints
Reasoning: Q2=No — 任務有依賴（dogfood 先於編碼：要先跑一票學到東西，才把規則硬寫進 AGENTS.md），非平行獨立分支。

Recommended skill:
  → /sprint ticket-gated-worktree-pipeline   （逐 task，dogfood T01 先行）

Persona for next skill:
  → eng-lead
  Reason: 主訊號是 code/harness（worktree 慣例、branch guard、AGENTS.md 編碼、checkpoint skill 實作），非 UI/process/strategy。
```

## Gotchas surfaced

- **撞車（已修正）**：06-13 `scheduler-wbs-linear` 鎖 Linear 為唯一 WBS store；新 ask 的「GitHub-first」會在 private repo 多疊冗餘層。修正為 repo-visibility 分流。
- **worktree 做一半**：`coding-agent-autonomy-rungs` reversibility kit 已有 worktree 隔離（✓），本案是把它從「隔離手段」升級為「強制閘」。
- **hook 不可靠**：autonomy-rungs 記了 destructive-guard/SessionStart 是 Claude-only，Codex 從不 wire hooks.json。所以閘走 git/PR 結構強制，非 hook。
- **dogfood 的 repo 屬性**：checkpoint 屬 pandastack（private，走 branch/PR）= code repo，閘適用；別跟改 `~/.claude/CLAUDE.md` live 檔（harness 豁免）搞混。
- **brain autocommit 衝突**：worktree-default 只在 code repo；brain repo 維持 autocommit daemon，不套 worktree。

## Gate Log

- Stage 1 (load context): 掃到 linear-epic-structure + scheduler-wbs-linear + coding-agent-autonomy-rungs 三前案；harness 目前無 worktree 規則（乾淨起點）
- Stage 2 (premise challenge): 4 questions（痛點 / 執法對象 / 範圍 / GitHub-vs-Linear 撞車），0 push-once，escape-hatch 未觸發（答案漸短自然收斂）
- Stage 3 (alternatives): 選 C，A Reject，B Defer
- Stage 4 (premise refresh): partial load-bearing；GitHub-first 撞 06-13 鎖定，修正為 repo-visibility 分流
- Stage 5 (output): 本檔 + plan

## OPEN_QUESTIONS

- AGENTS.md 編碼的確切措辭與放哪一節（Coding Discipline vs Dispatch）→ plan T03 定，過 careful。
- `main` 不准直接 commit code 的強制方式（pre-commit hook vs branch protection vs 純約定）→ dogfood retro 後定。
- public repo 的 Linear↔GitHub 整合具體設定 → 等第一個 active public repo 才做。

## Dogfood retro (T02) — 跑完 PRO-31 / PR #15 後

第一張 dogfood 票(checkpoint 四項補強)走完整 Linear issue → issue-keyed worktree → PR,五個觀察:

1. **issue-keyed worktree 慣例本來就在用**(`pandastack-worktrees/pro-NN-slug` + `feat/pro-NN-slug`,如 pro-16)。→ **保留**:閘不是發明新流程,是把已證明的慣例升級成強制規則,T03 編碼有現成依據。
2. **借來的 spec(argument-hint)是錯的**,Stage 4 review 抓到它違 `SKILL-FRONTMATTER.md`(Claude-command-ism,Codex/Hermes inert)。→ **調整**:從外部 skill 套件(Matt/Addy/Pashov)借 pattern 時,先對 pandastack frontmatter 契約查機制再寫進 spec。這正是「先 dogfood 再編碼」要抓的東西 — 在規則進 AGENTS.md 前先攔下。brain 的 `mattpocock-skills-personalized` 那條建議要補 caveat。
3. **Linear↔GitHub linkback 是手動的**(T05 deferred):PR comment + state transition 都靠手打 API ~5 行。→ **調整**:重估 T05 範圍 — Linear 的 GitHub 整合 private repo 也支援,若 PR 量上來,private 也該 wire,不必只留 public。目前手動可忍。
4. **新 issue 預設落在 `Building` state**(非 Backlog),且 team states 含 `Needs Decision` 硬閘(= 設計裡的 machine-enforced gate,已存在)。→ **保留**,linkback 時直接認這個 state 模型。
5. **閘這輪沒被真正強制** — 我是手動遵守(開 issue、key worktree),沒有東西「擋住」我跳過。→ **核心結論**:dogfood 證明 FLOW 手動可行;讓它從「慣例」變「閘」的是 T03/T04 的編碼+強制。這確認 T03/T04 才是真功夫,且必須走 careful + 4-step。

決定:T03(AGENTS.md 編碼)、T04(Claude 強制)維持 deferred,等 Panda 過目 PR #15 + 本 retro 後才動。`main` 不准直接 commit code 的強制方式(OPEN_QUESTION 2)併入 T04 一起定。
