# Soundness Review Reference

Output shape:

```text
Soundness summary:
- <overall state>

Findings:
- [severity] <claim/test/task/commit id>: <gap and evidence>

Status updates:
- <artifact update made, or "none">

Next phase:
- <vsdd skill or human review gate>
```

Severity guide:

- `high`: implementation or artifact state contradicts an approved claim.
- `medium`: status or ancestry is stale enough to misroute future work.
- `low`: wording, notes, or evidence should be tightened but routing remains safe.

Prefer correspondence findings over broad code-review commentary. Recommend new claims when implementation introduced behavior outside current approved meaning.

Review surfaces:

- recent task-linked commits,
- implementation summaries and validation evidence,
- `SPEC.yaml`, `TEST_PLAN.yaml`, and `TASKS.yaml` status accuracy,
- gaps where tests, tasks, or implementation no longer fulfill approved claims.
