---
name: vsdd
description: Route and resume Verification-Specified Development workflows from repository artifacts. Use when the user invokes /vsdd or asks to continue VSDD work, decide the next VSDD phase, inspect claim/test/task status, or recover workflow state from CONTEXT.md, SPEC.yaml, TEST_PLAN.yaml, TASKS.yaml, and task-linked git history.
---

# VSDD Router

Use this as the user-facing entrypoint. Treat the chat as disposable; derive state from repository artifacts and git history. For non-trivial routing, read `references/workflow.md` first so the README-level VSDD semantics are preserved.

## Required Checks

1. Confirm the current directory is the target repo.
2. Check `command -v yq`. If missing, stop and tell the user: `VSDD requires yq. On macOS install it with: brew install yq`.
3. Inspect `git status --short --branch`.
4. Look for `CONTEXT.md`, `SPEC.yaml`, `TEST_PLAN.yaml`, and `TASKS.yaml`.
5. Read `references/workflow.md`, then `CONTEXT.md` if present. Query YAML selectively; do not load large artifacts unless the query result is insufficient.

## Routing Order

Use preorder: claim -> test obligations -> implementation tasks -> commits. Never use or create a stored `next_action`; derive routing from artifact statuses, file order, git history, and parent-linked ancestry.

1. If no `SPEC.yaml` exists, route to `$vsdd-spec-gen`.
2. If approved claims have no linked tests or only draft/unreviewed tests, route to `$vsdd-spec-to-tests`.
3. If approved unfinished tests have no linked approved tasks, route to `$vsdd-tests-to-tasks`.
4. If approved pending tasks exist, route to `$vsdd-implement-tasks`.
5. If recent commits or artifact statuses look inconsistent, route to `$vsdd-soundness-review`.
6. If everything is implemented and sound, report that no approved pending VSDD work is available.

Prefer continuing from the most recent task-linked commit when possible. Use `scripts/trace_last_completed_task.sh` to recover its test and claim ancestry, then continue within that test before moving to the next test or claim.

## Helper Scripts

Run scripts with `bash`, because bundled copies may not be executable:

- `bash scripts/trace_last_completed_task.sh SPEC.yaml TEST_PLAN.yaml`
- `bash scripts/select_ready_claims.sh SPEC.yaml 5`
- `bash scripts/select_ready_tests.sh SPEC.yaml TEST_PLAN.yaml CLAIM-001 5`
- `bash scripts/select_ready_tasks.sh TEST_PLAN.yaml TASKS.yaml TEST-001 5`

See `references/workflow.md` for artifact shape, statuses, and helper semantics.

## Output

Give the user the selected next action, the artifact evidence used to choose it, and the exact skill or phase that should run next. If routing is blocked, name the missing artifact, dependency, or review gate.
