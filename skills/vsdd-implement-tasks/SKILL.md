---
name: vsdd-implement-tasks
description: "Implement approved pending VSDD tasks from TASKS.yaml with traceability to TEST_PLAN.yaml, SPEC.yaml, and task-linked commits. Use when approved pending tasks exist, when the user asks to execute the next VSDD task, or when implementation must be scoped by claim/test ancestry and committed as TASK-NNN: summary."
---

# VSDD Implement Tasks

Implement only approved pending tasks. The orchestrator owns global context, acceptance, artifact updates, and commits.

## Required Checks

1. Check `command -v yq`. If missing, stop and tell the user: `VSDD requires yq. On macOS install it with: brew install yq`.
2. Inspect `git status --short --branch` and avoid sweeping unrelated changes into the task.
3. Read `CONTEXT.md` if present.
4. Use helper scripts to select the next approved pending task in preorder.
5. Persist the selected task as `execution_status: in-progress` before delegating or editing so interruption is recoverable.

## Selection

Prefer continuity from the last completed task:

- `bash scripts/trace_last_completed_task.sh SPEC.yaml TEST_PLAN.yaml`
- `bash scripts/select_ready_tasks.sh TEST_PLAN.yaml TASKS.yaml TEST-001 5`
- `bash scripts/select_ready_tests.sh SPEC.yaml TEST_PLAN.yaml CLAIM-001 5`

If continuity is unavailable, select the first approved pending task in `TASKS.yaml` order.

## Execution

Resolve the selected task's test and claim ancestry by walking upward through `TEST_PLAN.yaml` and `SPEC.yaml`. Build the implementation context from:

- the task objective and notes,
- the parent test obligation,
- the parent claim statement, rationale, and scope,
- relevant `CONTEXT.md` guidance,
- allowed and risky paths inferred from the repo.

Use subagents only when the active runtime and user request permit delegation. The orchestrator has the global view; workers should not. Give workers only task-local context and explicit boundaries, choose the minimal capable model for each task, and review summaries, files touched, test results, and risks before accepting work.

Monitor workers for wandering: unrelated exploration, off-scope edits, repeated retries, or scope creep. Interrupt and re-brief early when a worker drifts; do not wait for clearly wandering work to finish.

## Completion

After accepting a task:

1. Run focused validation.
2. Commit with `TASK-NNN: concise summary`.
3. Remove the completed task from `TASKS.yaml` or update it only if repository policy requires retention.
4. Update the parent test `implementation_status` when its tasks are complete.
5. Update claim status only when all linked tests convincingly satisfy it.
6. Persist enough artifact state that interruption at any point remains recoverable.
7. Report artifact updates, commit hash, validation commands, residual risk, and any orchestration issues that should improve future task briefs.

See `references/orchestration.md` for state update rules.
