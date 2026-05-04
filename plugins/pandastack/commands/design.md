Run a design-driven development flow for: $ARGUMENTS

Follow this sequence:

1. Run /grill --mode structured to clarify requirements (product agent focus)
2. Use the design agent (read agents/design.md) to:
   - Research existing patterns and DESIGN.md
   - Propose 2-3 design directions
   - Pause for user approval (taste gate — user picks direction)
3. Build the approved design using the eng agent's principles (read agents/eng.md)
4. Run /review
5. Run /qa to verify the UI in a real browser
6. Run /ship
7. If design patterns worth remembering were discovered, run /pandastack:knowledge-ship — Stage 2 Extract + Stage 3 Backflow will write the pattern to docs/learnings/.
