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

out_dir="${1:-.secrets/n8n-live-export-api/$(date +%F)}"
mkdir -p "$out_dir"

list_resp="$(curl -fsS \
  -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
  "${N8N_BASE_URL%/}/api/v1/workflows?limit=250")"

manifest="$out_dir/manifest.tsv"
: > "$manifest"

jq -r '
  if type == "object" and has("data") then .data
  elif type == "array" then .
  else [] end
  | .[]
  | [.id, .name, (.active|tostring)]
  | @tsv
' <<<"$list_resp" | while IFS=$'\t' read -r workflow_id workflow_name workflow_active; do
  slug="$(printf '%s' "$workflow_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  [[ -n "$slug" ]] || slug="workflow"
  out_file="$out_dir/${workflow_id}--${slug}.json"

  curl -fsS \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "${N8N_BASE_URL%/}/api/v1/workflows/${workflow_id}" \
    | jq '.' > "$out_file"

  printf '%s\t%s\t%s\t%s\n' "$workflow_id" "$workflow_active" "$workflow_name" "$out_file" >> "$manifest"
  printf 'exported %s -> %s\n' "$workflow_id" "$out_file"
done

printf 'manifest %s\n' "$manifest"
