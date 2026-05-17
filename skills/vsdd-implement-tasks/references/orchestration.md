# Implementation Orchestration Reference

Commit format:

```text
TASK-017: implement atomic failed-import property
```

Selection:

1. Trace the most recent task-linked commit.
2. If its parent test still has approved pending tasks, continue that test.
3. Otherwise continue with the next approved unfinished test for the same claim.
4. Otherwise continue with the next approved unfinished claim.
5. If no continuity applies, use artifact order.

Worker prompt contents, when delegation is permitted:

- task ID, title, objective, and notes,
- parent test obligation and implementation status,
- parent claim statement, rationale, and scope,
- relevant `CONTEXT.md` excerpts,
- known forbidden paths, commands, expected output, and risk notes.

Avoid hard allowed-path lists unless the task genuinely requires them. Over-constraining paths can force locally tidy but globally suboptimal approaches. Instead, ask workers to explain unexpected touched areas in their summary.

Model choice:

- Choose the minimal capable model for each worker task.
- Use cheaper or smaller models for routine mechanical work.
- Use stronger models for foundational, ambiguous, cross-cutting, high-risk, or architecture-sensitive work.
- Treat model choice as part of orchestration, not an afterthought.

Acceptance:

- Validate the behavior required by the parent test obligation.
- Reject changes that satisfy a task locally while violating claim scope or repo boundaries.
- Treat subagents as replaceable workers, but account for their work cost before discarding output.
- Default verification surface is worker summary, validation evidence, declared risks, and `git diff --name-only`.
- Inspect deeper where risk warrants it; do not perform full manual-style diff review by default.
- If output is globally wrong, revert or reject and re-brief with missing context rather than quietly patching it yourself.
- Keep artifact updates narrow, interruption-safe, and traceable to the completed task.

Wander control:

- Watch for unrelated file reads, off-scope edits, repeated retries, expanding scope, or updates that no longer match the task.
- Prefer interrupting and re-briefing a wandering worker over letting it finish.
- Re-brief with the missing global context only when the mismatch is material: wrong abstraction, duplicate concept, broken pattern, or future-task blocker.
- Do not treat global-context rejection as normal code review.

Final orchestration report:

- Completed task and commit subject.
- Validation run.
- Subagent wandering, re-briefs, or over-local solutions encountered.
- Suggested improvements to future task briefs or VSDD artifacts.
