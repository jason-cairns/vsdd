#!/usr/bin/env bash
set -euo pipefail

SPEC_FILE="${1:-SPEC.yaml}"
LIMIT="${2:-5}"

LIMIT="$LIMIT" yq -o=yaml '
  .claims
  | map(select(.status == "approved"))
  | .[:env(LIMIT) | tonumber]
' "$SPEC_FILE"
