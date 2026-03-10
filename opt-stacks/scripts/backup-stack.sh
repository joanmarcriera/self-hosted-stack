#!/usr/bin/env bash
set -euo pipefail

timestamp="$(date -u +%F-%H%M%S)"
backup_root="/opt/stacks/backups"
run_dir="${backup_root}/runs/${timestamp}"
mkdir -p "$run_dir"

if docker ps --format '{{.Names}}' | grep -qx 'platform-postgres'; then
  docker exec platform-postgres pg_dumpall -U postgres > "${run_dir}/postgres-all.sql"
fi

if docker ps --format '{{.Names}}' | grep -qx 'platform-mariadb'; then
  docker exec platform-mariadb sh -lc 'exec mariadb-dump -uroot -p"$MARIADB_ROOT_PASSWORD" --all-databases' > "${run_dir}/mariadb-all.sql"
fi

tar -czf "${run_dir}/opt-stacks-config.tgz" /opt/stacks/core /opt/stacks/platform /opt/stacks/identity /opt/stacks/automation /opt/stacks/business /opt/stacks/monitoring
tar -czf "${run_dir}/app-data.tgz" \
  /opt/stacks/identity/data \
  /opt/stacks/automation/data \
  /opt/stacks/business/data \
  /opt/stacks/monitoring/data

find "${backup_root}/runs" -mindepth 1 -maxdepth 1 -type d -mtime +14 -exec rm -rf {} +

if [[ -f "${backup_root}/.env" ]]; then
  # shellcheck disable=SC1091
  source "${backup_root}/.env"
  if [[ -n "${RESTIC_REPOSITORY:-}" && -n "${RESTIC_PASSWORD:-}" ]]; then
    export RESTIC_REPOSITORY RESTIC_PASSWORD
    restic backup "${run_dir}"
    restic forget --keep-daily 7 --keep-weekly 4 --prune
  fi
fi

printf 'backup completed: %s\n' "${run_dir}"
