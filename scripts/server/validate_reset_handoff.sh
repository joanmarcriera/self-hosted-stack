#!/usr/bin/env bash
set -euo pipefail

handoff_env="${1:-.secrets/server-reset-handoff.env}"
users_csv="${2:-.secrets/server-reset-users.csv}"

failures=0
warnings=0

error() {
  printf 'ERROR: %s\n' "$1" >&2
  failures=$((failures + 1))
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
  warnings=$((warnings + 1))
}

is_placeholder() {
  local value
  value="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  [[ "$value" == replace-* || "$value" == set-* || "$value" == change-me || "$value" == changeme || "$value" == example-* || "$value" == placeholder* ]]
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || error "missing file: $path"
}

is_email() {
  [[ "$1" == *"@"* && "$1" != *@ && "$1" != @* ]]
}

require_file "$handoff_env"
require_file "$users_csv"

if (( failures > 0 )); then
  exit 1
fi

set -a
. "$handoff_env"
set +a

required_vars=(
  BASE_DOMAIN
  OWNER_NAME
  OWNER_EMAIL
  TZ
  AUTHENTIK_EMAIL_HOST
  AUTHENTIK_EMAIL_PORT
  AUTHENTIK_EMAIL_USERNAME
  AUTHENTIK_EMAIL_PASSWORD
  AUTHENTIK_EMAIL_USE_TLS
  AUTHENTIK_EMAIL_USE_SSL
  AUTHENTIK_EMAIL_TIMEOUT
  AUTHENTIK_EMAIL_FROM
  N8N_OWNER_EMAIL
)

for key in "${required_vars[@]}"; do
  if [[ -z "${!key:-}" ]]; then
    error "required variable is empty: $key"
  fi
done

if is_placeholder "${AUTHENTIK_EMAIL_PASSWORD:-}"; then
  error "AUTHENTIK_EMAIL_PASSWORD still looks like a placeholder"
fi

if ! is_email "${OWNER_EMAIL:-}"; then
  error "OWNER_EMAIL is not a valid email: ${OWNER_EMAIL:-}"
fi

if ! is_email "${AUTHENTIK_EMAIL_USERNAME:-}"; then
  error "AUTHENTIK_EMAIL_USERNAME is not a valid email: ${AUTHENTIK_EMAIL_USERNAME:-}"
fi

if ! is_email "${AUTHENTIK_EMAIL_FROM:-}"; then
  error "AUTHENTIK_EMAIL_FROM is not a valid email: ${AUTHENTIK_EMAIL_FROM:-}"
fi

if ! is_email "${N8N_OWNER_EMAIL:-}"; then
  error "N8N_OWNER_EMAIL is not a valid email: ${N8N_OWNER_EMAIL:-}"
fi

if [[ ! "${AUTHENTIK_EMAIL_PORT:-}" =~ ^[0-9]+$ ]]; then
  error "AUTHENTIK_EMAIL_PORT must be numeric"
fi

if [[ ! "${AUTHENTIK_EMAIL_TIMEOUT:-}" =~ ^[0-9]+$ ]]; then
  error "AUTHENTIK_EMAIL_TIMEOUT must be numeric"
fi

if [[ "${AUTHENTIK_EMAIL_USE_TLS:-}" != "true" && "${AUTHENTIK_EMAIL_USE_TLS:-}" != "false" ]]; then
  error "AUTHENTIK_EMAIL_USE_TLS must be true or false"
fi

if [[ "${AUTHENTIK_EMAIL_USE_SSL:-}" != "true" && "${AUTHENTIK_EMAIL_USE_SSL:-}" != "false" ]]; then
  error "AUTHENTIK_EMAIL_USE_SSL must be true or false"
fi

if [[ "${AUTHENTIK_EMAIL_HOST:-}" == "smtp.gmail.com" ]]; then
  if [[ "${AUTHENTIK_EMAIL_USE_TLS:-}" != "true" ]]; then
    error "Gmail on smtp.gmail.com requires AUTHENTIK_EMAIL_USE_TLS=true for the documented 587 flow"
  fi
  if [[ "${AUTHENTIK_EMAIL_USE_SSL:-}" != "false" ]]; then
    warn "Gmail example uses AUTHENTIK_EMAIL_USE_SSL=false"
  fi
  if [[ "${AUTHENTIK_EMAIL_PORT:-}" != "587" ]]; then
    warn "Gmail example uses AUTHENTIK_EMAIL_PORT=587"
  fi
  if [[ "${AUTHENTIK_EMAIL_PASSWORD:-}" == *" "* || "${AUTHENTIK_EMAIL_PASSWORD:-}" == *"\""* || "${AUTHENTIK_EMAIL_PASSWORD:-}" == *"'"* ]]; then
    error "AUTHENTIK_EMAIL_PASSWORD still contains spaces or quotes"
  fi
  if [[ ${#AUTHENTIK_EMAIL_PASSWORD} -ne 16 ]]; then
    warn "AUTHENTIK_EMAIL_PASSWORD is not 16 characters after normalization; confirm the app password was copied without spaces"
  fi
fi

header="$(head -n 1 "$users_csv" | tr -d '\r')"
expected_header="username,full_name,email,authentik_groups,authentik_password,n8n_access"
if [[ "$header" != "$expected_header" ]]; then
  error "unexpected users CSV header: $header"
fi

founders_count=0
n8n_owner_count=0
row_num=1

while IFS=, read -r username full_name email groups password n8n_access extra; do
  row_num=$((row_num + 1))
  username="${username%$'\r'}"
  full_name="${full_name%$'\r'}"
  email="${email%$'\r'}"
  groups="${groups%$'\r'}"
  password="${password%$'\r'}"
  n8n_access="${n8n_access%$'\r'}"
  extra="${extra%$'\r'}"
  [[ -z "${username}${full_name}${email}${groups}${password}${n8n_access}${extra}" ]] && continue
  [[ "$username" == username && "$full_name" == full_name ]] && continue

  if [[ -n "${extra:-}" ]]; then
    error "row $row_num has too many columns"
  fi

  [[ -n "$username" ]] || error "row $row_num missing username"
  [[ -n "$full_name" ]] || error "row $row_num missing full_name"
  [[ -n "$email" ]] || error "row $row_num missing email"
  [[ -n "$groups" ]] || error "row $row_num missing authentik_groups"
  [[ -n "$password" ]] || error "row $row_num missing authentik_password"
  [[ -n "$n8n_access" ]] || error "row $row_num missing n8n_access"

  if is_placeholder "$password"; then
    error "row $row_num authentik_password still looks like a placeholder"
  fi

  if ! is_email "$email"; then
    error "row $row_num email is invalid: $email"
  fi

  IFS=';' read -r -a split_groups <<<"$groups"
  valid_group=0
  for group in "${split_groups[@]}"; do
    case "$group" in
      automation-founders|automation-delivery|automation-ops) valid_group=1 ;;
      *) error "row $row_num has unsupported group: $group" ;;
    esac
    [[ "$group" == "automation-founders" ]] && founders_count=$((founders_count + 1))
  done
  if (( valid_group == 0 )); then
    error "row $row_num has no valid groups"
  fi

  case "$n8n_access" in
    owner)
      n8n_owner_count=$((n8n_owner_count + 1))
      if [[ "$email" != "${N8N_OWNER_EMAIL:-}" ]]; then
        warn "row $row_num is marked owner for n8n but email does not match N8N_OWNER_EMAIL"
      fi
      ;;
    editor|none) ;;
    *) error "row $row_num has unsupported n8n_access: $n8n_access" ;;
  esac
done <"$users_csv"

if (( founders_count == 0 )); then
  error "users CSV has no automation-founders user"
fi

if (( n8n_owner_count > 1 )); then
  error "users CSV has more than one n8n owner row"
fi

if (( n8n_owner_count == 0 )); then
  warn "users CSV has no n8n owner row; n8n owner creation will need a manual first login"
fi

if (( failures > 0 )); then
  printf 'handoff validation failed with %d error(s) and %d warning(s)\n' "$failures" "$warnings" >&2
  exit 1
fi

printf 'handoff validation passed with %d warning(s)\n' "$warnings"
printf 'base domain: %s\n' "$BASE_DOMAIN"
printf 'owner email: %s\n' "$OWNER_EMAIL"
printf 'n8n owner email: %s\n' "$N8N_OWNER_EMAIL"
printf 'users file: %s\n' "$users_csv"
