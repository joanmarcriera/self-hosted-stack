#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
attempts="${2:-24}"
delay="${3:-5}"

core_env="${stack_root}/core/.env"
identity_env="${stack_root}/identity/.env"

for file in "$core_env" "$identity_env"; do
  [[ -f "$file" ]] || {
    printf 'missing required file: %s\n' "$file" >&2
    exit 1
  }
done

set -a
source "$core_env"
source "$identity_env"
set +a

[[ -n "${AUTH_HOST:-}" ]] || {
  printf 'missing AUTH_HOST in %s\n' "$identity_env" >&2
  exit 1
}

[[ -n "${AUTHENTIK_BOOTSTRAP_TOKEN:-}" ]] || {
  printf 'missing AUTHENTIK_BOOTSTRAP_TOKEN in %s\n' "$identity_env" >&2
  exit 1
}

api_url="https://${AUTH_HOST}/api/v3/core/users/me/"

for (( attempt = 1; attempt <= attempts; attempt++ )); do
  http_code="$(
    curl -ksS -o /dev/null -w '%{http_code}' \
      -H "Authorization: Bearer ${AUTHENTIK_BOOTSTRAP_TOKEN}" \
      "$api_url" || true
  )"

  if [[ "$http_code" == "200" ]]; then
    printf 'Authentik API ready after %d attempt(s)\n' "$attempt"
    exit 0
  fi

  sleep "$delay"
done

printf 'Authentik API did not become ready at %s\n' "$api_url" >&2
exit 1
