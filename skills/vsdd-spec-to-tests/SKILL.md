---
name: vsdd-spec-to-tests
description: Convert approved VSDD claims in SPEC.yaml into reviewed TEST_PLAN.yaml test obligations. Use when approved claims lack adequate tests, when TEST_PLAN.yaml must be created or updated, or when claims need property, model, contract, regression, performance, security, or example obligations before implementation tasks are written.
---

# VSDD Spec To Tests

Turn approved claims into reviewed test obligations for human approval. Do not write implementation tests in this phase unless the user explicitly asks; define what must be tested.

## Workflow

1. Read `CONTEXT.md` if present.
2. Select approved claims from `SPEC.yaml`; avoid spending effort on `draft`, `deferred`, or `obsolete` claims unless asked.
3. Inspect existing `TEST_PLAN.yaml` and preserve valid reviewed suites.
4. Add or revise test suites for the selected claims, favoring obligations that would actually prove the claim.
5. Update each affected claim's `tests` list in `SPEC.yaml`.
6. Mark new or materially changed suites `needs-review` unless the user explicitly approves them.

## Test Obligation Guidance

Prefer a small number of strong obligations over many examples. Use these types where they fit: `property`, `model`, `contract`, `regression`, `performance`, `security`, and `example`.

Each test suite should state the obligation, not the implementation mechanics. Keep parent ancestry in `SPEC.yaml`; do not repeat claim IDs in test suites.

See `references/test-plan-artifact.md` for the YAML shape and an example.

## Output

Report which claims gained or changed test coverage, which suites need review, and whether the repo is ready for `$vsdd-tests-to-tasks`.
