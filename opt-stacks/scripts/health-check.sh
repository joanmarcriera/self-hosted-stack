#!/usr/bin/env bash
set -euo pipefail

echo "== Host =="
hostname
uname -sr

echo "== Docker =="
docker --version
docker compose version
systemctl is-active docker

echo "== Security =="
ufw status | sed -n "1,20p"
systemctl is-active fail2ban

echo "== Resources =="
free -h
swapon --show

echo "== Stack dirs =="
ls -la /opt/stacks
