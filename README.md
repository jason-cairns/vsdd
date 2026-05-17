# VSDD

VSDD is a human-in-the-loop, verification-first workflow for agentic software development. Its motivation is that large agent-generated pull requests are hard to trust because the review object becomes thousands of lines of implementation and hundreds of local tests. VSDD moves trust toward a small set of durable, human-reviewable artifacts that capture the essence of the product: what must be true, how that truth is tested, and what future implementation work remains.

The core conjecture is that most useful software can be described by a relatively small number of high-quality claims. Those claims should not be generated mechanically. They should emerge from a significant human-agent planning conversation where the agent interviews the human, challenges ambiguity, asks for examples and counterexamples, and compresses the product into a small, reviewable set of claims.

The chat session is disposable. The repository is the workflow state. A user should be able to clear the chat, invoke `/vsdd`, and continue from the artifacts without re-explaining the process.

## Global artifacts

VSDD uses global repo-level artifacts, not feature-local bundles.

- `CONTEXT.md` contains stable domain language, architectural boundaries, repo conventions, commands, testing norms, and other background needed by agents.
- `SPEC.yaml` contains the global ordered claims: capabilities, invariants, constraints, assumptions, and non-functional expectations. This is the highest-level artifact and should involve the most human input.
- `TEST_PLAN.yaml` contains reviewed test obligations, including property-based tests, model-based tests, contract tests, regression tests, performance tests, security tests, and a small number of illustrative examples.
- `TASKS.yaml` is the future work queue only. It is not history.
- Git history is the record of completed work.

The artifacts should stay small. If they become too large for a human to review, the workflow has failed. The purpose is to capture the true essence of the software, not to create bureaucracy.

Artifact templates and examples are kept under `references/artifacts/`. Helper scripts for selective YAML queries are kept under `scripts/`.

## Preorder workflow

VSDD proceeds in preorder:

```text
Claim
  -> test obligations for that claim
    -> implementation tasks for those tests
      -> commits for those tasks
```

Ancestry is recorded without repeating parent information in child artifacts:

- Claims list the tests that verify them.
- Test suites list the tasks that implement them.
- Tasks do not repeat their parent test or claim IDs.
- Commits reference only the task ID.

The claim and test ancestry for a task can be recovered by walking upward through `TEST_PLAN.yaml` and `SPEC.yaml`: find the test suite that lists the task, then find the claim that lists that test.

A commit message should follow a standard task-linked pattern:

```text
TASK-017: implement atomic failed-import property
```

Completed tasks should be removed from `TASKS.yaml` after commit. Their durable record is the git commit.

## Status-driven state

Every artifact carries enough status to resume after interruption. The router and subskills should use tools such as `yq` to search and update only the relevant YAML sections rather than loading entire artifacts into context by default.

There is no stored `next_action` field. The router derives the next action from statuses, file order, git history, and the preorder ancestry encoded in the artifacts.

Typical statuses include:

- claims: `draft`, `needs-review`, `approved`, `deferred`, `obsolete`
- test specs: `draft`, `needs-review`, `approved`, `deferred`, `obsolete`, plus implementation status such as `not-started`, `partial`, or `implemented`
- tasks: `draft`, `needs-review`, `approved`, `blocked`, plus execution status such as `pending` or `in-progress`

Agents may draft and execute. Humans approve meaning. The higher the artifact, the more human-led it should be.

## Routing helpers

The scripts in `scripts/` are intended as reusable helpers for router and phase skills:

- `select_ready_claims.sh` returns the first approved claims.
- `select_ready_tests.sh` returns approved unfinished tests, optionally constrained to a claim by resolving the claim's listed tests.
- `select_ready_tasks.sh` returns approved pending tasks, optionally constrained to a test by resolving the test suite's listed tasks.
- `trace_last_completed_task.sh` finds the most recent task-linked commit, then resolves its test and claim ancestry by searching parent artifact links.

The router should prefer continuing from the last completed task when possible. If the test suite containing that task still has approved pending tasks, continue there. If not, continue with the next approved unfinished test for the associated claim. If the claim is complete, continue with the next approved unfinished claim.

## Skills

VSDD is operated by one user-facing router skill and several internal phase skills.

### `/vsdd`

`/vsdd` is the router. On each invocation it may read `CONTEXT.md`, inspect git history, and use selective YAML queries against `SPEC.yaml`, `TEST_PLAN.yaml`, and `TASKS.yaml`. It recomputes the next valid action from artifact statuses and preorder ancestry. It should not rely on chat history.

### `vsdd-spec-gen`

`vsdd-spec-gen` conducts the human-agent interview and produces or updates `SPEC.yaml`. This is the most human-in-the-loop phase. The skill should ask questions, surface ambiguity, request examples and counterexamples, challenge weak claims, and keep the resulting claim set small and reviewable.

### `vsdd-spec-to-tests`

`vsdd-spec-to-tests` reads `CONTEXT.md` and relevant sections of `SPEC.yaml`, then produces or updates `TEST_PLAN.yaml`. It should also update each affected claim's `tests` list in `SPEC.yaml`. Its job is not to write implementation tests immediately, but to draft test obligations for human review. It should prefer property-based, model-based, contract, regression, performance, and security tests over large piles of example tests.

### `vsdd-tests-to-tasks`

`vsdd-tests-to-tasks` reads `CONTEXT.md`, relevant sections of `SPEC.yaml`, and relevant sections of `TEST_PLAN.yaml`, then produces or updates `TASKS.yaml`. It should also update each affected test suite's `tasks` list in `TEST_PLAN.yaml`. It still reads the spec for context; tasks should not be generated from the test plan alone. Each task should be small, reviewable, and suitable for one semantic commit.

### `vsdd-implement-tasks`

`vsdd-implement-tasks` reads the relevant global context, selects the next approved pending task in preorder, persists that it is in progress, and spawns subagents for execution. The orchestrator has the global view; subagents should not. Each subagent prompt should contain only the relevant task, its resolved claim/test ancestry, allowed paths, forbidden paths, commands, expected output, and risk notes.

The implementation orchestrator treats subagents as replaceable workers. It reviews their summaries, files touched, test results, and declared risks rather than performing a full manual-style diff review of every line. It may inspect deeper where risk warrants it. It rejects work that is locally optimal but violates global claims, architectural boundaries, or task scope, while recognizing that subagent work still has cost and should not be discarded casually.

The orchestrator should choose the minimal capable model for each subagent task. Routine mechanical tasks should use cheaper or smaller models. Foundational, ambiguous, cross-cutting, high-risk, or architecture-sensitive tasks should use stronger models. Model choice is part of orchestration, not an afterthought.

After accepting a task, the orchestrator makes the commit itself using the standard task-linked commit format, removes or updates the task in `TASKS.yaml`, updates implementation statuses in `TEST_PLAN.yaml` and `SPEC.yaml` where appropriate, and persists enough state that interruption at any point is recoverable.

### `vsdd-soundness-review`

`vsdd-soundness-review` runs occasionally to assess whether recent tasks and their implementations actually fulfill the demands of the claims. It may spawn subagents to scan the codebase, inspect recent commits, compare implementation summaries against the artifact hierarchy, and check whether statuses in `SPEC.yaml`, `TEST_PLAN.yaml`, and `TASKS.yaml` remain accurate.

Its output should be a concise soundness summary and any status updates it made. It should focus on correspondence and gaps: claims without adequate tests, tests marked implemented without convincing evidence, tasks that appear locally correct but globally unsound, and implementation work that should trigger new or revised claims.

## Human gates

VSDD deliberately keeps human approval at the semantic layers:

1. Humans co-author and approve claims in `SPEC.yaml`.
2. Humans review whether `TEST_PLAN.yaml` would actually prove those claims.
3. Humans review whether `TASKS.yaml` has safe task boundaries and ordering.
4. Agents may autonomously implement only approved pending tasks.
5. Humans review exceptions, high-risk summaries, and soundness-review findings.

This keeps human attention focused on meaning rather than generated code volume.

## Design principle

The central rule is:

```text
The chat is not the workflow state. The repository is the workflow state.
```

VSDD aims to make autonomous coding interrupt-safe, reviewable, and auditable. The goal is not more process. The goal is to make agentic development trustworthy by ensuring every implementation step can be traced back to a small set of human-approved claims and reviewed test obligations.
