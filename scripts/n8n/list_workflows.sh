#!/usr/bin/env bash
set -euo pipefail

ssh_target="${N8N_SSH_TARGET:-root@joanmarcriera.es}"
ssh_opts_raw="${N8N_SSH_OPTS:-}"
container="${N8N_CONTAINER:-n8n}"
ssh_cmd=(ssh -o BatchMode=yes)

if [[ -n "$ssh_opts_raw" ]]; then
  read -r -a ssh_extra_opts <<<"$ssh_opts_raw"
  ssh_cmd+=("${ssh_extra_opts[@]}")
fi

ssh_cmd+=("$ssh_target")

"${ssh_cmd[@]}" "docker exec '$container' n8n list:workflow"
