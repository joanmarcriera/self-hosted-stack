#!/usr/bin/env bash
set -euo pipefail

ssh_target="${1:-root@joanmarcriera.es}"
output_dir="${2:-.secrets}"
handoff_env_path="${output_dir}/server-reset-handoff.env"
users_csv_path="${output_dir}/server-reset-users.csv"

install -d -m 0700 "$output_dir"

raw_dump="$(mktemp)"
trap 'rm -f "$raw_dump"' EXIT

ssh -o BatchMode=yes "$ssh_target" 'bash -s' >"$raw_dump" <<'EOF'
set -euo pipefail

read_env_value() {
  local file="$1"
  local key="$2"
  [[ -f "$file" ]] || return 0
  awk -F= -v key="$key" '$1 == key {print substr($0, length(key) + 2); exit}' "$file"
}

find_container() {
  local exact_name="$1"
  local pattern="$2"

  if docker inspect "$exact_name" >/dev/null 2>&1; then
    printf '%s\n' "$exact_name"
    return 0
  fi

  docker ps --format '{{.Names}}' | awk -v pattern="$pattern" '$0 ~ pattern { print; exit }'
}

print_env() {
  local key="$1"
  local value="$2"
  printf 'ENV\t%s\t%s\n' "$key" "$value"
}

base_domain="$(read_env_value /opt/stacks/core/.env BASE_DOMAIN)"
timezone_value="$(read_env_value /opt/stacks/platform/.env TZ)"
bootstrap_email="$(read_env_value /opt/stacks/identity/.env AUTHENTIK_BOOTSTRAP_EMAIL)"
postgres_container="$(find_container platform-postgres '(^|-)postgres($|-)')"
mariadb_container="$(find_container platform-mariadb '(^|-)mariadb($|-)')"
mariadb_root_password="$(read_env_value /opt/stacks/platform/.env MARIADB_ROOT_PASSWORD)"
[[ -n "$postgres_container" ]] || {
  printf 'missing postgres container on live host\n' >&2
  exit 1
}
n8n_owner_email="$(docker exec "$postgres_container" psql -U postgres -d n8n -At -c "select email from \"user\" where disabled = false and \"roleSlug\" = 'global:owner' order by \"createdAt\" asc limit 1;" || true)"

owner_row="$(docker exec "$postgres_container" psql -U postgres -d authentik -At -F $'\t' -c "
select coalesce(u.name, ''), coalesce(u.email, '')
from authentik_core_user u
join authentik_core_user_groups ug on ug.user_id = u.id
join authentik_core_group g on g.group_uuid = ug.group_id
where g.name = 'automation-founders'
  and u.username <> 'AnonymousUser'
  and u.username not like 'ak-outpost-%'
order by case when u.email = '${bootstrap_email}' then 0 else 1 end, u.id
limit 1;
")"

owner_name="${owner_row%%$'\t'*}"
owner_email="${owner_row#*$'\t'}"

if [[ -n "$mariadb_container" && -n "$mariadb_root_password" && -n "$owner_email" ]]; then
  bookstack_row="$(docker exec "$mariadb_container" mariadb -N -B -uroot "-p${mariadb_root_password}" bookstack -e "select name, email from users where email = '${owner_email}' order by id limit 1;" || true)"
  if [[ -n "$bookstack_row" ]]; then
    owner_name="${bookstack_row%%$'\t'*}"
  fi
fi

print_env BASE_DOMAIN "$base_domain"
print_env OWNER_NAME "$owner_name"
print_env OWNER_EMAIL "$owner_email"
print_env TZ "$timezone_value"
print_env AUTHENTIK_EMAIL_HOST "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_HOST)"
print_env AUTHENTIK_EMAIL_PORT "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_PORT)"
print_env AUTHENTIK_EMAIL_USERNAME "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_USERNAME)"
print_env AUTHENTIK_EMAIL_PASSWORD "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_PASSWORD)"
print_env AUTHENTIK_EMAIL_USE_TLS "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_USE_TLS)"
print_env AUTHENTIK_EMAIL_USE_SSL "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_USE_SSL)"
print_env AUTHENTIK_EMAIL_TIMEOUT "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_TIMEOUT)"
print_env AUTHENTIK_EMAIL_FROM "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_FROM)"
print_env N8N_OWNER_EMAIL "${n8n_owner_email:-$owner_email}"
print_env GRAFANA_ADMIN_USER "$(read_env_value /opt/stacks/monitoring/.env GRAFANA_ADMIN_USER)"
print_env GRAFANA_ADMIN_PASSWORD "$(read_env_value /opt/stacks/monitoring/.env GRAFANA_ADMIN_PASSWORD)"
print_env ESPOCRM_ADMIN_USERNAME "$(read_env_value /opt/stacks/business/.env ESPOCRM_ADMIN_USERNAME)"
print_env ESPOCRM_ADMIN_PASSWORD "$(read_env_value /opt/stacks/business/.env ESPOCRM_ADMIN_PASSWORD)"
print_env AUTHENTIK_BOOTSTRAP_PASSWORD "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_BOOTSTRAP_PASSWORD)"
print_env AUTHENTIK_BOOTSTRAP_TOKEN "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_BOOTSTRAP_TOKEN)"
print_env AUTHENTIK_SECRET_KEY "$(read_env_value /opt/stacks/identity/.env AUTHENTIK_SECRET_KEY)"
print_env N8N_BASIC_AUTH_PASSWORD "$(read_env_value /opt/stacks/automation/.env N8N_BASIC_AUTH_PASSWORD)"
print_env N8N_ENCRYPTION_KEY "$(read_env_value /opt/stacks/automation/.env N8N_ENCRYPTION_KEY)"
print_env BOOKSTACK_APP_KEY "$(read_env_value /opt/stacks/business/.env BOOKSTACK_APP_KEY)"
print_env BOOKSTACK_OIDC_CLIENT_ID "$(read_env_value /opt/stacks/business/.env BOOKSTACK_OIDC_CLIENT_ID)"
print_env BOOKSTACK_OIDC_CLIENT_SECRET "$(read_env_value /opt/stacks/business/.env BOOKSTACK_OIDC_CLIENT_SECRET)"
print_env ESPOCRM_OIDC_CLIENT_ID "$(read_env_value /opt/stacks/business/.env ESPOCRM_OIDC_CLIENT_ID)"
print_env ESPOCRM_OIDC_CLIENT_SECRET "$(read_env_value /opt/stacks/business/.env ESPOCRM_OIDC_CLIENT_SECRET)"
print_env VIKUNJA_JWT_SECRET "$(read_env_value /opt/stacks/business/.env VIKUNJA_JWT_SECRET)"
print_env VIKUNJA_OIDC_CLIENT_ID "$(read_env_value /opt/stacks/business/.env VIKUNJA_OIDC_CLIENT_ID)"
print_env VIKUNJA_OIDC_CLIENT_SECRET "$(read_env_value /opt/stacks/business/.env VIKUNJA_OIDC_CLIENT_SECRET)"
print_env GRAFANA_OIDC_CLIENT_ID "$(read_env_value /opt/stacks/monitoring/.env GRAFANA_OIDC_CLIENT_ID)"
print_env GRAFANA_OIDC_CLIENT_SECRET "$(read_env_value /opt/stacks/monitoring/.env GRAFANA_OIDC_CLIENT_SECRET)"
print_env RESTIC_REPOSITORY "$(read_env_value /opt/stacks/backups/.env RESTIC_REPOSITORY)"
print_env RESTIC_PASSWORD "$(read_env_value /opt/stacks/backups/.env RESTIC_PASSWORD)"

docker exec "$postgres_container" psql -U postgres -d authentik -At -F $'\t' -c "
select
  u.username,
  coalesce(u.name, ''),
  coalesce(u.email, ''),
  string_agg(g.name, ';' order by g.name)
from authentik_core_user u
join authentik_core_user_groups ug on ug.user_id = u.id
join authentik_core_group g on g.group_uuid = ug.group_id
where g.name like 'automation-%'
  and u.username <> 'AnonymousUser'
  and u.username not like 'ak-outpost-%'
group by u.id
order by u.id;
" | while IFS=$'\t' read -r username full_name email groups; do
  printf 'USER\t%s\t%s\t%s\t%s\n' "$username" "$full_name" "$email" "$groups"
done
EOF

python3 - "$raw_dump" "$handoff_env_path" "$users_csv_path" <<'PY'
import csv
import os
import shlex
import sys

raw_dump_path, handoff_env_path, users_csv_path = sys.argv[1:4]

env = {}
users = []

with open(raw_dump_path, encoding="utf-8") as handle:
    for raw_line in handle:
        line = raw_line.rstrip("\n")
        if not line:
            continue
        parts = line.split("\t")
        if parts[0] == "ENV" and len(parts) >= 3:
            env[parts[1]] = parts[2]
        elif parts[0] == "USER" and len(parts) >= 5:
            users.append(
                {
                    "username": parts[1],
                    "full_name": parts[2],
                    "email": parts[3],
                    "authentik_groups": parts[4],
                }
            )

owner_email = env.get("N8N_OWNER_EMAIL", "")

def env_line(key: str) -> str:
    value = env.get(key, "")
    return f"{key}={shlex.quote(value)}" if value else f"{key}="

env_lines = [
    "# Exported from the live server. Keep this file local in .secrets/.",
    "",
    env_line("BASE_DOMAIN"),
    env_line("OWNER_NAME"),
    env_line("OWNER_EMAIL"),
    env_line("TZ"),
    "",
    "# Authentik SMTP",
    env_line("AUTHENTIK_EMAIL_HOST"),
    env_line("AUTHENTIK_EMAIL_PORT"),
    env_line("AUTHENTIK_EMAIL_USERNAME"),
    env_line("AUTHENTIK_EMAIL_PASSWORD"),
    env_line("AUTHENTIK_EMAIL_USE_TLS"),
    env_line("AUTHENTIK_EMAIL_USE_SSL"),
    env_line("AUTHENTIK_EMAIL_TIMEOUT"),
    env_line("AUTHENTIK_EMAIL_FROM"),
    "",
    "# n8n owner identity after rebuild",
    env_line("N8N_OWNER_EMAIL"),
    "",
    "# Optional: keep deterministic local app access instead of rotating on rebuild",
    env_line("GRAFANA_ADMIN_USER"),
    env_line("GRAFANA_ADMIN_PASSWORD"),
    env_line("ESPOCRM_ADMIN_USERNAME"),
    env_line("ESPOCRM_ADMIN_PASSWORD"),
    "",
    "# Optional: preserve generated secrets instead of letting the scripts rotate them",
    env_line("AUTHENTIK_BOOTSTRAP_PASSWORD"),
    env_line("AUTHENTIK_BOOTSTRAP_TOKEN"),
    env_line("AUTHENTIK_SECRET_KEY"),
    env_line("N8N_BASIC_AUTH_PASSWORD"),
    env_line("N8N_ENCRYPTION_KEY"),
    env_line("BOOKSTACK_APP_KEY"),
    env_line("BOOKSTACK_OIDC_CLIENT_ID"),
    env_line("BOOKSTACK_OIDC_CLIENT_SECRET"),
    env_line("ESPOCRM_OIDC_CLIENT_ID"),
    env_line("ESPOCRM_OIDC_CLIENT_SECRET"),
    env_line("VIKUNJA_JWT_SECRET"),
    env_line("VIKUNJA_OIDC_CLIENT_ID"),
    env_line("VIKUNJA_OIDC_CLIENT_SECRET"),
    env_line("GRAFANA_OIDC_CLIENT_ID"),
    env_line("GRAFANA_OIDC_CLIENT_SECRET"),
    "",
    "# Optional off-host backup",
    env_line("RESTIC_REPOSITORY"),
    env_line("RESTIC_PASSWORD"),
    "",
]

with open(handoff_env_path, "w", encoding="utf-8") as handle:
    handle.write("\n".join(env_lines))

with open(users_csv_path, "w", newline="", encoding="utf-8") as handle:
    writer = csv.DictWriter(
        handle,
        fieldnames=[
            "username",
            "full_name",
            "email",
            "authentik_groups",
            "authentik_password",
            "n8n_access",
        ],
        lineterminator="\n",
    )
    writer.writeheader()
    for user in users:
        groups = [group for group in user["authentik_groups"].split(";") if group]
        if owner_email and user["email"] == owner_email:
            n8n_access = "owner"
        elif "automation-delivery" in groups:
            n8n_access = "editor"
        else:
            n8n_access = "none"
        writer.writerow(
            {
                "username": user["username"],
                "full_name": user["full_name"],
                "email": user["email"],
                "authentik_groups": user["authentik_groups"],
                "authentik_password": "set-before-reset",
                "n8n_access": n8n_access,
            }
        )

os.chmod(handoff_env_path, 0o600)
os.chmod(users_csv_path, 0o600)
PY

printf 'exported handoff files to %s and %s\n' "$handoff_env_path" "$users_csv_path"
