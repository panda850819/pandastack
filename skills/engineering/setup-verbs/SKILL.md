---
name: setup-verbs
description: |
  Configure or repair a repository's Verbs issue-tracker setting. Use when setting up Verbs in a repo, when a tracker-dependent workflow cannot find its tracker, or when the existing `## verbs` block and Git remote may disagree.
reads:
  - repo: AGENTS.md
  - repo: CLAUDE.md
  - repo: .git/config
writes:
  - repo: AGENTS.md
  - repo: CLAUDE.md
forbids:
  - repo: .verbs.toml
domain: shared
classification: tool
user-invocable: true
---

# Setup Verbs

Configure the existing per-repository `## verbs` block for tracker-dependent
Verbs workflows. This initial contract supports GitHub only. Preview one
idempotent edit, ask once, and write only after approval.

## 1. Inspect

Read the Git remotes and any root `AGENTS.md` and `CLAUDE.md`. Select the
configuration surface with these rules:

1. If exactly one document contains `## verbs`, update that document.
2. If only one document exists, use it and add the block if needed.
3. If both documents contain a block, stop and ask which is canonical, even
   when their current blocks match.
4. If both documents exist without a block, stop and ask which is canonical.
5. If neither document exists, stop and ask which one to create.

Determine the tracker from current evidence:

- An existing tracker other than `github`: surface the conflict and stop. Do
  not overwrite it.
- Exactly one GitHub repository identity across the remotes: propose
  `tracker: github`.
- No GitHub remote, or conflicting GitHub repository identities: state the
  ambiguity and stop. Do not guess or silently configure another tracker.

Derive repository identity from the Git remote whenever a later workflow needs
it. Never copy owner or repository fields into the config block.

## 2. Preview and gate

Show the target file and exact proposed diff. Preserve every existing key and
all surrounding content. Add or replace exactly one line:

```yaml
tracker: github
```

Ask once: `[approve / reject / skip]`.

- `approve`: apply only the previewed edit.
- `reject` or `skip`: make no changes and stop.

## 3. Write and verify

After approval, update the selected document in place. Do not create a second
`## verbs` heading, a duplicate `tracker:` line, `.verbs.toml`, or a parallel
agent-configuration document tree.

Re-read the result and prove:

- the selected document has one canonical `## verbs` block and one
  `tracker: github` line;
- all pre-existing keys and surrounding content remain;
- the current Git remote still resolves to one GitHub repository identity.

Report the file path and resulting tracker setting. A second run with the same
state is a no-op: show that no diff is needed and do not ask for confirmation.

## Scenario contract

| Scenario | Required result |
|---|---|
| First setup, one root agent document, one GitHub identity | Preview adding one block or setting; write only after approval |
| Existing block without tracker | Preview adding one setting while preserving every existing key |
| Existing `tracker: github` | No-op; no duplicate and no approval prompt |
| Existing different tracker | Surface the conflict; do not overwrite or guess |
| Ambiguous document or remote identity | Ask for the missing canonical choice; make no change |

Native agent tools can already inspect Git and edit Markdown. This skill's
delta is the shared surface-selection rule, Git-derived identity, idempotence,
ambiguity stop, and preview gate across supported hosts.
