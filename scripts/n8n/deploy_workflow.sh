#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<USAGE
Usage:
  $(basename "$0") <workflow-json-file> <project-id> [--publish]

Env (optional):
  N8N_SSH_TARGET   default: root@joanmarcriera.es
  N8N_SSH_OPTS     extra ssh options, split on spaces
  N8N_CONTAINER    default: n8n
USAGE
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
  usage
  exit 1
fi

workflow_file="$1"
project_id="$2"
publish_flag="${3:-}"

if [[ ! -f "$workflow_file" ]]; then
  echo "Workflow file not found: $workflow_file" >&2
  exit 1
fi

if [[ "$publish_flag" != "" && "$publish_flag" != "--publish" ]]; then
  usage
  exit 1
fi

ssh_target="${N8N_SSH_TARGET:-root@joanmarcriera.es}"
ssh_opts_raw="${N8N_SSH_OPTS:-}"
container="${N8N_CONTAINER:-n8n}"
remote_tmp="/tmp/$(basename "$workflow_file")"
ssh_cmd=(ssh -o BatchMode=yes)

if [[ -n "$ssh_opts_raw" ]]; then
  read -r -a ssh_extra_opts <<<"$ssh_opts_raw"
  ssh_cmd+=("${ssh_extra_opts[@]}")
fi

ssh_cmd+=("$ssh_target")

workflow_meta="$(python3 - "$workflow_file" <<'PY'
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    data = json.load(f)
wid = data.get('id')
version_id = data.get('versionId')
missing = []
if not wid:
    missing.append('id')
if not version_id:
    missing.append('versionId')
if missing:
    raise SystemExit(f'workflow JSON must include top-level {", ".join(missing)}')
print(f"{wid}\t{version_id}")
PY
)"
workflow_id="${workflow_meta%%$'\t'*}"

echo "[1/4] Uploading workflow JSON to ${ssh_target}:${remote_tmp}"
"${ssh_cmd[@]}" "cat > '$remote_tmp'" < "$workflow_file"

echo "[2/4] Importing workflow into project ${project_id}"
"${ssh_cmd[@]}" "set -e; docker cp '$remote_tmp' '$container:$remote_tmp'; docker exec '$container' n8n import:workflow --input='$remote_tmp' --projectId='${project_id}'"

if [[ "$publish_flag" == "--publish" ]]; then
  echo "[3/4] Publishing workflow ${workflow_id} and restarting ${container}"
  "${ssh_cmd[@]}" "set -e; docker exec '$container' n8n publish:workflow --id='${workflow_id}'; docker restart '$container' >/dev/null"
else
  echo "[3/4] Skipping publish (use --publish to activate schedule/webhooks)"
  echo "      Note: importing an existing workflow ID can deactivate it until republished."
fi

echo "[4/4] Current workflows"
"${ssh_cmd[@]}" "docker exec '$container' n8n list:workflow"
