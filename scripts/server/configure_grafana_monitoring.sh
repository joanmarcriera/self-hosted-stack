#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
monitoring_env="${stack_root}/monitoring/.env"
monitoring_compose="${stack_root}/monitoring/docker-compose.yml"

require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    printf 'missing required file: %s\n' "$path" >&2
    exit 1
  }
}

require_file "$monitoring_env"
require_file "$monitoring_compose"

set -a
source "$monitoring_env"
set +a

docker compose --env-file "$monitoring_env" -f "$monitoring_compose" up -d --remove-orphans

for _ in $(seq 1 24); do
  if curl -ksS --fail "https://${STATUS_HOST}/api/health" >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

docker exec prometheus promtool check config /etc/prometheus/prometheus.yml >/dev/null

for _ in $(seq 1 24); do
  if docker exec prometheus promtool query instant http://127.0.0.1:9090 'sum(probe_success)' >/dev/null 2>&1; then
    break
  fi
  sleep 5
done

printf 'configured Grafana monitoring at https://%s\n' "${STATUS_HOST}"
