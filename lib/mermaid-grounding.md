# Mermaid / flow-diagram source-grounding

> Reflex for any skill that emits a Mermaid or flow diagram (repo docs, architecture explainers). A wired diagram asserts relationships; those relationships must be grounded in source you actually read, never inferred from names. Migrated from the retired `deepwiki` skill; the lint backstop already lives at `lib/lint-mermaid-grounding.sh`.

## Source Reading Rule

Before describing a module or drawing an architecture diagram, read at least 2 actual source files (entry points: `src/index.ts`, `src/main.py`, `contracts/*.sol`, `app/page.tsx`, etc.) — not just README and config. Module descriptions and diagrams must be grounded in source you read, not inferred from file names alone.

## Source-grounding guard (hard rule)

A wired diagram with directional edges (`A --> B`, `A -->|calls| B`) asserts relationships. Those edges MUST be grounded in source you actually read (imports/calls), never inferred from file names or READMEs. If you have NOT read/verified the source, do NOT draw any wired diagram with directional edges. **A caveat is not enough** — caveating a fabricated structure still asserts unverified relationships. Allowed instead: (a) prose-only description of the components, or (b) an explicit "insufficient source to diagram architecture" note in place of the diagram.

**A directory tree, file listing, or set of folder/file names is NOT source** — it grounds edges no more than a clone failure does. If all you have is names/structure (no actually-read import/call statements), you are in the unread case: no edged diagram (caveated or not), and no second "likely flow" / "canonical pipeline order" block that smuggles the same arrows back in. Inferring `ingest --> transform --> sink` from folder names is exactly the forbidden move.

## Self-check (code gate, not honor system)

After writing any doc with a mermaid/flow diagram, run `lib/lint-mermaid-grounding.sh <output-file>`. Exit 2 = directional edges without a source citation, or a canonical/likely-layout block smuggling edges back in. On fail, replace the edged diagram with an edgeless inventory or an "insufficient source" note and re-run until exit 0. (Two prose re-fixes leaked before the lint was added; the lint is the backstop, not the honor system.)
