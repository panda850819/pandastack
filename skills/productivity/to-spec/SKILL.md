---
name: to-spec
description: |
  Publish the current discussion and repository evidence as one canonical GitHub Spec Issue. Use when requirements are already established and need a durable specification, or when `grill` routes spec-sized work here. Do not use for requirements discovery or ticket decomposition.
reads:
  - repo: "**"
  - repo: AGENTS.md
  - repo: CLAUDE.md
  - skill: setup-verbs
  - cli: git
  - cli: gh
writes:
  - cli: gh issue create
  - cli: stdout
domain: shared
classification: exec
user-invocable: true
---

# To Spec

Synthesize established intent into one GitHub Spec Issue. Do not restart a
requirements interview. The Issue becomes the only requirements source of
truth; this skill creates no implementation tickets or canonical repository
spec copy.

## 1. Bind the tracker and evidence

Read the root `AGENTS.md` or `CLAUDE.md` and require one unambiguous
`tracker: github` under `## verbs`. If it is absent or conflicts, invoke
`setup-verbs` and stop until configuration is resolved. Derive `owner/repo`
from the Git remote and verify authenticated GitHub access.

Collect confirmed decisions from the current conversation, then inspect only
the repository surfaces needed to use its real vocabulary, constraints, and
test commands. Search open Issues for the same outcome; if a canonical Spec
Issue already exists, return it instead of publishing a duplicate.

Completion: every factual implementation or testing claim is supported by the
conversation or inspected repository; unresolved facts are named in Further
Notes rather than invented.

## 2. Draft the complete Issue

Use the title `[Spec] <outcome>` and exactly these top-level sections:

1. `## Problem`
2. `## Solution`
3. `## User Stories`
4. `## Implementation Decisions`
5. `## Testing Decisions`
6. `## Out of Scope`
7. `## Further Notes`

User Stories cover each affected actor's desired outcome plus material failure
and edge states, using `As a / I want / so that` where it clarifies acceptance.
Implementation Decisions name settled seams and constraints, not speculative
task breakdowns.

Testing Decisions propose the highest practical seam first:

1. existing end-to-end or behavioral contract;
2. existing public boundary or integration test;
3. focused unit or structural contract;
4. a new lower-level harness only when higher seams cannot prove the behavior.

State why each chosen seam proves the requirement and list concrete gaps.
Include this ownership sentence in Further Notes:

> This GitHub Spec Issue is the only requirements source of truth. Do not
> create or maintain a canonical repository spec copy.

Completion: the draft contains every required heading, substantive user
stories, evidenced decisions, explicit exclusions, and no implementation
tickets.

## 3. Confirm the test seams once

Show the complete draft and call out the proposed Testing Decisions. Ask once:
`[publish / reject]`.

- `publish`: publish this exact draft.
- `reject`: create nothing and stop.

Do not ask new discovery questions. Missing information remains explicit in
Further Notes for later resolution.

## 4. Publish and verify

Create exactly one Issue in the GitHub repository derived from Git. Use the
host GitHub capability or authenticated `gh`; do not write a body file inside
the repository. Do not create child Issues, branches, commits, or PRs.

Read the created Issue back and verify its URL, title, all seven headings, and
the ownership sentence. Report the URL and any unresolved Further Notes.
Missing or unreadable evidence means publication is not verified.

Native agents can draft and create Issues. This skill's delta is no-interview
synthesis, evidence-bound decisions, high-to-low test seams, one publication
gate, duplicate prevention, and canonical ownership.
