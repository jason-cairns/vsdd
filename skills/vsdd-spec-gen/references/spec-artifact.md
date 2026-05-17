# SPEC.yaml Reference

Template:

```yaml
schema_version: 0.1

claims:
  - id: CLAIM-000
    status: draft
    type: capability
    title: ""
    statement: >
      ""
    rationale: >
      ""
    scope:
      in: []
      out: []
    tests: []
    notes: []
```

Claim types:

- `capability`: user-visible or system capability.
- `invariant`: behavior that must always hold.
- `constraint`: boundary or rule the implementation must obey.
- `assumption`: explicit dependency or belief that may later be invalidated.
- `non-functional`: quality requirement such as performance, security, reliability, or operability.

Use `needs-review` for new claims unless the human explicitly approves them. Keep `tests` empty until `$vsdd-spec-to-tests` creates reviewed obligations.
