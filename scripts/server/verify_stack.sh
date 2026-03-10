#!/usr/bin/env bash
set -euo pipefail

wait_for_http_match() {
  local url="$1"
  local pattern="$2"
  local attempts="${3:-12}"
  local delay="${4:-5}"
  local output=""
  local attempt

  for (( attempt = 1; attempt <= attempts; attempt++ )); do
    output="$(curl -ksSI "$url" || true)"
    if printf '%s\n' "$output" | grep -Eq "$pattern"; then
      printf '%s\n' "$output"
      return 0
    fi
    sleep "$delay"
  done

  printf '%s\n' "$output"
  return 1
}

echo "== Host =="
hostnamectl --static
date -Iseconds

echo "== Services =="
systemctl is-active docker fail2ban auditd selfhost-backup.timer

echo "== Containers =="
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo "== Firewall =="
ufw status numbered

echo "== Backup timer =="
systemctl status selfhost-backup.timer --no-pager -l | sed -n '1,40p'

echo "== Shell policy =="
sed -n '1,40p' /etc/profile.d/10-history-settings.sh
sed -n '1,40p' /etc/profile.d/20-selfhost-prompt.sh

echo "== Recent tlog =="
journalctl -t tlog-rec-session -n 3 --no-pager || true

if [[ -f /opt/stacks/business/config/vikunja/config.yml ]]; then
  echo "== SSO config =="
  grep -n '^BOOKSTACK_OIDC_\(ISSUER\|CLIENT_ID\)=' /opt/stacks/business/.env || true
  grep -n '^ESPOCRM_OIDC_\(ISSUER\|CLIENT_ID\)=' /opt/stacks/business/.env || true
  sed -n '1,80p' /opt/stacks/business/config/vikunja/config.yml \
    | sed -E 's#(jwtsecret: ).*#\1[redacted]#; s#(clientsecret: ).*#\1[redacted]#'
  docker exec espocrm php -r '$config = include "/var/www/html/data/config.php"; foreach (["authenticationMethod","oidcClientId","oidcAuthorizationEndpoint","oidcJwksEndpoint","oidcUsernameClaim","oidcGroupClaim","oidcSyncTeams"] as $key) { if (array_key_exists($key, $config)) { echo $key . "=" . (is_array($config[$key]) ? json_encode($config[$key]) : (is_bool($config[$key]) ? ($config[$key] ? "true" : "false") : $config[$key])) . PHP_EOL; } }' \
    | sed -E 's#(oidcClientId=).*#\1[redacted-client-id]#'
fi

if [[ -f /opt/stacks/monitoring/.env ]]; then
  echo "== Monitoring auth =="
  set -a
  source /opt/stacks/monitoring/.env
  set +a
  printf 'STATUS_HOST=%s\n' "${STATUS_HOST:-}"
  wait_for_http_match "https://${STATUS_HOST}/login" '^HTTP/.* 200' | sed -n '1,8p'
  wait_for_http_match "https://${STATUS_HOST}/api/health" '^HTTP/.* 200' | sed -n '1,8p'
  echo "== Prometheus config =="
  docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
  echo "== Active targets =="
  docker exec prometheus wget -qO- http://127.0.0.1:9090/api/v1/targets \
    | jq -r '.data.activeTargets[] | [.labels.job, .labels.service, .discoveredLabels.__param_target, .health] | @tsv'
  echo "== HTTP targets =="
  docker exec prometheus cat /etc/prometheus/targets/http.yml
  echo "== TCP targets =="
  docker exec prometheus cat /etc/prometheus/targets/tcp.yml
fi
