Run a full sprint for this task: $ARGUMENTS

Follow this sequence, pausing at taste gates for user approval:

1. Run /brief to clarify requirements (skip if user says scope is clear)
2. If the brief mentions UI work, use the design agent (read agents/design.md) to propose a design direction. Pause for user approval before proceeding.
3. If scope is large or risky, use the ceo agent (read agents/ceo.md) for scope review. Pause for user approval.
4. Build the implementation using the eng agent's principles (read agents/eng.md). Track `iteration` counter, starts at 1.
5. Run /review.
5.5. **Verify gate** — parse /review output:
   - Count remaining P0 and P1 findings (exclude entries already marked AUTO-FIX, those are applied).
   - Count `COVERAGE GAP` and `SCOPE DRIFT` entries.
   - If all zero: proceed to step 6.
   - If `iteration` >= 3: stop the sprint with: "Verify gate failed after 3 loops. Manual intervention required: <findings summary>". Do NOT auto-loop further.
   - Otherwise present the findings via the four-option gate (`lib/gate-contract.md`):
     - **approve** → append findings to eng agent context, return to step 4, increment `iteration`.
     - **edit** → user prunes/edits findings list, then approve flow.
     - **reject** → stop the sprint, leave branch as-is.
     - **skip** → proceed to step 6, note the unresolved findings in the final report.
6. If UI changed, run /qa
7. Run /ship
8. If a non-trivial pattern was discovered during this sprint, run /pandastack:knowledge-ship or /pandastack:work-ship — Stage 2 Extract + Stage 3 Backflow will route the learning to docs/learnings/
