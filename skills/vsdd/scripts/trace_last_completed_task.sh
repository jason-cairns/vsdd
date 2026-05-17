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

TEST_IDS="$({ TASK_ID="$TASK_ID" yq -r '
  .test_suites[]
  | select((.tasks // []) | contains([strenv(TASK_ID)]))
  | .id
' "$TEST_PLAN_FILE"; } | paste -sd, -)"

echo "last_completed_task: $TASK_ID"

echo "tests:"
if [ -z "$TEST_IDS" ]; then
  echo "[]"
else
  TEST_IDS="$TEST_IDS" yq -o=yaml '
    .test_suites
    | map(.id as $id | select(strenv(TEST_IDS) | split(",") | contains([$id])))
    | map({"id": .id, "status": .status, "implementation_status": .implementation_status, "type": .type, "title": .title, "tasks": .tasks})
  ' "$TEST_PLAN_FILE"
fi

echo "claims:"
if [ -z "$TEST_IDS" ]; then
  echo "[]"
else
  TEST_IDS="$TEST_IDS" yq -o=yaml '
    .claims
    | map(
        (.tests // []) as $linked
        | select(strenv(TEST_IDS) | split(",") | any_c(. as $id | $linked | contains([$id])))
      )
    | map({"id": .id, "status": .status, "type": .type, "title": .title, "tests": .tests})
  ' "$SPEC_FILE"
fi
