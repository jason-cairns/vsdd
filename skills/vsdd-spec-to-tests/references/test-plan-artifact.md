# TEST_PLAN.yaml Reference

Template:

```yaml
schema_version: 0.1

test_suites:
  - id: TEST-000
    status: draft
    implementation_status: not-started
    type: property
    title: ""
    obligation: >
      ""
    tasks: []
    notes: []
```

Test types:

- `property`: general behavior across many inputs or states.
- `model`: comparison against a simpler reference model.
- `contract`: API, schema, CLI, file, or integration contract.
- `regression`: known failure or previously fixed behavior.
- `performance`: latency, throughput, memory, or scale obligation.
- `security`: authorization, input handling, leakage, or threat behavior.
- `example`: one illustrative scenario; use sparingly.

Parent ancestry lives in `SPEC.yaml`: add each test ID to the relevant claim's `tests` list. Do not add claim IDs to test suites.
