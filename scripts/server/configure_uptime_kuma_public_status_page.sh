#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
core_env="${stack_root}/core/.env"
business_env="${stack_root}/business/.env"
monitoring_env="${stack_root}/monitoring/.env"

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

sqlite_query() {
  local sql="$1"
  printf '%s\n' "$sql" | docker exec -i uptime-kuma sh -lc 'sqlite3 /app/data/kuma.db'
}

require_file "$core_env"
require_file "$business_env"
require_file "$monitoring_env"

set -a
. "$core_env"
. "$business_env"
. "$monitoring_env"
set +a

public_slug="public"
public_title="Public"
public_description="Selected external-facing services for the SME demo stack."
public_footer="Generated from the repo-backed stack workflow."
public_group_name="Public Services"

public_monitor_names=(
  "Landing (apex)"
  "n8n"
  "BookStack"
  "Vikunja"
  "EspoCRM"
)

status_page_id="$(
  sqlite_query "select id from status_page where slug='${public_slug}' order by id limit 1;"
)"

public_title_sql="$(sql_escape "$public_title")"
public_description_sql="$(sql_escape "$public_description")"
public_footer_sql="$(sql_escape "$public_footer")"
public_group_name_sql="$(sql_escape "$public_group_name")"

if [[ -n "$status_page_id" ]]; then
  sqlite_query "update status_page set title='${public_title_sql}', description='${public_description_sql}', icon='/icon.svg', theme='light', published=1, search_engine_index=0, show_tags=0, footer_text='${public_footer_sql}', custom_css='', show_powered_by=0, show_certificate_expiry=1, modified_date=CURRENT_TIMESTAMP where id=${status_page_id};"
else
  sqlite_query "insert into status_page (slug, title, description, icon, theme, published, search_engine_index, show_tags, footer_text, custom_css, show_powered_by, show_certificate_expiry) values ('${public_slug}', '${public_title_sql}', '${public_description_sql}', '/icon.svg', 'light', 1, 0, 0, '${public_footer_sql}', '', 0, 1);"
  status_page_id="$(
    sqlite_query "select id from status_page where slug='${public_slug}' order by id limit 1;"
  )"
fi

[[ -n "$status_page_id" ]] || {
  printf 'failed to create or locate Kuma status page %s\n' "$public_slug" >&2
  exit 1
}

group_id="$(
  sqlite_query "select id from \"group\" where status_page_id=${status_page_id} and public=1 and name='${public_group_name_sql}' order by id limit 1;"
)"

if [[ -n "$group_id" ]]; then
  sqlite_query "update \"group\" set name='${public_group_name_sql}', public=1, active=1, weight=1, status_page_id=${status_page_id} where id=${group_id};"
else
  sqlite_query "insert into \"group\" (name, public, active, weight, status_page_id) values ('${public_group_name_sql}', 1, 1, 1, ${status_page_id});"
  group_id="$(
    sqlite_query "select id from \"group\" where status_page_id=${status_page_id} and public=1 and name='${public_group_name_sql}' order by id limit 1;"
  )"
fi

[[ -n "$group_id" ]] || {
  printf 'failed to create or locate Kuma public group\n' >&2
  exit 1
}

sqlite_query "delete from monitor_group where group_id=${group_id};"
sqlite_query "delete from monitor_group where group_id in (select id from \"group\" where status_page_id=${status_page_id} and id<>${group_id});"
sqlite_query "delete from \"group\" where status_page_id=${status_page_id} and id<>${group_id};"

monitor_order=1
for monitor_name in "${public_monitor_names[@]}"; do
  monitor_name_sql="$(sql_escape "$monitor_name")"
  monitor_id="$(
    sqlite_query "select id from monitor where name='${monitor_name_sql}' order by id limit 1;"
  )"

  [[ -n "$monitor_id" ]] || {
    printf 'missing Kuma monitor required for public page: %s\n' "$monitor_name" >&2
    exit 1
  }

  sqlite_query "insert into monitor_group (monitor_id, group_id, weight, send_url) values (${monitor_id}, ${group_id}, ${monitor_order}, 0);"
  monitor_order=$((monitor_order + 1))
done

printf 'configured Kuma public status page at https://%s/status/%s\n' "${STATUS_HOST}" "${public_slug}"
