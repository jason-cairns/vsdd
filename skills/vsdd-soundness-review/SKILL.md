---
name: vsdd-soundness-review
description: Audit VSDD correspondence between SPEC.yaml claims, TEST_PLAN.yaml obligations, TASKS.yaml work items, implementation changes, and task-linked git history. Use when recent work may have drifted from approved claims, statuses may be stale, tests marked implemented need evidence, or the user asks whether VSDD artifacts remain sound.
---

# VSDD Soundness Review

Assess whether implementation and artifact state still correspond to approved VSDD meaning. Focus on correspondence and gaps, not broad code review.

## Required Checks

1. Check `command -v yq`. If missing, stop and tell the user: `VSDD requires yq. On macOS install it with: brew install yq`.
2. Inspect `git status --short --branch`.
3. Read `CONTEXT.md` if present.
4. Use helper scripts and targeted `git log`/`git show` inspection to connect tasks, tests, claims, and commits.
5. Spawn scoped subagents only when useful to scan code, inspect recent commits, compare implementation summaries, or check artifact statuses.

## Review Focus

Look for:

- approved claims without adequate tests,
- tests marked `implemented` without convincing task or commit evidence,
- approved pending tasks that no longer match their parent test,
- commits with `TASK-NNN` messages that cannot be traced through `TEST_PLAN.yaml` and `SPEC.yaml`,
- implementation that appears locally correct but violates claim scope, architecture, or non-functional expectations,
- new behavior that should trigger new or revised claims.

Do not turn this into a full code review unless a correspondence gap requires code inspection.

## Helpers

Run scripts with `bash`:

- `bash scripts/trace_last_completed_task.sh SPEC.yaml TEST_PLAN.yaml`
- `bash scripts/select_ready_claims.sh SPEC.yaml 20`
- `bash scripts/select_ready_tests.sh SPEC.yaml TEST_PLAN.yaml "" 20`
- `bash scripts/select_ready_tasks.sh TEST_PLAN.yaml TASKS.yaml "" 20`

See `references/soundness.md` for audit output shape.

## Output

Return a concise soundness summary, evidence-backed gaps, status updates made, and recommended next VSDD phase. If you change artifacts, keep edits narrow and explain the reason.
