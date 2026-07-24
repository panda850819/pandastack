#!/usr/bin/env python3
"""Contract checks for the prose-only setup-verbs workflow."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills/engineering/setup-verbs/SKILL.md"
text = SKILL.read_text()


def require(fragment: str, scenario: str) -> None:
    assert fragment in text, f"{scenario}: missing contract fragment {fragment!r}"


# First setup: select the only available agent document, derive GitHub from Git,
# preview the exact edit, and gate the write.
require("If only one document exists, use it and add the block if needed.", "first setup")
require("Exactly one GitHub repository identity across the remotes", "first setup")
require("Show the target file and exact proposed diff.", "first setup")
require("Ask once: `[approve / reject / skip]`.", "first setup")

# Update: preserve the current block and replace or add one setting.
require("Preserve every existing key and\nall surrounding content.", "update")
require("Add or replace exactly one line:", "update")

# Idempotence: a configured repo does not get another heading, setting, or gate.
require("A second run with the same\nstate is a no-op", "idempotence")
require("do not ask for confirmation", "idempotence")
require("Do not create a second\n`## verbs` heading, a duplicate `tracker:` line", "idempotence")

# Ambiguity: do not choose a document, repository identity, or unsupported
# tracker without evidence.
require("If both documents contain a block, stop and ask which is canonical", "ambiguous document")
require("If both documents exist without a block", "ambiguous document")
require("No GitHub remote, or conflicting GitHub repository identities", "ambiguous remote")
require("Do not guess or silently configure another tracker.", "unsupported tracker")
require("An existing tracker other than `github`: surface the conflict and stop.", "tracker conflict")
require("Existing different tracker | Surface the conflict; do not overwrite or guess", "tracker conflict")

# The existing agent document is the sole config surface.
require("`.verbs.toml`", "single config surface")
assert not (ROOT / ".verbs.toml").exists(), "must not introduce .verbs.toml"
assert not (ROOT / "docs/agents").exists(), "must not introduce docs/agents"

print("setup-verbs contract: ok")
