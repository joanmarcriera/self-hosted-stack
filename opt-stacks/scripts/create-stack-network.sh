#!/usr/bin/env bash
set -euo pipefail

NETWORK_NAME="stack-net"
if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
  docker network create "$NETWORK_NAME"
  echo "Created network: $NETWORK_NAME"
else
  echo "Network already exists: $NETWORK_NAME"
fi
