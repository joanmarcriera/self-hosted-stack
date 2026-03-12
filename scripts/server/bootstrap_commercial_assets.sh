#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
core_env="${stack_root}/core/.env"
identity_env="${stack_root}/identity/.env"
business_env="${stack_root}/business/.env"
automation_env="${stack_root}/automation/.env"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../.." && pwd)"
repo_automation_compose="${repo_root}/opt-stacks/automation/docker-compose.yml"

require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    printf 'missing required file: %s\n' "$path" >&2
    exit 1
  }
}

upsert_env() {
  local file="$1"
  local key="$2"
  local value="$3"

  if grep -q "^${key}=" "$file" 2>/dev/null; then
    sed -i'' -e "s#^${key}=.*#${key}=${value}#" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >> "$file"
  fi
}

drop_env() {
  local file="$1"
  local key="$2"

  if [[ -f "$file" ]]; then
    sed -i'' -e "/^${key}=/d" "$file"
  fi
}

require_file "$core_env"
require_file "$identity_env"
require_file "$business_env"
require_file "$automation_env"
require_file "$repo_automation_compose"

set -a
. "$core_env"
. "$identity_env"
. "$business_env"
. "$automation_env"
set +a

owner_email="${AUTHENTIK_BOOTSTRAP_EMAIL:-${ACME_EMAIL:-}}"
default_team_id="${COMMERCIAL_TARGET_TEAM_ID:-${ESPOCRM_DEFAULT_TEAM_ID:-de502c342b7599a63}}"

[[ -n "$owner_email" ]] || {
  printf 'missing AUTHENTIK_BOOTSTRAP_EMAIL or ACME_EMAIL in stack env files\n' >&2
  exit 1
}

docker ps --format '{{.Names}}' | grep -qx 'espocrm' || {
  printf 'espocrm container is not running\n' >&2
  exit 1
}

docker ps --format '{{.Names}}' | grep -qx 'bookstack' || {
  printf 'bookstack container is not running\n' >&2
  exit 1
}

docker ps --format '{{.Names}}' | grep -qx 'n8n' || {
  printf 'n8n container is not running\n' >&2
  exit 1
}

lead_capture_output="$(docker exec -i \
  -e COMMERCIAL_LEAD_CAPTURE_NAME="Automation Audit Intake" \
  -e COMMERCIAL_TARGET_TEAM_ID="$default_team_id" \
  espocrm php /dev/stdin < "${script_dir}/bootstrap_espocrm_lead_capture.php")"

printf '%s\n' "$lead_capture_output"

lead_capture_api_key="$(printf '%s\n' "$lead_capture_output" | sed -n 's/^ESPOCRM_LEAD_CAPTURE_API_KEY=//p' | tail -n 1)"

[[ -n "$lead_capture_api_key" ]] || {
  printf 'failed to determine ESPOCRM_LEAD_CAPTURE_API_KEY\n' >&2
  exit 1
}

upsert_env "$automation_env" "ESPOCRM_API_BASE_URL" "https://${CRM_HOST}"
upsert_env "$automation_env" "ESPOCRM_LEAD_CAPTURE_API_KEY" "$lead_capture_api_key"
drop_env "$automation_env" "ESPOCRM_API_KEY"
drop_env "$automation_env" "ESPOCRM_API_USER"

install -m 0644 "$repo_automation_compose" "${stack_root}/automation/docker-compose.yml"

docker compose --env-file "$automation_env" -f "${stack_root}/automation/docker-compose.yml" up -d n8n

docker exec -i \
  -e COMMERCIAL_OWNER_EMAIL="$owner_email" \
  -e COMMERCIAL_BASE_DOMAIN="riera.co.uk" \
  bookstack php /dev/stdin < "${script_dir}/seed_bookstack_commercial_assets.php"

printf 'bootstrapped commercial automation assets and refreshed n8n env\n'
