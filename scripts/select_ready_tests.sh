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

TEST_IDS="$({ yq -r --arg claim_id "$CLAIM_ID" '
  .claims[]
  | select(.id == $claim_id)
  | (.tests // [])[]
' "$SPEC_FILE"; } | paste -sd, -)"

if [ -z "$TEST_IDS" ]; then
  echo "[]"
  exit 0
fi

TEST_IDS="$TEST_IDS" LIMIT="$LIMIT" yq -o=yaml '
  .test_suites
  | map(
      select(
        .status == "approved"
        and .implementation_status != "implemented"
        and ((env(TEST_IDS) | split(",")) as $wanted | any($wanted[]; . == .id))
      )
    )
  | .[:env(LIMIT) | tonumber]
' "$TEST_PLAN_FILE"
