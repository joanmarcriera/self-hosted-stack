#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
handoff_env_path="${3:-/opt/stacks/secrets/server-reset-handoff.env}"

if [[ -f "$handoff_env_path" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$handoff_env_path"
  set +a
fi

base_domain="${BASE_DOMAIN:-${1:-example.com}}"
owner_email="${OWNER_EMAIL:-${2:-founder@example.com}}"
stack_tz="${TZ:-Europe/London}"

write_if_missing() {
  local file="$1"
  local content="$2"
  local old_umask
  if [[ ! -f "$file" ]]; then
    old_umask="$(umask)"
    umask 077
    printf '%s\n' "$content" >"$file"
    umask "$old_umask"
  fi
}

rand_hex() {
  openssl rand -hex "$1"
}

rand_b64() {
  openssl rand -base64 "$1" | tr -d '\n'
}

read_existing_value() {
  local file="$1"
  local key="$2"
  [[ -f "$file" ]] || return 1
  awk -F= -v key="$key" '$1 == key {print substr($0, length(key) + 2); exit}' "$file"
}

existing_or_value() {
  local file="$1"
  local key="$2"
  local fallback="$3"
  local existing=""
  existing="$(read_existing_value "$file" "$key" || true)"
  if [[ -n "$existing" ]]; then
    printf '%s' "$existing"
  else
    printf '%s' "$fallback"
  fi
}

render_template() {
  local template_path="$1"
  sed \
    -e "s|__BASE_DOMAIN__|${base_domain}|g" \
    -e "s|__AUTH_URL__|https://auth.${base_domain}|g" \
    -e "s|__N8N_URL__|https://n8n.${base_domain}|g" \
    -e "s|__DOCS_URL__|https://docs.${base_domain}|g" \
    -e "s|__TASKS_URL__|https://tasks.${base_domain}|g" \
    -e "s|__CRM_URL__|https://crm.${base_domain}|g" \
    -e "s|__STATUS_URL__|https://status.${base_domain}|g" \
    -e "s|__PUBLIC_STATUS_URL__|https://status.${base_domain}/d/stack-overview/stack-overview|g" \
    "$template_path"
}

postgres_password="$(existing_or_value /opt/stacks/platform/.env POSTGRES_PASSWORD "${POSTGRES_PASSWORD:-$(rand_hex 16)}")"
authentik_db_password="$(existing_or_value /opt/stacks/platform/.env AUTHENTIK_DB_PASSWORD "${AUTHENTIK_DB_PASSWORD:-$(rand_hex 16)}")"
n8n_db_password="$(existing_or_value /opt/stacks/platform/.env N8N_DB_PASSWORD "${N8N_DB_PASSWORD:-$(rand_hex 16)}")"
mariadb_root_password="$(existing_or_value /opt/stacks/platform/.env MARIADB_ROOT_PASSWORD "${MARIADB_ROOT_PASSWORD:-$(rand_hex 16)}")"
bookstack_db_password="$(existing_or_value /opt/stacks/platform/.env BOOKSTACK_DB_PASSWORD "${BOOKSTACK_DB_PASSWORD:-$(rand_hex 16)}")"
espocrm_db_password="$(existing_or_value /opt/stacks/platform/.env ESPOCRM_DB_PASSWORD "${ESPOCRM_DB_PASSWORD:-$(rand_hex 16)}")"
authentik_secret_key="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_SECRET_KEY "${AUTHENTIK_SECRET_KEY:-$(rand_b64 60)}")"
authentik_bootstrap_password="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_BOOTSTRAP_PASSWORD "${AUTHENTIK_BOOTSTRAP_PASSWORD:-$(rand_hex 12)}")"
authentik_bootstrap_token="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_BOOTSTRAP_TOKEN "${AUTHENTIK_BOOTSTRAP_TOKEN:-$(rand_hex 24)}")"
authentik_email_host="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_HOST "${AUTHENTIK_EMAIL_HOST:-localhost}")"
authentik_email_port="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_PORT "${AUTHENTIK_EMAIL_PORT:-25}")"
authentik_email_username="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_USERNAME "${AUTHENTIK_EMAIL_USERNAME:-}")"
authentik_email_password="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_PASSWORD "${AUTHENTIK_EMAIL_PASSWORD:-}")"
authentik_email_use_tls="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_USE_TLS "${AUTHENTIK_EMAIL_USE_TLS:-false}")"
authentik_email_use_ssl="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_USE_SSL "${AUTHENTIK_EMAIL_USE_SSL:-false}")"
authentik_email_timeout="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_TIMEOUT "${AUTHENTIK_EMAIL_TIMEOUT:-10}")"
authentik_email_from="$(existing_or_value /opt/stacks/identity/.env AUTHENTIK_EMAIL_FROM "${AUTHENTIK_EMAIL_FROM:-${owner_email}}")"
n8n_basic_auth_password="$(existing_or_value /opt/stacks/automation/.env N8N_BASIC_AUTH_PASSWORD "${N8N_BASIC_AUTH_PASSWORD:-$(rand_hex 12)}")"
n8n_encryption_key="$(existing_or_value /opt/stacks/automation/.env N8N_ENCRYPTION_KEY "${N8N_ENCRYPTION_KEY:-$(rand_hex 32)}")"
bookstack_app_key="$(existing_or_value /opt/stacks/business/.env BOOKSTACK_APP_KEY "${BOOKSTACK_APP_KEY:-base64:$(rand_b64 32)}")"
bookstack_oidc_issuer="$(existing_or_value /opt/stacks/business/.env BOOKSTACK_OIDC_ISSUER "${BOOKSTACK_OIDC_ISSUER:-https://auth.${base_domain}/application/o/bookstack/}")"
bookstack_oidc_client_id="$(existing_or_value /opt/stacks/business/.env BOOKSTACK_OIDC_CLIENT_ID "${BOOKSTACK_OIDC_CLIENT_ID:-bookstack-oidc}")"
bookstack_oidc_client_secret="$(existing_or_value /opt/stacks/business/.env BOOKSTACK_OIDC_CLIENT_SECRET "${BOOKSTACK_OIDC_CLIENT_SECRET:-$(rand_hex 24)}")"
espocrm_admin_username="$(existing_or_value /opt/stacks/business/.env ESPOCRM_ADMIN_USERNAME "${ESPOCRM_ADMIN_USERNAME:-admin}")"
espocrm_admin_password="$(existing_or_value /opt/stacks/business/.env ESPOCRM_ADMIN_PASSWORD "${ESPOCRM_ADMIN_PASSWORD:-$(rand_hex 12)}")"
espocrm_oidc_issuer="$(existing_or_value /opt/stacks/business/.env ESPOCRM_OIDC_ISSUER "${ESPOCRM_OIDC_ISSUER:-https://auth.${base_domain}/application/o/espocrm/}")"
espocrm_oidc_client_id="$(existing_or_value /opt/stacks/business/.env ESPOCRM_OIDC_CLIENT_ID "${ESPOCRM_OIDC_CLIENT_ID:-espocrm-oidc}")"
espocrm_oidc_client_secret="$(existing_or_value /opt/stacks/business/.env ESPOCRM_OIDC_CLIENT_SECRET "${ESPOCRM_OIDC_CLIENT_SECRET:-$(rand_hex 24)}")"
vikunja_jwt_secret="$(existing_or_value /opt/stacks/business/.env VIKUNJA_JWT_SECRET "${VIKUNJA_JWT_SECRET:-$(rand_hex 32)}")"
vikunja_oidc_client_id="$(existing_or_value /opt/stacks/business/.env VIKUNJA_OIDC_CLIENT_ID "${VIKUNJA_OIDC_CLIENT_ID:-vikunja-oidc}")"
vikunja_oidc_client_secret="$(existing_or_value /opt/stacks/business/.env VIKUNJA_OIDC_CLIENT_SECRET "${VIKUNJA_OIDC_CLIENT_SECRET:-$(rand_hex 24)}")"
grafana_admin_user="$(existing_or_value /opt/stacks/monitoring/.env GRAFANA_ADMIN_USER "${GRAFANA_ADMIN_USER:-${KUMA_ADMIN_USERNAME:-admin}}")"
grafana_admin_password="$(existing_or_value /opt/stacks/monitoring/.env GRAFANA_ADMIN_PASSWORD "${GRAFANA_ADMIN_PASSWORD:-${KUMA_ADMIN_PASSWORD:-$(rand_hex 12)}}")"
grafana_oidc_client_id="$(existing_or_value /opt/stacks/monitoring/.env GRAFANA_OIDC_CLIENT_ID "${GRAFANA_OIDC_CLIENT_ID:-grafana-oidc}")"
grafana_oidc_client_secret="$(existing_or_value /opt/stacks/monitoring/.env GRAFANA_OIDC_CLIENT_SECRET "${GRAFANA_OIDC_CLIENT_SECRET:-$(rand_hex 24)}")"

core_env=$(cat <<EOF
BASE_DOMAIN=${base_domain}
ACME_EMAIL=${owner_email}
AUTH_HOST=auth.${base_domain}
LANDING_HOST=${base_domain}
LANDING_WWW_HOST=www.${base_domain}
EOF
)

platform_env=$(cat <<EOF
TZ=${stack_tz}
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=${postgres_password}
AUTHENTIK_DB_NAME=authentik
AUTHENTIK_DB_USER=authentik
AUTHENTIK_DB_PASSWORD=${authentik_db_password}
N8N_DB_NAME=n8n
N8N_DB_USER=n8n
N8N_DB_PASSWORD=${n8n_db_password}
MARIADB_ROOT_PASSWORD=${mariadb_root_password}
BOOKSTACK_DB_NAME=bookstack
BOOKSTACK_DB_USER=bookstack
BOOKSTACK_DB_PASSWORD=${bookstack_db_password}
ESPOCRM_DB_NAME=espocrm
ESPOCRM_DB_USER=espocrm
ESPOCRM_DB_PASSWORD=${espocrm_db_password}
EOF
)

identity_env=$(cat <<EOF
AUTH_HOST=auth.${base_domain}
STATUS_HOST=status.${base_domain}
AUTHENTIK_SECRET_KEY=${authentik_secret_key}
AUTHENTIK_DB_NAME=authentik
AUTHENTIK_DB_USER=authentik
AUTHENTIK_DB_PASSWORD=${authentik_db_password}
AUTHENTIK_BOOTSTRAP_EMAIL=${owner_email}
AUTHENTIK_BOOTSTRAP_PASSWORD=${authentik_bootstrap_password}
AUTHENTIK_BOOTSTRAP_TOKEN=${authentik_bootstrap_token}
AUTHENTIK_EMAIL_HOST=${authentik_email_host}
AUTHENTIK_EMAIL_PORT=${authentik_email_port}
AUTHENTIK_EMAIL_USERNAME=${authentik_email_username}
AUTHENTIK_EMAIL_PASSWORD=${authentik_email_password}
AUTHENTIK_EMAIL_USE_TLS=${authentik_email_use_tls}
AUTHENTIK_EMAIL_USE_SSL=${authentik_email_use_ssl}
AUTHENTIK_EMAIL_TIMEOUT=${authentik_email_timeout}
AUTHENTIK_EMAIL_FROM=${authentik_email_from}
EOF
)

automation_env=$(cat <<EOF
TZ=${stack_tz}
N8N_HOST=n8n.${base_domain}
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=${n8n_basic_auth_password}
N8N_ENCRYPTION_KEY=${n8n_encryption_key}
N8N_DB_NAME=n8n
N8N_DB_USER=n8n
N8N_DB_PASSWORD=${n8n_db_password}
EOF
)

business_env=$(cat <<EOF
TZ=${stack_tz}
DOCS_HOST=docs.${base_domain}
BOOKSTACK_APP_KEY=${bookstack_app_key}
BOOKSTACK_DB_NAME=bookstack
BOOKSTACK_DB_USER=bookstack
BOOKSTACK_DB_PASSWORD=${bookstack_db_password}
BOOKSTACK_OIDC_ISSUER=${bookstack_oidc_issuer}
BOOKSTACK_OIDC_CLIENT_ID=${bookstack_oidc_client_id}
BOOKSTACK_OIDC_CLIENT_SECRET=${bookstack_oidc_client_secret}
CRM_HOST=crm.${base_domain}
ESPOCRM_DB_NAME=espocrm
ESPOCRM_DB_USER=espocrm
ESPOCRM_DB_PASSWORD=${espocrm_db_password}
ESPOCRM_ADMIN_USERNAME=${espocrm_admin_username}
ESPOCRM_ADMIN_PASSWORD=${espocrm_admin_password}
ESPOCRM_OIDC_ISSUER=${espocrm_oidc_issuer}
ESPOCRM_OIDC_CLIENT_ID=${espocrm_oidc_client_id}
ESPOCRM_OIDC_CLIENT_SECRET=${espocrm_oidc_client_secret}
TASKS_HOST=tasks.${base_domain}
VIKUNJA_JWT_SECRET=${vikunja_jwt_secret}
VIKUNJA_OIDC_CLIENT_ID=${vikunja_oidc_client_id}
VIKUNJA_OIDC_CLIENT_SECRET=${vikunja_oidc_client_secret}
EOF
)

monitoring_env=$(cat <<EOF
STATUS_HOST=status.${base_domain}
AUTH_HOST=auth.${base_domain}
GRAFANA_ADMIN_USER=${grafana_admin_user}
GRAFANA_ADMIN_PASSWORD=${grafana_admin_password}
GRAFANA_FOUNDER_EMAIL=${owner_email}
GRAFANA_OIDC_CLIENT_ID=${grafana_oidc_client_id}
GRAFANA_OIDC_CLIENT_SECRET=${grafana_oidc_client_secret}
EOF
)

if [[ -n "${RESTIC_REPOSITORY:-}" || -n "${RESTIC_PASSWORD:-}" ]]; then
backup_env=$(cat <<EOF
RESTIC_REPOSITORY=${RESTIC_REPOSITORY:-}
RESTIC_PASSWORD=${RESTIC_PASSWORD:-}
EOF
)
else
backup_env=$(cat <<'EOF'
# Optional off-host restic target.
# RESTIC_REPOSITORY=s3:s3.amazonaws.com/your-bucket/selfhost
# RESTIC_PASSWORD=change-me
EOF
)
fi

vikunja_config=$(cat <<EOF
service:
  publicurl: https://tasks.${base_domain}/
  jwtsecret: ${vikunja_jwt_secret}
database:
  type: sqlite
  path: /db/vikunja.db
auth:
  openid:
    enabled: false
    providers: {}
EOF
)

write_if_missing /opt/stacks/core/.env "$core_env"
write_if_missing /opt/stacks/platform/.env "$platform_env"
write_if_missing /opt/stacks/identity/.env "$identity_env"
write_if_missing /opt/stacks/automation/.env "$automation_env"
write_if_missing /opt/stacks/business/.env "$business_env"
write_if_missing /opt/stacks/monitoring/.env "$monitoring_env"
write_if_missing /opt/stacks/backups/.env "$backup_env"

install -d -m 0755 \
  /opt/stacks/core/data/letsencrypt \
  /opt/stacks/core/site \
  /opt/stacks/platform/data/postgres \
  /opt/stacks/platform/data/mariadb \
  /opt/stacks/platform/initdb/postgres \
  /opt/stacks/platform/initdb/mariadb \
  /opt/stacks/identity/data/authentik \
  /opt/stacks/identity/custom-templates \
  /opt/stacks/automation/data/n8n \
  /opt/stacks/business/config/vikunja \
  /opt/stacks/business/data/bookstack \
  /opt/stacks/business/data/espocrm \
  /opt/stacks/business/data/vikunja/files \
  /opt/stacks/business/data/vikunja/db \
  /opt/stacks/monitoring/blackbox \
  /opt/stacks/monitoring/grafana/dashboards \
  /opt/stacks/monitoring/grafana/provisioning/dashboards \
  /opt/stacks/monitoring/grafana/provisioning/datasources \
  /opt/stacks/monitoring/prometheus/targets \
  /opt/stacks/monitoring/data/grafana \
  /opt/stacks/monitoring/data/prometheus \
  /opt/stacks/backups/runs

write_if_missing /opt/stacks/business/config/vikunja/config.yml "$vikunja_config"

chown -R 1000:1000 \
  /opt/stacks/automation/data/n8n \
  /opt/stacks/business/data/bookstack \
  /opt/stacks/business/data/vikunja

chown -R 472:472 /opt/stacks/monitoring/data/grafana
chown -R 65534:65534 /opt/stacks/monitoring/data/prometheus

chmod 600 /opt/stacks/core/.env \
  /opt/stacks/platform/.env \
  /opt/stacks/identity/.env \
  /opt/stacks/automation/.env \
  /opt/stacks/business/.env \
  /opt/stacks/monitoring/.env \
  /opt/stacks/backups/.env
chmod 0644 /opt/stacks/business/config/vikunja/config.yml

render_template "${script_dir}/templates/landing-page.html" >/opt/stacks/core/site/index.html
chmod 0644 /opt/stacks/core/site/index.html

cat >/opt/stacks/monitoring/prometheus/targets/http.yml <<EOF
- targets:
    - https://${base_domain}/
  labels:
    service: landing
- targets:
    - https://www.${base_domain}/
  labels:
    service: www
- targets:
    - https://auth.${base_domain}/if/flow/default-authentication-flow/
  labels:
    service: authentik
- targets:
    - https://n8n.${base_domain}/
  labels:
    service: n8n
- targets:
    - https://docs.${base_domain}/login
  labels:
    service: bookstack
- targets:
    - https://tasks.${base_domain}/api/v1/info
  labels:
    service: vikunja
- targets:
    - https://crm.${base_domain}/
  labels:
    service: espocrm
- targets:
    - https://status.${base_domain}/api/health
  labels:
    service: grafana
EOF
chmod 0644 /opt/stacks/monitoring/prometheus/targets/http.yml

cat >/opt/stacks/monitoring/prometheus/targets/tcp.yml <<EOF
- targets:
    - ${base_domain}:22
  labels:
    service: ssh
- targets:
    - platform-postgres:5432
  labels:
    service: postgres
- targets:
    - platform-mariadb:3306
  labels:
    service: mariadb
EOF
chmod 0644 /opt/stacks/monitoring/prometheus/targets/tcp.yml

cat >/opt/stacks/platform/initdb/postgres/10-create-app-dbs.sh <<EOF
#!/usr/bin/env bash
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "\$POSTGRES_USER" --dbname "\$POSTGRES_DB" <<SQL
DO \\$\\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'authentik') THEN
    CREATE ROLE authentik LOGIN PASSWORD '${authentik_db_password}';
  END IF;
END
\\$\\$;
SELECT 'CREATE DATABASE authentik OWNER authentik'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'authentik') \gexec

DO \\$\\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'n8n') THEN
    CREATE ROLE n8n LOGIN PASSWORD '${n8n_db_password}';
  END IF;
END
\\$\\$;
SELECT 'CREATE DATABASE n8n OWNER n8n'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n') \gexec
SQL
EOF
chmod +x /opt/stacks/platform/initdb/postgres/10-create-app-dbs.sh
chmod 0755 /opt/stacks/platform/initdb/postgres/10-create-app-dbs.sh

cat >/opt/stacks/platform/initdb/mariadb/10-create-app-dbs.sql <<EOF
CREATE DATABASE IF NOT EXISTS bookstack CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'bookstack'@'%' IDENTIFIED BY '${bookstack_db_password}';
GRANT ALL PRIVILEGES ON bookstack.* TO 'bookstack'@'%';

CREATE DATABASE IF NOT EXISTS espocrm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'espocrm'@'%' IDENTIFIED BY '${espocrm_db_password}';
GRANT ALL PRIVILEGES ON espocrm.* TO 'espocrm'@'%';

FLUSH PRIVILEGES;
EOF
chmod 0644 /opt/stacks/platform/initdb/mariadb/10-create-app-dbs.sql

printf 'rendered stack envs for %s\n' "$base_domain"
