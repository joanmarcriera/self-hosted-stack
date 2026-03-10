#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
core_env="${stack_root}/core/.env"
identity_env="${stack_root}/identity/.env"
business_env="${stack_root}/business/.env"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    printf 'missing required file: %s\n' "$path" >&2
    exit 1
  }
}

require_file "$core_env"
require_file "$identity_env"
require_file "$business_env"

set -a
. "$core_env"
. "$identity_env"
. "$business_env"
set +a

owner_email="${AUTHENTIK_BOOTSTRAP_EMAIL:-}"
base_domain="${BASE_DOMAIN:-}"
vikunja_db="${stack_root}/business/data/vikunja/db/vikunja.db"

[[ -n "$owner_email" ]] || {
  printf 'missing AUTHENTIK_BOOTSTRAP_EMAIL in %s\n' "$identity_env" >&2
  exit 1
}

[[ -n "$base_domain" ]] || {
  printf 'missing BASE_DOMAIN in %s\n' "$core_env" >&2
  exit 1
}

[[ -f "$vikunja_db" ]] || {
  printf 'missing Vikunja database: %s\n' "$vikunja_db" >&2
  exit 1
}

docker ps --format '{{.Names}}' | grep -qx 'bookstack' || {
  printf 'bookstack container is not running\n' >&2
  exit 1
}

docker ps --format '{{.Names}}' | grep -qx 'espocrm' || {
  printf 'espocrm container is not running\n' >&2
  exit 1
}

docker exec -i \
  -e DEMO_OWNER_EMAIL="$owner_email" \
  -e DEMO_BASE_DOMAIN="$base_domain" \
  bookstack php /dev/stdin < "${script_dir}/seed_bookstack_demo.php"

python3 "${script_dir}/seed_vikunja_demo.py" "$vikunja_db" "$base_domain"

docker exec -i \
  -e DEMO_OWNER_EMAIL="$owner_email" \
  -e DEMO_BASE_DOMAIN="$base_domain" \
  espocrm php /dev/stdin < "${script_dir}/seed_espocrm_demo.php"

printf 'seeded demo content for BookStack, Vikunja, and EspoCRM\n'
