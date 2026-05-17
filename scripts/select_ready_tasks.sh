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

TASK_IDS="$({ yq -r --arg test_id "$TEST_ID" '
  .test_suites[]
  | select(.id == $test_id)
  | (.tasks // [])[]
' "$TEST_PLAN_FILE"; } | paste -sd, -)"

if [ -z "$TASK_IDS" ]; then
  echo "[]"
  exit 0
fi

TASK_IDS="$TASK_IDS" LIMIT="$LIMIT" yq -o=yaml '
  .tasks
  | map(
      select(
        .status == "approved"
        and .execution_status == "pending"
        and ((env(TASK_IDS) | split(",")) | index(.id))
      )
    )
  | .[:env(LIMIT) | tonumber]
' "$TASKS_FILE"
