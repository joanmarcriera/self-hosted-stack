#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
owner_name="${2:-Joan Marc Riera}"

core_env="${stack_root}/core/.env"
platform_env="${stack_root}/platform/.env"
identity_env="${stack_root}/identity/.env"
business_env="${stack_root}/business/.env"
monitoring_env="${stack_root}/monitoring/.env"
identity_compose="${stack_root}/identity/docker-compose.yml"
business_compose="${stack_root}/business/docker-compose.yml"
monitoring_compose="${stack_root}/monitoring/docker-compose.yml"
vikunja_config_path="${stack_root}/business/config/vikunja/config.yml"

for file in "$core_env" "$platform_env" "$identity_env" "$business_env" "$monitoring_env" "$identity_compose" "$business_compose" "$monitoring_compose"; do
  [[ -f "$file" ]] || {
    printf 'missing required file: %s\n' "$file" >&2
    exit 1
  }
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bash "${script_dir}/wait_for_authentik_api.sh" "$stack_root" 24 5

set -a
source "$core_env"
source "$platform_env"
source "$identity_env"
source "$business_env"
source "$monitoring_env"
set +a

upsert_env_value() {
  local file="$1"
  local key="$2"
  local value="$3"
  local tmp
  tmp="$(mktemp)"
  awk -F= -v key="$key" -v value="$value" '
    BEGIN { updated = 0 }
    $1 == key {
      if (updated == 0) {
        print key "=" value
        updated = 1
      }
      next
    }
    { print }
    END {
      if (updated == 0) {
        print key "=" value
      }
    }
  ' "$file" >"$tmp"
  cat "$tmp" >"$file"
  rm -f "$tmp"
}

require_value() {
  local name="$1"
  local value="${!name:-}"
  [[ -n "$value" ]] || {
    printf 'missing required value: %s\n' "$name" >&2
    exit 1
  }
}

require_value AUTH_HOST
require_value AUTHENTIK_BOOTSTRAP_EMAIL
require_value AUTHENTIK_BOOTSTRAP_TOKEN
require_value DOCS_HOST
require_value CRM_HOST
require_value TASKS_HOST
require_value STATUS_HOST
require_value ESPOCRM_DB_NAME
require_value ESPOCRM_DB_USER
require_value ESPOCRM_DB_PASSWORD
require_value VIKUNJA_JWT_SECRET

bookstack_oidc_issuer="${BOOKSTACK_OIDC_ISSUER:-https://${AUTH_HOST}/application/o/bookstack/}"
bookstack_oidc_client_id="${BOOKSTACK_OIDC_CLIENT_ID:-bookstack-oidc}"
bookstack_oidc_client_secret="${BOOKSTACK_OIDC_CLIENT_SECRET:-$(openssl rand -hex 24)}"
espocrm_oidc_issuer="${ESPOCRM_OIDC_ISSUER:-https://${AUTH_HOST}/application/o/espocrm/}"
espocrm_oidc_client_id="${ESPOCRM_OIDC_CLIENT_ID:-espocrm-oidc}"
espocrm_oidc_client_secret="${ESPOCRM_OIDC_CLIENT_SECRET:-$(openssl rand -hex 24)}"
vikunja_oidc_client_id="${VIKUNJA_OIDC_CLIENT_ID:-vikunja-oidc}"
vikunja_oidc_client_secret="${VIKUNJA_OIDC_CLIENT_SECRET:-$(openssl rand -hex 24)}"
grafana_admin_user="${GRAFANA_ADMIN_USER:-${KUMA_ADMIN_USERNAME:-admin}}"
grafana_admin_password="${GRAFANA_ADMIN_PASSWORD:-${KUMA_ADMIN_PASSWORD:-$(openssl rand -hex 12)}}"
grafana_oidc_client_id="${GRAFANA_OIDC_CLIENT_ID:-grafana-oidc}"
grafana_oidc_client_secret="${GRAFANA_OIDC_CLIENT_SECRET:-$(openssl rand -hex 24)}"

upsert_env_value "$business_env" BOOKSTACK_OIDC_ISSUER "$bookstack_oidc_issuer"
upsert_env_value "$business_env" BOOKSTACK_OIDC_CLIENT_ID "$bookstack_oidc_client_id"
upsert_env_value "$business_env" BOOKSTACK_OIDC_CLIENT_SECRET "$bookstack_oidc_client_secret"
upsert_env_value "$business_env" ESPOCRM_OIDC_ISSUER "$espocrm_oidc_issuer"
upsert_env_value "$business_env" ESPOCRM_OIDC_CLIENT_ID "$espocrm_oidc_client_id"
upsert_env_value "$business_env" ESPOCRM_OIDC_CLIENT_SECRET "$espocrm_oidc_client_secret"
upsert_env_value "$business_env" VIKUNJA_OIDC_CLIENT_ID "$vikunja_oidc_client_id"
upsert_env_value "$business_env" VIKUNJA_OIDC_CLIENT_SECRET "$vikunja_oidc_client_secret"
upsert_env_value "$identity_env" STATUS_HOST "$STATUS_HOST"
upsert_env_value "$monitoring_env" AUTH_HOST "$AUTH_HOST"
upsert_env_value "$monitoring_env" GRAFANA_ADMIN_USER "$grafana_admin_user"
upsert_env_value "$monitoring_env" GRAFANA_ADMIN_PASSWORD "$grafana_admin_password"
upsert_env_value "$monitoring_env" GRAFANA_FOUNDER_EMAIL "$AUTHENTIK_BOOTSTRAP_EMAIL"
upsert_env_value "$monitoring_env" GRAFANA_OIDC_CLIENT_ID "$grafana_oidc_client_id"
upsert_env_value "$monitoring_env" GRAFANA_OIDC_CLIENT_SECRET "$grafana_oidc_client_secret"
chmod 600 "$business_env"
chmod 600 "$identity_env"
chmod 600 "$monitoring_env"

BOOKSTACK_OIDC_ISSUER="$bookstack_oidc_issuer"
BOOKSTACK_OIDC_CLIENT_ID="$bookstack_oidc_client_id"
BOOKSTACK_OIDC_CLIENT_SECRET="$bookstack_oidc_client_secret"
ESPOCRM_OIDC_ISSUER="$espocrm_oidc_issuer"
ESPOCRM_OIDC_CLIENT_ID="$espocrm_oidc_client_id"
ESPOCRM_OIDC_CLIENT_SECRET="$espocrm_oidc_client_secret"
VIKUNJA_OIDC_CLIENT_ID="$vikunja_oidc_client_id"
VIKUNJA_OIDC_CLIENT_SECRET="$vikunja_oidc_client_secret"
GRAFANA_ADMIN_USER="$grafana_admin_user"
GRAFANA_ADMIN_PASSWORD="$grafana_admin_password"
GRAFANA_OIDC_CLIENT_ID="$grafana_oidc_client_id"
GRAFANA_OIDC_CLIENT_SECRET="$grafana_oidc_client_secret"

auth_api_base="https://${AUTH_HOST}/api/v3"

api_get() {
  local path="$1"
  curl -ksS --fail-with-body \
    -H "Authorization: Bearer ${AUTHENTIK_BOOTSTRAP_TOKEN}" \
    "${auth_api_base}${path}"
}

api_write() {
  local method="$1"
  local path="$2"
  local payload="$3"
  curl -ksS --fail-with-body \
    -X "$method" \
    -H "Authorization: Bearer ${AUTHENTIK_BOOTSTRAP_TOKEN}" \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "${auth_api_base}${path}"
}

property_mappings_json="$(api_get "/propertymappings/all/?page_size=100")"
certificate_keypairs_json="$(api_get "/crypto/certificatekeypairs/?page_size=100")"
flows_json="$(api_get "/flows/instances/?page_size=100")"
groups_json="$(api_get "/core/groups/?page_size=100")"
providers_json="$(api_get "/providers/oauth2/?page_size=100")"
proxy_providers_json="$(api_get "/providers/proxy/?page_size=100")"
applications_json="$(api_get "/core/applications/?page_size=100")"
outposts_json="$(api_get "/outposts/instances/?page_size=100")"
me_json="$(api_get "/core/users/me/")"

current_user_pk="$(printf '%s' "$me_json" | jq -r '.user.pk')"
current_user_username="$(printf '%s' "$me_json" | jq -r '.user.username')"
auth_flow_id="$(printf '%s' "$flows_json" | jq -r '.results[] | select(.slug == "default-authentication-flow") | .pk')"
authz_flow_id="$(printf '%s' "$flows_json" | jq -r '.results[] | select(.slug == "default-provider-authorization-implicit-consent") | .pk')"
invalidation_flow_id="$(printf '%s' "$flows_json" | jq -r '.results[] | select(.slug == "default-provider-invalidation-flow") | .pk')"
signing_key_pk="$(printf '%s' "$certificate_keypairs_json" | jq -r '
  (.results[] | select(.name == "authentik Self-signed Certificate") | .pk),
  (.results[0].pk // empty)
' | head -n 1)"

require_value current_user_pk
require_value current_user_username
require_value auth_flow_id
require_value authz_flow_id
require_value invalidation_flow_id
require_value signing_key_pk

scope_mappings="$(printf '%s' "$property_mappings_json" | jq -c '
  [
    .results[]
    | select(
        .managed == "goauthentik.io/providers/oauth2/scope-openid" or
        .managed == "goauthentik.io/providers/oauth2/scope-email" or
        .managed == "goauthentik.io/providers/oauth2/scope-profile"
      )
    | .pk
  ] | unique
')"

ensure_group() {
  local group_name="$1"
  local add_user_pk="${2:-}"
  local group_json
  group_json="$(printf '%s' "$groups_json" | jq -c --arg group_name "$group_name" '.results[] | select(.name == $group_name)' | head -n 1)"
  if [[ -z "$group_json" ]]; then
    local payload
    if [[ -n "$add_user_pk" ]]; then
      payload="$(jq -n --arg name "$group_name" --argjson user_pk "$add_user_pk" '{name: $name, users: [$user_pk]}')"
    else
      payload="$(jq -n --arg name "$group_name" '{name: $name}')"
    fi
    api_write POST "/core/groups/" "$payload" >/dev/null
    groups_json="$(api_get "/core/groups/?page_size=100")"
    return
  fi

  if [[ -n "$add_user_pk" ]]; then
    local group_uuid users_json payload
    group_uuid="$(printf '%s' "$group_json" | jq -r '.pk')"
    users_json="$(printf '%s' "$group_json" | jq -c --argjson user_pk "$add_user_pk" '.users + [$user_pk] | unique')"
    payload="$(jq -n --arg name "$group_name" --argjson users "$users_json" '{name: $name, users: $users}')"
    api_write PATCH "/core/groups/${group_uuid}/" "$payload" >/dev/null
    groups_json="$(api_get "/core/groups/?page_size=100")"
  fi
}

upsert_provider() {
  local provider_name="$1"
  local client_id="$2"
  local client_secret="$3"
  local logout_uri="$4"
  local redirect_uris="$5"
  local provider_pk payload

  provider_pk="$(printf '%s' "$providers_json" | jq -r --arg provider_name "$provider_name" --arg client_id "$client_id" '
    .results[]
    | select(.name == $provider_name or .client_id == $client_id)
    | .pk
  ' | head -n 1)"

  payload="$(jq -n \
    --arg name "$provider_name" \
    --arg authentication_flow "$auth_flow_id" \
    --arg authorization_flow "$authz_flow_id" \
    --arg invalidation_flow "$invalidation_flow_id" \
    --arg client_id "$client_id" \
    --arg client_secret "$client_secret" \
    --arg logout_uri "$logout_uri" \
    --arg signing_key "$signing_key_pk" \
    --argjson property_mappings "$scope_mappings" \
    --argjson redirect_uris "$redirect_uris" \
    '{
      name: $name,
      authentication_flow: $authentication_flow,
      authorization_flow: $authorization_flow,
      invalidation_flow: $invalidation_flow,
      property_mappings: $property_mappings,
      client_type: "confidential",
      client_id: $client_id,
      client_secret: $client_secret,
      access_code_validity: "minutes=5",
      access_token_validity: "minutes=60",
      refresh_token_validity: "days=30",
      refresh_token_threshold: "seconds=0",
      include_claims_in_id_token: true,
      signing_key: $signing_key,
      redirect_uris: $redirect_uris,
      logout_uri: $logout_uri,
      logout_method: "frontchannel",
      sub_mode: "user_id",
      issuer_mode: "per_provider"
    }')"

  if [[ -n "$provider_pk" ]]; then
    api_write PATCH "/providers/oauth2/${provider_pk}/" "$payload" >/dev/null
  else
    api_write POST "/providers/oauth2/" "$payload" >/dev/null
  fi

  providers_json="$(api_get "/providers/oauth2/?page_size=100")"
  printf '%s' "$providers_json" | jq -r --arg provider_name "$provider_name" --arg client_id "$client_id" '
    .results[]
    | select(.name == $provider_name or .client_id == $client_id)
    | .pk
  ' | head -n 1
}

upsert_application() {
  local app_name="$1"
  local app_slug="$2"
  local provider_pk="$3"
  local launch_url="$4"
  local description="$5"
  local payload existing_slug

  payload="$(jq -n \
    --arg name "$app_name" \
    --arg slug "$app_slug" \
    --argjson provider "$provider_pk" \
    --arg launch_url "$launch_url" \
    --arg description "$description" \
    '{
      name: $name,
      slug: $slug,
      provider: $provider,
      open_in_new_tab: false,
      meta_launch_url: $launch_url,
      meta_description: $description,
      meta_publisher: "joanmarcriera.es",
      group: "SME Stack"
    }')"

  existing_slug="$(printf '%s' "$applications_json" | jq -r --arg slug "$app_slug" --arg launch_url "$launch_url" '
    .results[]
    | select(.slug == $slug or .meta_launch_url == $launch_url)
    | .slug
  ' | head -n 1)"

  if [[ -n "$existing_slug" ]]; then
    api_write PATCH "/core/applications/${existing_slug}/" "$payload" >/dev/null
  else
    api_write POST "/core/applications/" "$payload" >/dev/null
  fi

  applications_json="$(api_get "/core/applications/?page_size=100")"
}

upsert_proxy_provider() {
  local provider_name="$1"
  local external_host="$2"
  local mode="$3"
  local skip_path_regex="${4:-}"
  local provider_pk payload

  provider_pk="$(printf '%s' "$proxy_providers_json" | jq -r --arg provider_name "$provider_name" --arg external_host "$external_host" '
    .results[]
    | select(.name == $provider_name or .external_host == $external_host)
    | .pk
  ' | head -n 1)"

  payload="$(jq -n \
    --arg name "$provider_name" \
    --arg authentication_flow "$auth_flow_id" \
    --arg authorization_flow "$authz_flow_id" \
    --arg invalidation_flow "$invalidation_flow_id" \
    --arg external_host "$external_host" \
    --arg mode "$mode" \
    --arg skip_path_regex "$skip_path_regex" \
    '{
      name: $name,
      authentication_flow: $authentication_flow,
      authorization_flow: $authorization_flow,
      invalidation_flow: $invalidation_flow,
      external_host: $external_host,
      mode: $mode,
      access_token_validity: "minutes=5",
      refresh_token_validity: "days=30"
    } + (if $skip_path_regex != "" then {skip_path_regex: $skip_path_regex} else {} end)')"

  if [[ -n "$provider_pk" ]]; then
    api_write PATCH "/providers/proxy/${provider_pk}/" "$payload" >/dev/null
  else
    api_write POST "/providers/proxy/" "$payload" >/dev/null
  fi

  proxy_providers_json="$(api_get "/providers/proxy/?page_size=100")"
  printf '%s' "$proxy_providers_json" | jq -r --arg provider_name "$provider_name" --arg external_host "$external_host" '
    .results[]
    | select(.name == $provider_name or .external_host == $external_host)
    | .pk
  ' | head -n 1
}

ensure_outpost_provider() {
  local outpost_name="$1"
  local provider_pk="$2"
  local outpost_pk providers payload outpost_config

  outpost_pk="$(printf '%s' "$outposts_json" | jq -r --arg outpost_name "$outpost_name" '
    .results[]
    | select(.name == $outpost_name)
    | .pk
  ' | head -n 1)"
  [[ -n "$outpost_pk" ]] || {
    printf 'missing required outpost: %s\n' "$outpost_name" >&2
    exit 1
  }

  providers="$(printf '%s' "$outposts_json" | jq -c --arg outpost_name "$outpost_name" --argjson provider_pk "$provider_pk" '
    .results[]
    | select(.name == $outpost_name)
    | (.providers + [$provider_pk] | unique)
  ' | head -n 1)"
  outpost_config="$(printf '%s' "$outposts_json" | jq -c --arg outpost_name "$outpost_name" --arg auth_host "https://${AUTH_HOST}" '
    .results[]
    | select(.name == $outpost_name)
    | (.config // {}) + {
        authentik_host: $auth_host,
        authentik_host_browser: $auth_host
      }
  ' | head -n 1)"
  payload="$(jq -n --argjson providers "$providers" --argjson config "$outpost_config" '{providers: $providers, config: $config}')"
  api_write PATCH "/outposts/instances/${outpost_pk}/" "$payload" >/dev/null
  outposts_json="$(api_get "/outposts/instances/?page_size=100")"
}

espo_oidc_issuer_base="${ESPOCRM_OIDC_ISSUER%/}/"
espo_oidc_authorization_endpoint="https://${AUTH_HOST}/application/o/authorize/"
espo_oidc_token_endpoint="https://${AUTH_HOST}/application/o/token/"
espo_oidc_userinfo_endpoint="https://${AUTH_HOST}/application/o/userinfo/"
espo_oidc_jwks_endpoint="${espo_oidc_issuer_base}jwks/"
espo_oidc_logout_endpoint="${espo_oidc_issuer_base}end-session/"

mariadb_exec() {
  local sql="$1"
  docker exec platform-mariadb mariadb \
    -u"${ESPOCRM_DB_USER}" \
    -p"${ESPOCRM_DB_PASSWORD}" \
    "${ESPOCRM_DB_NAME}" \
    --batch --skip-column-names \
    -e "$sql"
}

bookstack_db_exec() {
  local sql="$1"
  docker exec platform-mariadb mariadb \
    -u"${BOOKSTACK_DB_USER}" \
    -p"${BOOKSTACK_DB_PASSWORD}" \
    "${BOOKSTACK_DB_NAME}" \
    --batch --skip-column-names \
    -e "$sql"
}

random_espo_id() {
  openssl rand -hex 9 | cut -c1-17
}

sql_escape() {
  printf '%s' "$1" | sed "s/'/''/g"
}

ensure_espocrm_team() {
  local name="$1"
  local team_id
  team_id="$(mariadb_exec "SELECT id FROM team WHERE deleted=0 AND name='${name}' LIMIT 1;")"
  if [[ -z "$team_id" ]]; then
    team_id="$(random_espo_id)"
    mariadb_exec "INSERT INTO team (id, name, deleted, created_at, modified_at) VALUES ('${team_id}', '${name}', 0, UTC_TIMESTAMP(), UTC_TIMESTAMP());"
  fi
  printf '%s' "$team_id"
}

ensure_espocrm_user_link() {
  local username="$1"
  local team_id="$2"
  local role="${3:-}"
  local user_id
  user_id="$(mariadb_exec "SELECT id FROM user WHERE deleted=0 AND user_name='${username}' LIMIT 1;")"
  [[ -n "$user_id" ]] || return 0

  mariadb_exec "UPDATE user SET default_team_id='${team_id}', modified_at=UTC_TIMESTAMP() WHERE id='${user_id}';"

  if [[ -n "$(mariadb_exec "SELECT id FROM team_user WHERE deleted=0 AND user_id='${user_id}' AND team_id='${team_id}' LIMIT 1;")" ]]; then
    mariadb_exec "UPDATE team_user SET role='${role}', deleted=0 WHERE user_id='${user_id}' AND team_id='${team_id}';"
  else
    mariadb_exec "INSERT INTO team_user (team_id, user_id, role, deleted) VALUES ('${team_id}', '${user_id}', '${role}', 0);"
  fi
}

ensure_group "automation-founders" "$current_user_pk"
ensure_group "automation-delivery"
ensure_group "automation-ops"

bookstack_redirects="$(jq -c -n --arg base "https://${DOCS_HOST}" '[
  {matching_mode: "strict", url: ($base + "/oidc/callback")},
  {matching_mode: "strict", url: ($base + "/oidc/callback/")}
]')"
vikunja_redirects="$(jq -c -n --arg url "https://${TASKS_HOST}/auth/openid/authentik" '[
  {matching_mode: "strict", url: $url}
]')"
grafana_redirects="$(jq -c -n --arg url "https://${STATUS_HOST}/login/generic_oauth" '[
  {matching_mode: "strict", url: $url}
]')"

bookstack_provider_pk="$(upsert_provider \
  "BookStack OIDC" \
  "${BOOKSTACK_OIDC_CLIENT_ID}" \
  "${BOOKSTACK_OIDC_CLIENT_SECRET}" \
  "https://${DOCS_HOST}/login?prevent_auto_init=true" \
  "${bookstack_redirects}")"

vikunja_provider_pk="$(upsert_provider \
  "Vikunja OIDC" \
  "${VIKUNJA_OIDC_CLIENT_ID}" \
  "${VIKUNJA_OIDC_CLIENT_SECRET}" \
  "https://${TASKS_HOST}/login" \
  "${vikunja_redirects}")"

espocrm_redirects="$(jq -c -n --arg url "https://${CRM_HOST}/oauth-callback.php" '[
  {matching_mode: "strict", url: $url}
]')"

espocrm_provider_pk="$(upsert_provider \
  "EspoCRM OIDC" \
  "${ESPOCRM_OIDC_CLIENT_ID}" \
  "${ESPOCRM_OIDC_CLIENT_SECRET}" \
  "https://${CRM_HOST}/" \
  "${espocrm_redirects}")"

grafana_provider_pk="$(upsert_provider \
  "Grafana OIDC" \
  "${GRAFANA_OIDC_CLIENT_ID}" \
  "${GRAFANA_OIDC_CLIENT_SECRET}" \
  "https://${STATUS_HOST}/logout" \
  "${grafana_redirects}")"

upsert_application \
  "BookStack" \
  "bookstack" \
  "${bookstack_provider_pk}" \
  "https://${DOCS_HOST}" \
  "Shared SOPs, handover notes, and client-facing project docs."

upsert_application \
  "Vikunja" \
  "vikunja" \
  "${vikunja_provider_pk}" \
  "https://${TASKS_HOST}" \
  "Task execution board for the 3-person automation consultancy demo."

upsert_application \
  "EspoCRM" \
  "espocrm" \
  "${espocrm_provider_pk}" \
  "https://${CRM_HOST}" \
  "Commercial memory for leads, companies, deals, and client relationships."

upsert_application \
  "Grafana" \
  "grafana" \
  "${grafana_provider_pk}" \
  "https://${STATUS_HOST}" \
  "Monitoring dashboards for service health, TLS posture, and future funnel metrics."

install -d -m 0755 "$(dirname "${vikunja_config_path}")"
cat >"${vikunja_config_path}" <<EOF
service:
  publicurl: https://${TASKS_HOST}/
  jwtsecret: ${VIKUNJA_JWT_SECRET}
database:
  type: sqlite
  path: /db/vikunja.db
auth:
  local:
    enabled: false
  openid:
    enabled: true
    providers:
      authentik:
        name: Login with Authentik
        authurl: https://${AUTH_HOST}/application/o/vikunja/
        clientid: ${VIKUNJA_OIDC_CLIENT_ID}
        clientsecret: ${VIKUNJA_OIDC_CLIENT_SECRET}
        scope: openid profile email
        forceuserinfo: false
        emailfallback: true
        usernamefallback: true
EOF
chmod 0644 "${vikunja_config_path}"

founders_team_id="$(ensure_espocrm_team "Founders")"
delivery_team_id="$(ensure_espocrm_team "Delivery")"
ops_team_id="$(ensure_espocrm_team "Operations")"

mariadb_exec "UPDATE user SET user_name='${current_user_username}', modified_at=UTC_TIMESTAMP() WHERE type='admin' AND deleted=0 AND user_name <> '${current_user_username}';"
ensure_espocrm_user_link "${current_user_username}" "${founders_team_id}" "Manager"

docker exec -u www-data -i espocrm php <<PHP
<?php
\$configFile = '/var/www/html/data/config.php';
\$config = include \$configFile;
\$teamColumns = new stdClass();
\$teamColumns->{'${founders_team_id}'} = (object) ['group' => 'automation-founders'];
\$teamColumns->{'${delivery_team_id}'} = (object) ['group' => 'automation-delivery'];
\$teamColumns->{'${ops_team_id}'} = (object) ['group' => 'automation-ops'];

\$config['siteUrl'] = 'https://${CRM_HOST}';
\$config['authenticationMethod'] = 'Oidc';
\$config['oidcClientId'] = '${ESPOCRM_OIDC_CLIENT_ID}';
\$config['oidcClientSecret'] = '${ESPOCRM_OIDC_CLIENT_SECRET}';
\$config['oidcAuthorizationEndpoint'] = '${espo_oidc_authorization_endpoint}';
\$config['oidcTokenEndpoint'] = '${espo_oidc_token_endpoint}';
\$config['oidcUserInfoEndpoint'] = '${espo_oidc_userinfo_endpoint}';
\$config['oidcJwksEndpoint'] = '${espo_oidc_jwks_endpoint}';
\$config['oidcJwtSignatureAlgorithmList'] = ['RS256'];
\$config['oidcScopes'] = ['profile', 'email'];
\$config['oidcGroupClaim'] = 'groups';
\$config['oidcCreateUser'] = true;
\$config['oidcUsernameClaim'] = 'preferred_username';
\$config['oidcSync'] = true;
\$config['oidcSyncTeams'] = true;
\$config['oidcTeamsIds'] = ['${founders_team_id}', '${delivery_team_id}', '${ops_team_id}'];
\$config['oidcTeamsColumns'] = \$teamColumns;
\$config['oidcFallback'] = false;
\$config['oidcAllowRegularUserFallback'] = false;
\$config['oidcAllowAdminUser'] = true;
\$config['oidcAuthorizationPrompt'] = 'consent';
\$config['oidcLogoutUrl'] = '${espo_oidc_logout_endpoint}';

\$export = var_export(\$config, true);
file_put_contents(\$configFile, "<?php\nreturn " . \$export . ";\n");
PHP

bookstack_owner_exists="$(
  bookstack_db_exec "SELECT COUNT(*) FROM users WHERE email='${AUTHENTIK_BOOTSTRAP_EMAIL}' OR external_auth_id='${AUTHENTIK_BOOTSTRAP_EMAIL}';"
)"
if [[ "${bookstack_owner_exists}" == "0" ]]; then
  docker exec bookstack php /app/www/artisan bookstack:create-admin \
    --initial \
    --email "${AUTHENTIK_BOOTSTRAP_EMAIL}" \
    --name "${owner_name}" \
    --external-auth-id "${AUTHENTIK_BOOTSTRAP_EMAIL}" \
    --generate-password \
    --no-interaction >/dev/null
fi

docker compose --env-file "${business_env}" -f "${business_compose}" up -d bookstack vikunja espocrm espocrm-daemon
docker exec espocrm php /var/www/html/command.php clear-cache >/dev/null
docker compose --env-file "${identity_env}" -f "${identity_compose}" up -d authentik-server
docker compose --env-file "${monitoring_env}" -f "${monitoring_compose}" up -d grafana prometheus blackbox-exporter

printf 'configured SSO for BookStack, Vikunja, EspoCRM, and Grafana\n'
