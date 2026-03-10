#!/usr/bin/env bash
set -euo pipefail

ssh_target="${N8N_SSH_TARGET:-root@joanmarcriera.es}"
ssh_opts_raw="${N8N_SSH_OPTS:-}"
container="${N8N_CONTAINER:-n8n}"
out_dir="${1:-.secrets/n8n-live-export/$(date +%F)}"
ssh_cmd=(ssh -o BatchMode=yes)

if [[ -n "$ssh_opts_raw" ]]; then
  read -r -a ssh_extra_opts <<<"$ssh_opts_raw"
  ssh_cmd+=("${ssh_extra_opts[@]}")
fi

ssh_cmd+=("$ssh_target")

mkdir -p "$out_dir"

# Export one file per workflow from inside the running n8n container, then untar locally.
"${ssh_cmd[@]}" \
  "docker exec '$container' sh -lc 'tmpdir=\$(mktemp -d); n8n export:workflow --backup --output=\$tmpdir >/dev/null; tar -C \$tmpdir -cf - .; rm -rf \$tmpdir'" \
  | tar -C "$out_dir" -xf -

all_file="$(mktemp)"
active_file="$(mktemp)"
trap 'rm -f "$all_file" "$active_file"' EXIT

"${ssh_cmd[@]}" "docker exec '$container' n8n list:workflow" > "$all_file"
"${ssh_cmd[@]}" "docker exec '$container' n8n list:workflow --active=true" \
  | cut -d'|' -f1 | sort > "$active_file"

manifest="$out_dir/manifest.tsv"
: > "$manifest"

while IFS='|' read -r workflow_id workflow_name; do
  is_active=false
  if grep -Fxq "$workflow_id" "$active_file"; then
    is_active=true
  fi
  printf '%s\t%s\t%s\t%s\n' \
    "$workflow_id" \
    "$is_active" \
    "$workflow_name" \
    "$out_dir/${workflow_id}.json" >> "$manifest"
done < "$all_file"

printf 'exported %s workflows to %s\n' "$(wc -l < "$manifest" | tr -d ' ')" "$out_dir"
printf 'manifest %s\n' "$manifest"
