#!/usr/bin/env python3
"""Contract checks for the tracker-native planning lifecycle."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
GRILL = (ROOT / "skills/productivity/grill/SKILL.md").read_text()
README = (ROOT / "README.md").read_text()
RESOLVER = (ROOT / "RESOLVER.md").read_text()
DISPATCH = (ROOT / "DISPATCH.md").read_text()
MANIFEST = (ROOT / "manifest.toml").read_text()


def require(text: str, fragment: str, scenario: str) -> None:
    assert fragment in text, f"{scenario}: missing contract fragment {fragment!r}"


def require_words(text: str, fragment: str, scenario: str) -> None:
    require(" ".join(text.split()), " ".join(fragment.split()), scenario)


require(GRILL, "require two or more implementation Issues", "spec threshold")
require(GRILL, "even one PR changes a\n   public contract, schema or migration, or security boundary", "spec threshold")
require(GRILL, "Do not write a competing repository brief, executable plan", "single source")
require(GRILL, "**Smaller work -> local close.** Continue to Stage C", "small-work branch")
require(GRILL, "**Large and foggy -> Wayfinder.**", "wayfinder branch")

require(README, "to-spec --> canonical GitHub Spec Issue", "public lifecycle")
require(README, "to-tickets --> child Issue graph", "public lifecycle")
require(README, "manually selected", "manual frontier")
require_words(README, "grill -> to-spec -> to-tickets -> manually selected frontier Issue -> sprint -> review -> ship", "public lifecycle")
require_words(README, "one independently reviewable and revertible PR", "one issue one PR")

require(RESOLVER, "A human selects one unblocked implementation Issue.", "ownership")
require(RESOLVER, "reports the frontier but does not choose work", "ownership")
require(DISPATCH, "never schedules or claims the next frontier", "non-scheduling sprint")
require(DISPATCH, "canonical GitHub Spec Issue / to spec", "spec dispatch")
require(DISPATCH, "dependency graph / to tickets", "ticket dispatch")

assert "[skill.implement]" not in MANIFEST, "must not add implement"
assert "[skill.to-prd]" not in MANIFEST, "must not add to-prd"
assert "structured brief by default" not in DISPATCH, "dispatch must expose conditional close"

print("planning lifecycle contract: ok")
