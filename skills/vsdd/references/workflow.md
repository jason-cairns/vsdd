# VSDD Workflow Reference

VSDD is a human-in-the-loop, verification-first workflow for agentic software development. It exists because large agent-generated pull requests are hard to trust when the review object is mostly implementation volume and local test output. Move trust into small, durable, human-reviewable artifacts that capture what must be true, how it is tested, and what future work remains.

Core conjecture: most useful software rests on a small number of high-quality claims. Do not explode the spec into hundreds of claims: good products usually depend on a few product truths, and humans must be able to review them. Draw claims out through human-agent planning, ambiguity challenges, examples, and counterexamples.

Central rule:

```text
The chat is not the workflow state. The repository is the workflow state.
```

## Global Artifacts

Use global repo-level artifacts, not feature-local bundles:

- `CONTEXT.md`: map to stable domain language, architecture boundaries, repo conventions, commands, testing norms, and downstream context files. Keep detailed terrain in mapped files, not in the chat or bloated claims.
- `SPEC.yaml`: global ordered claims: capabilities, invariants, constraints, assumptions, and non-functional expectations. This is the highest artifact and needs the most human input.
- `TEST_PLAN.yaml`: reviewed test obligations: property, model, contract, regression, performance, security, and a small number of illustrative examples.
- `TASKS.yaml`: future work queue only; it is not history.
- Git history: durable record of completed work.

Keep artifacts small. If they become too large for human review, the workflow has failed; the goal is essence, not bureaucracy.

## Claim Boundary

`SPEC.yaml` contains product truths, not environmental inventories, implementation tactics, or data-cleaning checklists. Promote a detail into a claim only when a human product/domain reviewer must approve it as part of what the product is.

Use `CONTEXT.md` as a map when details are important but not claims:

- messy source systems, corrupt values, data dictionaries, stakeholder notes, and anomaly catalogs belong downstream of the `CONTEXT.md` map;
- a claim may say a dataset satisfies a model input contract, with assumptions or notes pointing to mapped context;
- `TEST_PLAN.yaml` proves the claim against those known terrain details;
- `TASKS.yaml` decomposes discovery or implementation work needed to make the claim true.

When spec work uncovers new domain context, update `CONTEXT.md` or a downstream file it maps to. Do not hide new durable context in chat.

## Preorder

Proceed in preorder:

```text
Claim -> test obligations -> implementation tasks -> commits
```

Ancestry is parent-linked without repeating parent information in children:

- Claims list test IDs in `tests`.
- Test suites list task IDs in `tasks`.
- Tasks do not repeat claim or test IDs.
- Commits reference only the task ID with `TASK-NNN: summary`.

Recover ancestry for a task by finding the test suite that lists it, then the claim that lists that test. Remove completed tasks from `TASKS.yaml` after commit; the commit is their durable record.

## Status-Driven State

Every artifact carries enough status to resume after interruption. Use `yq` or helpers to query and update relevant YAML sections rather than loading entire artifacts by default.

There is no stored `next_action`. Derive the next action from statuses, file order, git history, and preorder ancestry.

- Claims: `draft`, `needs-review`, `approved`, `deferred`, `obsolete`.
- Test specs: `draft`, `needs-review`, `approved`, `deferred`, `obsolete`.
- Test implementation: `not-started`, `partial`, `implemented`.
- Tasks: `draft`, `needs-review`, `approved`, `blocked`.
- Task execution: `pending`, `in-progress`.

Agents may draft and execute. Humans approve meaning. The higher the artifact, the more human-led it should be.

## Routing Helpers

The helper scripts require `yq` and should be run with `bash`:

- `select_ready_claims.sh`: first approved claims.
- `select_ready_tests.sh`: approved unfinished tests, optionally constrained to a claim by resolving the claim's listed tests.
- `select_ready_tasks.sh`: approved pending tasks, optionally constrained to a test by resolving the test suite's listed tasks.
- `trace_last_completed_task.sh`: most recent task-linked commit plus resolved test and claim ancestry.

Prefer continuing from the last completed task. If that test still has approved pending tasks, continue there. If not, continue with the next approved unfinished test for the associated claim. If the claim is complete, continue with the next approved unfinished claim.

## Human Gates

Keep human approval at semantic layers:

1. Humans co-author and approve claims in `SPEC.yaml`.
2. Humans review whether `TEST_PLAN.yaml` would prove those claims.
3. Humans review whether `TASKS.yaml` has safe boundaries and ordering.
4. Agents may autonomously implement only approved pending tasks.
5. Humans review exceptions, high-risk summaries, and soundness-review findings.

VSDD aims to make autonomous coding interrupt-safe, reviewable, and auditable. Every implementation step should trace back to human-approved claims and reviewed test obligations.
