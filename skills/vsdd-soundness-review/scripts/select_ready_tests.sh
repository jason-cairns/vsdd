#!/usr/bin/env bash
set -euo pipefail

SPEC_FILE="${1:-SPEC.yaml}"
TEST_PLAN_FILE="${2:-TEST_PLAN.yaml}"
CLAIM_ID="${3:-}"
LIMIT="${4:-5}"

if [ -z "$CLAIM_ID" ]; then
  LIMIT="$LIMIT" yq -o=yaml '
    .test_suites
    | map(select(.status == "approved" and .implementation_status != "implemented"))
    | .[:env(LIMIT) | tonumber]
  ' "$TEST_PLAN_FILE"
  exit 0
fi

TEST_IDS="$({ CLAIM_ID="$CLAIM_ID" yq -r '
  .claims[]
  | select(.id == strenv(CLAIM_ID))
  | (.tests // [])[]
' "$SPEC_FILE"; } | paste -sd, -)"

if [ -z "$TEST_IDS" ]; then
  echo "[]"
  exit 0
fi

TEST_IDS="$TEST_IDS" LIMIT="$LIMIT" yq -o=yaml '
  .test_suites
  | map(
      .id as $id |
      select(
        .status == "approved"
        and .implementation_status != "implemented"
        and (strenv(TEST_IDS) | split(",") | contains([$id]))
      )
    )
  | .[:env(LIMIT) | tonumber]
' "$TEST_PLAN_FILE"
