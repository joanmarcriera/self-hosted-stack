#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
core_env="${stack_root}/core/.env"
identity_env="${stack_root}/identity/.env"
automation_env="${stack_root}/automation/.env"
business_env="${stack_root}/business/.env"
monitoring_env="${stack_root}/monitoring/.env"
monitoring_compose="${stack_root}/monitoring/docker-compose.yml"

require_file() {
  local path="$1"
  [[ -f "$path" ]] || {
    printf 'missing required file: %s\n' "$path" >&2
    exit 1
  }
}

sql_escape() {
  printf "%s" "$1" | sed "s/'/''/g"
}

require_file "$core_env"
require_file "$identity_env"
require_file "$automation_env"
require_file "$business_env"
require_file "$monitoring_env"
require_file "$monitoring_compose"

set -a
. "$core_env"
. "$identity_env"
. "$automation_env"
. "$business_env"
. "$monitoring_env"
set +a

kuma_public_hosts=(
  "${LANDING_HOST:-}"
  "${LANDING_WWW_HOST:-}"
  "${AUTH_HOST:-}"
  "${N8N_HOST:-}"
  "${DOCS_HOST:-}"
  "${TASKS_HOST:-}"
  "${CRM_HOST:-}"
  "${STATUS_HOST:-}"
)

for host in "${kuma_public_hosts[@]}"; do
  [[ -n "$host" ]] || {
    printf 'missing one or more required host variables in stack env files\n' >&2
    exit 1
  }
done

kuma_username="${KUMA_ADMIN_USERNAME:-}"
if [[ -z "$kuma_username" ]]; then
  printf 'missing KUMA_ADMIN_USERNAME in %s\n' "$monitoring_env" >&2
  exit 1
fi

sqlite_query() {
  local sql="$1"
  printf '%s\n' "$sql" | docker exec -i uptime-kuma sh -lc 'sqlite3 /app/data/kuma.db'
}

user_sql="$(sql_escape "$kuma_username")"
kuma_user_id="$(
  sqlite_query "select id from user where username='${user_sql}' order by id limit 1;"
)"

if [[ -z "$kuma_user_id" ]]; then
  printf 'failed to locate Kuma user for %s\n' "$kuma_username" >&2
  exit 1
fi

sync_http_monitor() {
  local name="$1"
  local url="$2"
  local description="$3"
  local name_sql url_sql description_sql monitor_id

  name_sql="$(sql_escape "$name")"
  url_sql="$(sql_escape "$url")"
  description_sql="$(sql_escape "$description")"
  monitor_id="$(
    sqlite_query "select id from monitor where user_id=${kuma_user_id} and name='${name_sql}' order by id limit 1;"
  )"

  if [[ -n "$monitor_id" ]]; then
    sqlite_query "update monitor set active=1, interval=60, url='${url_sql}', type='http', maxretries=2, retry_interval=60, resend_interval=0, maxredirects=10, accepted_statuscodes_json='[\"200-399\"]', method='GET', description='${description_sql}', ignore_tls=0, upside_down=0, timeout=0 where id=${monitor_id};"
    sqlite_query "delete from monitor where user_id=${kuma_user_id} and name='${name_sql}' and id<>${monitor_id};"
  else
    sqlite_query "insert into monitor (name, active, user_id, interval, url, type, maxretries, retry_interval, resend_interval, maxredirects, accepted_statuscodes_json, method, description, ignore_tls, upside_down, timeout) values ('${name_sql}', 1, ${kuma_user_id}, 60, '${url_sql}', 'http', 2, 60, 0, 10, '[\"200-399\"]', 'GET', '${description_sql}', 0, 0, 0);"
  fi
}

sync_port_monitor() {
  local name="$1"
  local hostname="$2"
  local port="$3"
  local description="$4"
  local name_sql host_sql description_sql monitor_id

  name_sql="$(sql_escape "$name")"
  host_sql="$(sql_escape "$hostname")"
  description_sql="$(sql_escape "$description")"
  monitor_id="$(
    sqlite_query "select id from monitor where user_id=${kuma_user_id} and name='${name_sql}' order by id limit 1;"
  )"

  if [[ -n "$monitor_id" ]]; then
    sqlite_query "update monitor set active=1, interval=60, hostname='${host_sql}', port=${port}, type='port', maxretries=2, retry_interval=60, resend_interval=0, description='${description_sql}', upside_down=0, timeout=0 where id=${monitor_id};"
    sqlite_query "delete from monitor where user_id=${kuma_user_id} and name='${name_sql}' and id<>${monitor_id};"
  else
    sqlite_query "insert into monitor (name, active, user_id, interval, hostname, port, type, maxretries, retry_interval, resend_interval, description, upside_down, timeout) values ('${name_sql}', 1, ${kuma_user_id}, 60, '${host_sql}', ${port}, 'port', 2, 60, 0, '${description_sql}', 0, 0);"
  fi
}

sync_http_monitor "Landing (apex)" "https://${LANDING_HOST}" "Public landing page through Traefik."
sync_http_monitor "Landing (www)" "https://${LANDING_WWW_HOST}" "Public www alias through Traefik."
sync_http_monitor "Authentik" "https://${AUTH_HOST}" "Identity portal should stay reachable and redirect to the login flow."
sync_http_monitor "n8n" "https://${N8N_HOST}" "Automation editor and webhook UI."
sync_http_monitor "BookStack" "https://${DOCS_HOST}" "Knowledge base should redirect to login."
sync_http_monitor "Vikunja" "https://${TASKS_HOST}" "Task app should redirect to Authentik-backed login."
sync_http_monitor "EspoCRM" "https://${CRM_HOST}" "CRM frontend must stay reachable."
sync_http_monitor "Uptime Kuma" "https://${STATUS_HOST}" "Monitoring UI should redirect through Authentik."

sync_port_monitor "SSH" "${LANDING_HOST}" "22" "Host reachability for operator access."
sync_port_monitor "Postgres" "platform-postgres" "5432" "Internal shared Postgres container for n8n and Authentik."
sync_port_monitor "MariaDB" "platform-mariadb" "3306" "Internal shared MariaDB container for BookStack and EspoCRM."

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/configure_uptime_kuma_public_status_page.sh" "$stack_root"

docker compose --env-file "$monitoring_env" -f "$monitoring_compose" restart uptime-kuma >/dev/null

printf 'configured Kuma monitors for user %s (%s)\n' "$kuma_username" "$kuma_user_id"
