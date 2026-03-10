#!/usr/bin/env bash
set -euo pipefail

ssh_target="${N8N_SSH_TARGET:-root@joanmarcriera.es}"
ssh_opts_raw="${N8N_SSH_OPTS:-}"
db_container="${N8N_DB_CONTAINER:-platform-postgres}"
db_name="${N8N_DB_NAME:-n8n}"
db_user="${N8N_DB_USER:-postgres}"
ssh_cmd=(ssh -o BatchMode=yes)

if [[ -n "$ssh_opts_raw" ]]; then
  read -r -a ssh_extra_opts <<<"$ssh_opts_raw"
  ssh_cmd+=("${ssh_extra_opts[@]}")
fi

ssh_cmd+=("$ssh_target")

"${ssh_cmd[@]}" "docker exec '$db_container' psql -U '$db_user' -d '$db_name' -F \$'\t' -Atc \"select u.id, u.email, p.id, p.name, pr.role from \\\"user\\\" u join project_relation pr on pr.\\\"userId\\\" = u.id join project p on p.id = pr.\\\"projectId\\\" order by u.email, p.name;\""
