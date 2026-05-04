# lib/capability-probe.md — Substrate availability check + graceful degradation

> Shared module. Loaded by Layer 1 flow skills (`sprint`, `office-hours`, `boardroom`, `dojo`, `prep`) at startup. Detects missing substrate (gbq, vault, pdctx, AGENTS.md, lib/ files) and either degrades to generic mode or aborts with a missing-deps list. Never silently fails.
>
> Origin: pandastack v1.0 is public, but slim skills assume Panda's substrate exists (gbq / vault / pdctx context / private overlay). Fresh-clone users hit silent degradation. Codex Q6 (2026-05-04 review) flagged this. capability-probe makes the substrate dependency explicit + load-bearing.

## When to load

At the START of every Layer 1 flow skill — before any `gbq` call, before any vault read, before any pdctx context lookup. Atomic check that runs in <500ms.

Specifically:

- `sprint` Stage 0 (dojo loaded inside)
- `office-hours` Stage 1 (load context)
- `boardroom` Stage 0 (load plan + persona-frame)
- `dojo` / `prep` opening
- `gatekeeper` opening (if integrating vault past-case lookup)
- Any retro / brief / curate-feeds run

Skip for atomic skills that have no substrate dependency (`init`, `done`, `freeze`, `careful`, `checkpoint`).

## Probe checks (8 items)

Run all 8 checks. Each returns `ok / missing / broken / unknown`.

```
[1] AGENTS substrate    — `~/.agents/AGENTS.md` exists, readable, non-empty
[2] vault root          — vault path from pdctx context exists, has Inbox/ + knowledge/ subdirs
[3] gbq                 — `gbq --version` returns 0; `gbq smoke "test"` returns ≥1 result OR "no results" (not error)
[4] pdctx               — `pdctx status` returns current context name; not stale
[5] lib/ files          — required lib/ refs for THIS skill exist (read frontmatter `reads:` to determine list)
[6] persona agents      — if skill chains personas, check `~/.claude/agents/{persona}.md` OR `agents/{persona}.md` source exists
[7] cli tools           — domain-specific CLIs (gog, slack, bird, notion, defuddle) only if frontmatter `reads: cli: <name>`
[8] write paths         — directories the skill will write to exist + are writable (Inbox/ / docs/ / Blog/ etc.)
```

Each check has a 500ms timeout. Probe total ≤4s.

## Output protocol

```
== capability-probe (skill: {name}) ==
[1] AGENTS substrate    : ok
[2] vault root          : ok
[3] gbq                 : broken (gbrain doctor --fast returns 90/100 but gbq returns "DB connection failed")
[4] pdctx               : ok (current: personal:developer)
[5] lib/ files          : missing (lib/push-once.md not found)
[6] persona agents      : ok
[7] cli tools           : ok
[8] write paths         : ok

→ degraded: [3, 5]
→ blocked:  [] (none — degrade rather than block)
```

## Action by probe result

| Result | Action |
|---|---|
| All 8 ok | Proceed normally |
| 1-3 degraded, 0 blocked | Proceed in degraded mode (see below) |
| ≥4 degraded OR ≥1 blocked | Abort, print missing list, suggest fix command, exit |

### Degraded mode rules

For each degraded check:

- **gbq broken** → fall back to raw `rg` grep on vault root for the same query terms; mark output `[fallback: rg, no semantic ranking]`
- **lib/ file missing** → load the inline fallback embedded in the skill body (each skill MUST have a 3-line summary of each lib it uses, for fallback) OR proceed with `[lib/X.md missing — using inline fallback]` warning
- **persona agent missing** → use only persona skill if available; if neither present, prompt user "persona X not installed, proceed without?" with N as default
- **cli tool missing** → skip that integration, proceed without; log `[skipped: cli:X not available]`
- **vault path missing** → ABORT (this is structural, can't degrade)
- **AGENTS.md missing** → ABORT (substrate is gone, behavior would drift wildly)

### Abort messages

When aborting, print:

```
== capability-probe ABORT ==
skill {name} requires substrate that is missing:

  [{check-id}] {check-name}: {why missing}

To fix:
  - {fix command 1}
  - {fix command 2}

If you don't intend to fix and want to use a generic version, install gstack
or another fully-bundled skill stack instead. pandastack assumes the substrate
declared in `pandastack/README.md` § "Install".
```

Exit cleanly. Do not partially run.

## Why probe ≠ trust

Probe checks **availability**, not **correctness**. A `gbq smoke "test"` returning empty is "ok" (gbq works, just no match). A `gbq smoke "test"` returning "DB connection failed" is "broken" (gbq is unreachable).

Skills should NOT trust probe results indefinitely. Re-probe at start of every Layer 1 flow run; the substrate state is time-varying (gbrain SIGKILL'd this morning, pdctx context switched, vault path changed).

## Skills' obligation

Every Layer 1 flow skill MUST declare in frontmatter:

```yaml
capability_required:
  - agents.md
  - vault
  - gbq          # mark "optional" if degraded mode is supported
  - pdctx        # mark "optional" if generic context works
  - lib/push-once.md
  - lib/escape-hatch.md
  - lib/persona-frame.md  # if persona-routed
```

`capability-probe` reads this list and runs the matching subset of checks. Items not declared = not probed = potential silent failure (and a lint flag against the skill).

## Anti-patterns

- ❌ Probe runs only on first invocation per session, then cached forever — substrate state changes, re-probe each run
- ❌ Probe failure ignored ("oh well, gbq broken, just continue silently") — defeats the whole point
- ❌ Probe expanded to validate substrate CONTENT ("does AGENTS.md have section Voice?") — that's a separate lint, keep probe to availability
- ❌ Skill tries `gbq` directly without probe ("if it fails I'll catch it") — probe is the single point of truth for substrate, do NOT scatter checks
- ❌ Probe degrade message buried in skill output — must print as opening block so user sees substrate state immediately

## Origin

- codex Q6 (2026-05-04 review of pandastack v1.1 redesign) — public repo dogfood mismatch, slim skills silently fail on fresh clone
- pandastack 2026-05-04 — `lib/capability-probe.md` created to make substrate dependency explicit + load-bearing
- 5/3 gbrain SIGKILL incident — `gbrain doctor --fast` returned 90/100 but gbq itself was broken; probe must run real `gbq smoke query` not just CLI doctor
