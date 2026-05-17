---
name: vsdd-spec-gen
description: Conduct the VSDD human-agent specification interview and create or update SPEC.yaml. Use when a repo lacks approved VSDD claims, when claims need revision, when product intent is ambiguous, or when the user wants capabilities, invariants, constraints, assumptions, and non-functional expectations compressed into a small human-reviewable claim set.
---

# VSDD Spec Generation

Create or revise `SPEC.yaml`. This is the most human-led VSDD phase; claims should emerge from planning conversation, not mechanical generation.

## Workflow

1. Read `CONTEXT.md` if present, plus any existing `SPEC.yaml`.
2. Interview the user for goal, audience, success criteria, in/out scope, examples, counterexamples, constraints, and non-functional expectations.
3. Challenge vague claims until each can be reviewed and tested.
4. Use examples and counterexamples to compress intent into a small claim set. Prefer durable product truth over implementation detail.
5. Write claims with stable IDs, statuses, types, statements, rationale, scope, empty or existing `tests`, and notes.
6. Mark new or materially changed claims `needs-review` unless the user explicitly approves them in the same interaction.

## Claim Guidance

Use claim types from `references/spec-artifact.md`: `capability`, `invariant`, `constraint`, `assumption`, and `non-functional`.

Good claims are:

- Specific enough to test.
- Stable across implementation attempts.
- Small enough for a human to review.
- Free of hidden chat-only context.

Avoid large generated specs, issue backlogs, and implementation task lists in this phase.

## Output

Summarize the claim changes and list any human review decisions still needed. Do not proceed to test planning until the relevant claims are approved.
