#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") <project-id> [workflow-dir]

Env (optional):
  N8N_SSH_TARGET   default: root@joanmarcriera.es
  N8N_SSH_OPTS     extra ssh options, split on spaces
  N8N_CONTAINER    default: n8n
USAGE
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

project_id="$1"
workflow_dir="${2:-n8n/workflows}"

if [[ ! -d "$workflow_dir" ]]; then
  echo "Workflow directory not found: $workflow_dir" >&2
  exit 1
fi

ssh_target="${N8N_SSH_TARGET:-root@joanmarcriera.es}"
ssh_opts_raw="${N8N_SSH_OPTS:-}"
container="${N8N_CONTAINER:-n8n}"
remote_dir="/tmp/n8n-import-workflows"
ssh_cmd=(ssh -o BatchMode=yes)

if [[ -n "$ssh_opts_raw" ]]; then
  read -r -a ssh_extra_opts <<<"$ssh_opts_raw"
  ssh_cmd+=("${ssh_extra_opts[@]}")
fi

ssh_cmd+=("$ssh_target")

echo "[1/3] Uploading ${workflow_dir} to ${ssh_target}:${remote_dir}"
COPYFILE_DISABLE=1 COPY_EXTENDED_ATTRIBUTES_DISABLE=1 tar \
  --exclude='._*' \
  -C "$workflow_dir" \
  -cf - . \
  | "${ssh_cmd[@]}" "rm -rf '$remote_dir' && mkdir -p '$remote_dir' && tar --warning=no-unknown-keyword -xf - -C '$remote_dir'"

echo "[2/3] Importing workflows into project ${project_id}"
"${ssh_cmd[@]}" "set -e; docker cp '$remote_dir/.' '$container:$remote_dir'; docker exec '$container' n8n import:workflow --separate --input='$remote_dir' --projectId='${project_id}'"

echo "[3/3] Cleaning temporary files"
"${ssh_cmd[@]}" "docker exec -u 0 '$container' sh -lc 'rm -rf $remote_dir'; rm -rf '$remote_dir'"

echo "Imported workflows from ${workflow_dir}"
