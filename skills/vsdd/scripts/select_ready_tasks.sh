#!/usr/bin/env bash
set -euo pipefail

TEST_PLAN_FILE="${1:-TEST_PLAN.yaml}"
TASKS_FILE="${2:-TASKS.yaml}"
TEST_ID="${3:-}"
LIMIT="${4:-5}"

if [ -z "$TEST_ID" ]; then
  LIMIT="$LIMIT" yq -o=yaml '
    .tasks
    | map(select(.status == "approved" and .execution_status == "pending"))
    | .[:env(LIMIT) | tonumber]
  ' "$TASKS_FILE"
  exit 0
fi

TASK_IDS="$({ TEST_ID="$TEST_ID" yq -r '
  .test_suites[]
  | select(.id == strenv(TEST_ID))
  | (.tasks // [])[]
' "$TEST_PLAN_FILE"; } | paste -sd, -)"

if [ -z "$TASK_IDS" ]; then
  echo "[]"
  exit 0
fi

TASK_IDS="$TASK_IDS" LIMIT="$LIMIT" yq -o=yaml '
  .tasks
  | map(
      .id as $id |
      select(
        .status == "approved"
        and .execution_status == "pending"
        and (strenv(TASK_IDS) | split(",") | contains([$id]))
      )
    )
  | .[:env(LIMIT) | tonumber]
' "$TASKS_FILE"
