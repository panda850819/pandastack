---
date: 2026-06-13
type: brief
source: office-hours
topic: WBS store + scheduler 架構：Linear + symphony 藍本 + pandastack executor
tags: [brief, office-hours, scheduler, loop-in-agent, linear]
---

# WBS store + scheduler 架構

## Problem

loop-in-agent 的 scheduler 要從工作分解推導「今天最緊急」並餵 proposal，但 brain 是散文知識、reduce 不出 priority/dependency。需要一個可機讀、可關聯查詢的 WBS store，且不能污染 brain 的知識本質，也不該自己重造一個 issue tracker。

## Original premise

brain 的 `projects/` page 長出可機讀 WBS frontmatter 層（status/priority/blocked_by/needs_human），scheduler 讀 brain。

## Revised premise (after grill)

WBS state 不進 brain。三層分工：
- **brain** = 散文知識 + 輕量 index（記重要資訊/狀態，指向 WBS store）
- **WBS store** = Linear（外部成熟 tracker，已有 MCP，不自架不自造）
- **scheduler** = 抄 symphony 架構（poll tracker → reduce → dispatch），executor 換成 pandastack skills

symphony 與 Linear 是搭配（symphony 用 Linear），不是競品；multica 與 Linear 是競品（multica 自帶 tracker）。

## Alternatives considered

- A: multica（採用整個自架平台：Go+Next.js+Postgres，自帶 board+agent daemon）— **Reject**（平台當主人、換編排世界觀、自架重依賴、custom license、917 open issues）
- B: 自建 SQLite WBS store（抄 multica schema，本機單檔）— **Defer**（只有當需要 100% 本機/離線/state 不出機才回來選）
- C: Linear 當 WBS store（已有 MCP、symphony 是現成藍本、零建置零維護）— **Add（chosen）**

## Chosen approach

C — Linear 當 WBS store。理由：省掉整個「建 store + state machine + UI」那半（本來就要寫的 scheduler 那半跑不掉，但 store 這半 Linear 直接給且成熟）；已有 Linear MCP；symphony `SPEC.md` 幾乎逐字是這個架構的可重實作藍本（poll Linear → reduce → spawn executor per issue），把 codex executor 換成 pandastack skill dispatch 即成立。

接受的 trade-off：WBS state 在 Linear 雲端 + scheduler reduce 要打 API（離線跑不了）；`needs_human` 硬 gate 從 DB constraint 退化成 board convention（用一個 custom workflow state 表達，scheduler 認那個 state 就硬停）。

Executable plan: docs/plans/scheduler-wbs-linear.md

## Scope

In:
- WBS store = Linear（Murmur 當 project；issue tree + sub-issue + priority + blocked-by）
- 對接約定：pandastack 7-phase lifecycle ↔ Linear workflow states；`needs_human` = 一個 custom state/label；`acceptance_criteria` 在 issue description 的約定格式（scheduler 可 parse）
- reduce 邏輯：讀 active issues → 排除 blocked → sort(priority→age) → 輸出「今天最緊急」（抄 symphony §8.2 eligibility + stable sort）
- scheduler 架構參照：symphony tick = reconcile → validate → fetch → filter eligible → stable-sort → dispatch；HITL = state transition；gap = 硬停在 needs_human state（補 symphony/multica 都缺的硬 gate）

Out:
- 真正的 daemon / spawn 執行端（Phase 1）
- 完整 HITL handoff 實作（Phase 2）
- multica / 自建 SQLite（rejected / deferred）
- brain frontmatter WBS schema（原 premise，已推翻）
- 自建 board UI（用 Linear 的）
- aging / starvation guard（symphony 缺，列入 Phase 1 backlog）

## Next skill (recommended)

```
Shape: single-target-iterative（對接約定 + reduce 是一條可迭代的 walking skeleton）
Reasoning: Q1=Yes — 單一目標（讓 scheduler 讀得出 Linear 的今天最緊急），預期迭代

Recommended skill:
  → /sprint scheduler-wbs-linear

Persona: eng-lead
  Reason: 技術執行為主（對接約定 doc + reduce 實作 + Linear API/MCP 讀取）
```

## Gotchas surfaced

- scheduler 讀 Linear 的載體未定（獨立 daemon 用 Linear API key 直打 vs 主 session 內用 claude MCP）— 影響整個執行端設計，但 reduce 邏輯與載體無關，Phase 0 先做 reduce，載體 Phase 1 grill。
- Linear 沒有原生 `needs_human` 欄位 — 用 custom workflow state 表達，scheduler 硬認那個 state 才能達成硬 gate。
- Murmur 的工作分解現在腦子/brain，錄進 Linear 是使用者手動前置，不是 code task。

## Gate Log

- Stage 1: skipped (--quick)
- Stage 2 (premise challenge): 1 question — state 該不該進 brain。答：不該，WBS state 用結構化 store、brain 只做知識+index。premise 翻轉。
- Stage 3 (alternatives): multica(Reject) / SQLite(Defer) / Linear(Add). 使用者中途拋 Linear，alternatives 重構為 store-層 build-vs-adopt。
- Stage 4 (premise refresh): 原 premise(brain schema) 整個被替換為 Linear 三層分工。
- Stage 5: brief saved.

## OPEN_QUESTIONS

- scheduler 載體：獨立 daemon vs 主 session 內 loop（Phase 1 grill）。
- needs_human / acceptance 的 Linear 具體表達（state 名、description 格式）→ plan T01 定。
- aging/starvation guard 是否 Phase 1 就要（symphony 缺，低優先級可能餓死）。
