#!/usr/bin/env bash
set -euo pipefail

ssh_target="${1:-root@joanmarcriera.es}"
handoff_env="${2:-.secrets/server-reset-handoff.env}"
users_csv="${3:-.secrets/server-reset-users.csv}"
remote_dir="${REMOTE_HANDOFF_DIR:-/opt/stacks/secrets}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

[[ -f "$handoff_env" ]] || {
  printf 'missing required file: %s\n' "$handoff_env" >&2
  exit 1
}

[[ -f "$users_csv" ]] || {
  printf 'missing required file: %s\n' "$users_csv" >&2
  exit 1
}

bash "${script_dir}/validate_reset_handoff.sh" "$handoff_env" "$users_csv" >/dev/null

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

cp "$handoff_env" "${tmpdir}/server-reset-handoff.env"
cp "$users_csv" "${tmpdir}/server-reset-users.csv"

COPYFILE_DISABLE=1 COPY_EXTENDED_ATTRIBUTES_DISABLE=1 tar -cf - \
  -C "$tmpdir" \
  server-reset-handoff.env \
  server-reset-users.csv \
  | ssh -o BatchMode=yes "$ssh_target" "mkdir -p '$remote_dir' && tar --warning=no-unknown-keyword --no-same-owner -xf - -C '$remote_dir' && chmod 600 '$remote_dir/server-reset-handoff.env' '$remote_dir/server-reset-users.csv'"

printf 'pushed handoff files to %s:%s\n' "$ssh_target" "$remote_dir"
