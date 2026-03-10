#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"

bash "${stack_root}/scripts/create-stack-network.sh"

docker compose --env-file "${stack_root}/platform/.env" -f "${stack_root}/platform/docker-compose.yml" up -d
docker compose --env-file "${stack_root}/core/.env" -f "${stack_root}/core/docker-compose.yml" up -d
docker compose --env-file "${stack_root}/identity/.env" -f "${stack_root}/identity/docker-compose.yml" up -d
docker compose --env-file "${stack_root}/automation/.env" -f "${stack_root}/automation/docker-compose.yml" up -d
docker compose --env-file "${stack_root}/business/.env" -f "${stack_root}/business/docker-compose.yml" up -d
docker compose --env-file "${stack_root}/monitoring/.env" -f "${stack_root}/monitoring/docker-compose.yml" up -d

systemctl daemon-reload
systemctl enable --now selfhost-backup.timer
