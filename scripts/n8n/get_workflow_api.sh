#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $(basename "$0") <workflow-id>" >&2
  exit 1
fi

workflow_id="$1"
env_file="${N8N_API_ENV_FILE:-.secrets/n8n-api.env}"
if [[ ! -f "$env_file" ]]; then
  echo "Missing env file: $env_file" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$env_file"
: "${N8N_BASE_URL:?N8N_BASE_URL missing in $env_file}"
: "${N8N_API_KEY:?N8N_API_KEY missing in $env_file}"

curl -fsS \
  -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
  "${N8N_BASE_URL%/}/api/v1/workflows/${workflow_id}"
