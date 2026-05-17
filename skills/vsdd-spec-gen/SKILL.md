---
name: vsdd-spec-gen
description: Conduct the VSDD human-agent specification interview and create or update SPEC.yaml. Use when a repo lacks approved VSDD claims, when claims need revision, when product intent is ambiguous, or when the user wants capabilities, invariants, constraints, assumptions, and non-functional expectations compressed into a small human-reviewable claim set.
---

# VSDD Spec Generation

Create or revise `SPEC.yaml`. This is the most human-led VSDD phase; claims should emerge from planning conversation, not mechanical generation.

## Workflow

1. Read `CONTEXT.md` as the context map if present, plus any existing `SPEC.yaml`.
2. Interview the user for goal, audience, success criteria, in/out scope, examples, counterexamples, constraints, and non-functional expectations.
3. Challenge vague claims until each can be reviewed and tested.
4. Use examples and counterexamples to compress intent into a few claims. Prefer durable product truth over implementation detail, terrain description, or cleanup tactics.
5. Write claims with stable IDs, statuses, types, statements, rationale, scope, empty or existing `tests`, and notes.
6. Mark new or materially changed claims `needs-review` unless the user explicitly approves them in the same interaction.

## Claim Guidance

Use claim types from `references/spec-artifact.md`: `capability`, `invariant`, `constraint`, `assumption`, and `non-functional`.

Good claims are:

- Specific enough to test.
- Stable across implementation attempts.
- Small enough for a human to review.
- Free of hidden chat-only context.

Avoid large generated specs, issue backlogs, implementation task lists, and catalogs of environmental mess in this phase. If spec work uncovers durable context, update `CONTEXT.md` as the map or add/update the downstream context file it points to.

Promote a detail into `SPEC.yaml` only when a human reviewer must approve it as product truth. Keep domain terrain, data corruption classes, anomaly examples, stakeholder notes, and cleaning recipes in mapped context; refer to them from claim notes or assumptions when needed.

## Output

Summarize the claim changes and list any human review decisions still needed. Do not proceed to test planning until the relevant claims are approved.
