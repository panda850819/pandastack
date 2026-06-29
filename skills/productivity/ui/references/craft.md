# UI craft (the lore the model cannot derive)

Specific numbers, names, stacks, bans. Read before writing CSS, not after.

## Type — fonts

**Reflex-font blocklist** — refuse as a *display* face; these are the model's training-default and signal
"no decision was made": Inter, DM Sans, DM Serif Display/Text, Outfit, Plus Jakarta Sans, Instrument
Sans/Serif, Space Grotesk, Space Mono, IBM Plex Sans/Serif/Mono, Syne, Fraunces, Newsreader, Lora,
Crimson Pro/Text, Playfair Display, Cormorant, Cormorant Garamond. Carve-out: informed product-UI use is
fine (e.g. Inter for a dense data table) when justified.
**Pick from a named foundry:** Klim, Commercial Type, Colophon, Grilli Type, OH no Type, Village — or an
open-source face with a personality you can defend in one sentence.

**CJK + Latin** (Latin-only type rules silently break Chinese):
- Latin first, system CJK after: `font-family: -apple-system, "SF Pro Text", "PingFang SC", "Noto Sans SC", sans-serif;`
- Line-height: CJK body **1.7–1.8**, Latin **1.4–1.5**. Not one value for both.
- Tag runs `lang="zh"/"ja"/"en"` so the browser picks font + line-breaking.
- Serif mode needs an explicit CJK serif fallback or it drops to sans: `"Newsreader", "Songti SC", "Noto Serif SC", serif`.
- **Never negative letter-spacing on CJK runs** — it cramps Hanzi, reads as a bug. Scope tracking to `lang="en"`.

**Latin display letter-spacing** (Latin only): `~-0.022em` ≥32px, `~-0.012em` 20–28px, normal ≤16px.
Positive tracking on large headlines is always wrong.
**text-wrap:** `balance` on headings/short (≤6 lines Chromium, ≤10 Firefox); `pretty` on body; default on code.
**Font smoothing (macOS, once at root):** `-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale;`
**Numbers:** `font-variant-numeric: tabular-nums` for counters, timers, prices, number columns.
**Widow:** flag a block whose last line is under **~13%** of its widest line. Fix by trimming copy, NOT a
`max-width` cap. Nested `<code>` hides widows from greps — verify on render.

## Color (OKLCH magnitudes)

- Reduce chroma near lightness extremes: at 85% L chroma **~0.08** (0.15 garish); tighten near 15% too.
- Tint neutral grays toward the brand hue, chroma **0.005–0.01**, so neutrals aren't dead-flat.
- **Never gray text on a colored background** — use the background hue at reduced lightness.

**Surface hierarchy** (depth via lightness steps, not drop shadows):
- Light: adjacent nested surfaces need ≥**4% lightness step** OR shadow ≥`0 1px 3px rgba(0,0,0,0.10)`. A
  white card on near-white with `0 1px 2px rgba(0,0,0,0.05)` is invisible noise.
- Dark: canvas `#08090a`; elevation via white overlays — cards `rgba(255,255,255,0.02)`, elevated `0.04`,
  prominent `0.05`; borders `0.05` subtle / `0.08` standard. Dark drop-shadows are invisible; step luminance.

## CSS bans — each with the rewrite

Left = the model's default; right = instead.
1. `border-left/right` > 1px section accent → colored dot, short hr, bg swatch, or weight shift.
2. `background-clip: text` gradient text → solid color or weight (illegible in high-contrast mode).
3. `backdrop-filter: blur` glassmorphism default card → background-color steps + `box-shadow`.
4. Purple→blue gradients / cyan-on-dark → derive palette from brand words via OKLCH.
5. Rounded-rect + `box-shadow` card as default container → **cardless by default**; card only when content needs it.
6. `transition: all` / animating width/height/padding/margin → list exact props; height reveal via `grid-template-rows: 0fr → 1fr`.
7. Modal as overflow escape → inline expand / detail panel / route. Modal only for true focus-lock (it breaks browser back-nav).

Two silent bugs:
- **Mobile sticky hover:** wrap hover in `@media (hover: hover)` (`[@media(hover:hover)]:hover:...`), else a tapped element stays hovered.
- **Tailwind v4 `@theme` + dynamic class names purge:** names built from variables get JIT-purged, styles vanish silently. Use static class names / `safelist` / `:root` + `extend.colors`.

## Motion

No bounce/elastic. Exponential ease-out: `cubic-bezier(0.16, 1, 0.3, 1)` (or ease-out-quart/quint). Animate
`transform`/`opacity` only. Icon swap: 120ms opacity cross-fade + `scale(0.9→1)`, no rotation unless
semantic. Stagger enter: `opacity 0→1`, `translateY(12px→0)`, `blur(4px→0)`; ~100ms between chunks, ~80ms
between title words. Exit: `translateY(-12px)`, ~150ms ease-in. Press: `scale(0.96)` on `:active`. App-shell:
`active:scale-95` on all interactive elements. Framer: `initial={false}` on `AnimatePresence` for toggles/tabs/icon-swaps.

## Spacing and radius

- **Stop tuning magic values after 3 adjustments** — the bug is structural, not numeric. Collapse N
  independent padding/gap/margin values into one named token; reduce the count before arguing the value.
- Outer container padding defaults to equal the inner element gap.
- Concentric radius: `outer = inner + padding`. If padding > **24px**, treat layers as separate surfaces.
- Section padding need not be symmetric: optical balance often wants bottom **20–25% larger** than top.
  Body measure ~**65ch**.
- **Fixed-height state slot** (status bar, action slot, toolbar, menu item): one font size across states —
  a 1pt delta (13px vs 14px) jitters layout on state change. Vary fill/stroke/opacity/color/icon, never size.
- Image depth without layout shift: `outline: 1px solid rgba(0,0,0,0.1); outline-offset: -1px;` (light) /
  `rgba(255,255,255,0.1)` (dark). `outline`, not `border`.

## Product completeness (the layer a visual pass skips)

**Strategic omissions** — ship-blockers a happy-path build drops: custom branded 404 with a path back;
back-nav on every page; form validation with inline errors adjacent to each field; skip-to-content link as
the FIRST focusable element (`<a href="#main-content">Skip to main content</a>`, visually-hidden); cookie
consent (EU/California); footer Privacy + Terms.

**Default-trap checklist** — these appear only if intentional: purple/blue gradient hero over white;
three-part hero (headline + subtext + two side-by-side CTAs); card grid with identical corners/shadows/
padding; top nav logo-left/links-center/action-right; sections alternating white and `#f9f9f9`; centered
icon-over-heading-over-paragraph; four-column equal footer. Test: swap in different content; if the layout
still works unchanged, it's a template, not a design.

**Content authenticity:** sample names not John Doe/Jane Smith → Priya Mehta, Lars Eriksson, Nia Okafor;
companies not Acme/TechCorp/Initech → Meridian Logistics, Hokkaido Ceramics, Vantage Bioworks; no round
numbers (99.99%/$100.00 → 99.94%/$99.00); sentence case all headings (Title Case is the top AI tell); strip
`!` from success (`Saved!`→`Saved`); never `Oops!`; "Something went wrong" → "We couldn't load your data.
Try refreshing."; banned marketing words Elevate/Seamless/Unleash/Delve/Tapestry/Game-changer/Next-Gen.
Missing asset → labeled placeholder (grey rect / monogram / dashed border); never draw imagery as inline SVG.

**Completion screens:** show the one result (reclaimed size / processed count) on the primary line, detail in
an overlay from the summary row; no redundant Review button, no "0 skipped", hide the affordance when nothing
was skipped/failed.

**Destructive surfaces:** batch / one-tap is OK only when each row is independently verifiable (name, source,
owner, path, preview, recovery). Opaque rows → review-first / scoped / disabled. Fewer clicks ≠ remove verify.

**Redesign priority order** (existing UI): font → color cleanup → hover/active states → layout/whitespace →
replace generic components → loading/empty/error states → typographic polish.

**Direction-lock from a reference:** cited product → 3 properties (radius philosophy / depth = shadow vs
bg-step vs border / accent family), name those not the brand. Recreate from a repo → read the token files
(`theme.ts`, `colors.ts`, `tokens.css`, `_variables.scss`), lift exact values; attach only the target folder.
Source + screenshot both → read the code. URL only → fetch returns stripped text; ask for a screenshot.

**Render-verification matrix:** screenshot at **375px** (320px for buttons) and **1280px**, in **every shipped
locale**. Source-invisible regressions: early wraps, orphaned separator dots, table overflow, widows.

**App-shell** (sidebar + main): decorative backgrounds OFF; hierarchy via background-color steps + shadow
only; commit a named radius scale before the first component; utility mode (orient / show status / enable
action), no marketing hero.
