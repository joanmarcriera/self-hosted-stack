#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
core_env="${stack_root}/core/.env"
identity_env="${stack_root}/identity/.env"

require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    printf 'missing required file: %s\n' "$path" >&2
    exit 1
  }
}

upsert_env_value() {
  local file="$1"
  local key="$2"
  local value="$3"
  local escaped
  escaped="$(printf '%s' "$value" | sed 's/[\/&]/\\&/g')"
  if grep -q "^${key}=" "$file"; then
    sed -i "s/^${key}=.*/${key}=${escaped}/" "$file"
  else
    printf '%s=%s\n' "$key" "$value" >>"$file"
  fi
}

require_file "$core_env"
require_file "$identity_env"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/wait_for_authentik_api.sh" "$stack_root" 24 5

set -a
. "$core_env"
. "$identity_env"
set +a

upsert_env_value "$identity_env" AUTHENTIK_EMAIL_HOST "${AUTHENTIK_EMAIL_HOST:-localhost}"
upsert_env_value "$identity_env" AUTHENTIK_EMAIL_PORT "${AUTHENTIK_EMAIL_PORT:-25}"
upsert_env_value "$identity_env" AUTHENTIK_EMAIL_USERNAME "${AUTHENTIK_EMAIL_USERNAME:-}"
upsert_env_value "$identity_env" AUTHENTIK_EMAIL_PASSWORD "${AUTHENTIK_EMAIL_PASSWORD:-}"
upsert_env_value "$identity_env" AUTHENTIK_EMAIL_USE_TLS "${AUTHENTIK_EMAIL_USE_TLS:-false}"
upsert_env_value "$identity_env" AUTHENTIK_EMAIL_USE_SSL "${AUTHENTIK_EMAIL_USE_SSL:-false}"
upsert_env_value "$identity_env" AUTHENTIK_EMAIL_TIMEOUT "${AUTHENTIK_EMAIL_TIMEOUT:-10}"
upsert_env_value "$identity_env" AUTHENTIK_EMAIL_FROM "${AUTHENTIK_EMAIL_FROM:-${AUTHENTIK_BOOTSTRAP_EMAIL}}"
chmod 600 "$identity_env"

set -a
. "$identity_env"
set +a

api_base="https://${AUTH_HOST}/api/v3"
auth_header="Authorization: Bearer ${AUTHENTIK_BOOTSTRAP_TOKEN}"

api_get() {
  curl -ksS -H "$auth_header" "${api_base}$1"
}

api_write() {
  local method="$1"
  local path="$2"
  local payload="$3"
  curl -ksS -X "$method" \
    -H "$auth_header" \
    -H 'Content-Type: application/json' \
    "${api_base}${path}" \
    --data "$payload"
}

recovery_flow_pk="$(
  api_get "/flows/instances/?page_size=200" \
    | jq -r '.results[] | select(.slug == "default-recovery-flow") | .pk' \
    | head -n 1
)"

if [[ -z "$recovery_flow_pk" ]]; then
  docker exec authentik-server ak apply_blueprint /blueprints/example/flows-recovery-email-verification.yaml >/dev/null
  recovery_flow_pk="$(
    api_get "/flows/instances/?page_size=200" \
      | jq -r '.results[] | select(.slug == "default-recovery-flow") | .pk' \
      | head -n 1
  )"
fi

if [[ -z "$recovery_flow_pk" ]]; then
  printf 'failed to locate default-recovery-flow after blueprint import\n' >&2
  exit 1
fi

brand_json="$(
  api_get "/core/brands/?page_size=50" \
    | jq -c '.results[] | select(.default == true)' \
    | head -n 1
)"

if [[ -z "$brand_json" ]]; then
  printf 'failed to locate default Authentik brand\n' >&2
  exit 1
fi

brand_uuid="$(printf '%s' "$brand_json" | jq -r '.brand_uuid')"
current_recovery_flow="$(printf '%s' "$brand_json" | jq -r '.flow_recovery // empty')"

if [[ "$current_recovery_flow" != "$recovery_flow_pk" ]]; then
  payload="$(jq -n --arg flow_recovery "$recovery_flow_pk" '{flow_recovery: $flow_recovery}')"
  api_write PATCH "/core/brands/${brand_uuid}/" "$payload" >/dev/null
fi

smtp_host="${AUTHENTIK_EMAIL_HOST:-localhost}"
smtp_from="${AUTHENTIK_EMAIL_FROM:-authentik@localhost}"

printf 'configured Authentik recovery flow on default brand\n'
if [[ "$smtp_host" == "localhost" || -z "$smtp_host" ]]; then
  printf 'SMTP still uses placeholder settings in %s\n' "$identity_env"
else
  printf 'SMTP configured via %s as %s from %s\n' "$smtp_host" "${AUTHENTIK_EMAIL_PORT:-25}" "$smtp_from"
fi
