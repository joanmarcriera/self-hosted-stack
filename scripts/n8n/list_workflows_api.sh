#!/usr/bin/env bash
set -euo pipefail

env_file="${N8N_API_ENV_FILE:-.secrets/n8n-api.env}"
if [[ ! -f "$env_file" ]]; then
  echo "Missing env file: $env_file" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$env_file"
: "${N8N_BASE_URL:?N8N_BASE_URL missing in $env_file}"
: "${N8N_API_KEY:?N8N_API_KEY missing in $env_file}"

resp="$(curl -fsS \
  -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
  "${N8N_BASE_URL%/}/api/v1/workflows?limit=250")"

if command -v jq >/dev/null 2>&1; then
  # Support both common response shapes: {data:[...]} or [...]
  jq -r '
    if type == "object" and has("data") then .data
    elif type == "array" then .
    else [] end
    | .[]
    | "\(.id)|\(.name)|active=\(.active)"' <<<"$resp"
else
  printf '%s\n' "$resp"
fi
