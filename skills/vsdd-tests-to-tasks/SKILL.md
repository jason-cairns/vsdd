---
name: vsdd-tests-to-tasks
description: Convert approved VSDD TEST_PLAN.yaml suites into small approved TASKS.yaml work items. Use when approved unfinished tests lack implementation tasks, when TASKS.yaml must be created or updated, or when work needs to be sliced into one-semantic-commit tasks traceable through TEST_PLAN.yaml and SPEC.yaml.
---

# VSDD Tests To Tasks

Turn reviewed test obligations into implementation tasks. Tasks are future work only; git history records completed work. Always derive tasks from both the parent claim and the test obligation.

## Workflow

1. Read `CONTEXT.md` if present.
2. Read the relevant approved claims from `SPEC.yaml`; do not generate tasks from the test plan alone.
3. Select approved test suites from `TEST_PLAN.yaml` whose `implementation_status` is not `implemented`.
4. Add or revise small tasks in `TASKS.yaml` with safe boundaries and ordering for human review.
5. Update each affected test suite's `tasks` list in `TEST_PLAN.yaml`.
6. Mark new or materially changed tasks `needs-review` unless the user explicitly approves them.

## Task Guidance

Each task should be suitable for one semantic commit and should include objective plus risk or boundary notes where useful. Do not repeat parent test or claim IDs inside task objects; ancestry is recovered from parent artifact links.

Use `approved` plus `execution_status: pending` only when the human has accepted the task boundary.

See `references/task-artifact.md` for the YAML shape and an example.

## Output

Report created or changed tasks, parent tests updated, review gates remaining, and whether `$vsdd-implement-tasks` can run.
