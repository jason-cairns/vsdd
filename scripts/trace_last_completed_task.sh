#!/usr/bin/env bash
set -euo pipefail

SPEC_FILE="${1:-SPEC.yaml}"
TEST_PLAN_FILE="${2:-TEST_PLAN.yaml}"

TASK_ID="$(
  git log --format=%s \
  | grep -Eo '^TASK-[0-9]+' \
  | head -n 1 || true
)"

if [ -z "$TASK_ID" ]; then
  cat <<'YAML'
last_completed_task: null
tests: []
claims: []
YAML
  exit 0
fi

TEST_IDS="$({ yq -r --arg task_id "$TASK_ID" '
  .test_suites[]
  | select((.tasks // []) | index($task_id))
  | .id
' "$TEST_PLAN_FILE"; } | paste -sd, -)"

echo "last_completed_task: $TASK_ID"

echo "tests:"
if [ -z "$TEST_IDS" ]; then
  echo "[]"
else
  TEST_IDS="$TEST_IDS" yq -o=yaml '
    .test_suites
    | map(select((env(TEST_IDS) | split(",")) | index(.id)))
    | map({id, status, implementation_status, type, title, tasks})
  ' "$TEST_PLAN_FILE"
fi

echo "claims:"
if [ -z "$TEST_IDS" ]; then
  echo "[]"
else
  TEST_IDS="$TEST_IDS" yq -o=yaml '
    .claims
    | map(
        select(
          (.tests // []) as $linked
          | (env(TEST_IDS) | split(",")) as $wanted
          | any($wanted[]; . as $id | $linked | index($id))
        )
      )
    | map({id, status, type, title, tests})
  ' "$SPEC_FILE"
fi
