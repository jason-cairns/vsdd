# TASKS.yaml Reference

Template:

```yaml
schema_version: 0.1

tasks:
  - id: TASK-000
    status: draft
    execution_status: pending
    title: ""
    objective: >
      ""
    notes: []
```

Task rules:

- Keep tasks small enough for one semantic commit.
- Use `approved` only after human acceptance.
- Use `execution_status: pending` for work the agent may implement.
- Do not repeat parent test or claim IDs in task objects.
- Add the task ID to the parent test suite's `tasks` list in `TEST_PLAN.yaml`.

Completed tasks are removed from `TASKS.yaml` after commit unless the repo explicitly chooses retention. The commit message is the durable history record.
