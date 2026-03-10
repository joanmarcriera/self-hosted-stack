#!/usr/bin/env bash
set -euo pipefail

ssh_target="${1:-root@joanmarcriera.es}"
remote_dir="${REMOTE_REPO_DIR:-/root/self-hosted-stack}"

COPYFILE_DISABLE=1 COPY_EXTENDED_ATTRIBUTES_DISABLE=1 tar --exclude='._*' -cf - \
  README.md \
  docs \
  n8n \
  opt-stacks \
  scripts \
  server-config \
  | ssh -o BatchMode=yes "$ssh_target" "mkdir -p '$remote_dir' && tar --warning=no-unknown-keyword --no-same-owner -xf - -C '$remote_dir'"

printf 'synced repo assets to %s:%s\n' "$ssh_target" "$remote_dir"
