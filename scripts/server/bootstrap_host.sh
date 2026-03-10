#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y
apt-get install -y \
  ufw fail2ban unattended-upgrades \
  curl gnupg ca-certificates software-properties-common apt-transport-https \
  git jq rsync tmux htop vim tree \
  auditd audispd-plugins tlog python3-systemd \
  restic apache2-utils

install -m 0755 -d /etc/apt/keyrings
if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

. /etc/os-release
cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${VERSION_CODENAME} stable
EOF

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

timedatectl set-timezone Europe/London

if ! swapon --show | grep -q '^/swapfile'; then
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -qxF '/swapfile none swap sw 0 0' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

install -d -m 0755 \
  /opt/stacks/core \
  /opt/stacks/platform \
  /opt/stacks/identity \
  /opt/stacks/automation \
  /opt/stacks/business \
  /opt/stacks/monitoring \
  /opt/stacks/backups \
  /opt/stacks/secrets \
  /opt/stacks/scripts

rsync -rlptD --chown=root:root "${repo_root}/server-config/etc/" /etc/
rsync -rlptD --chown=root:root "${repo_root}/opt-stacks/" /opt/stacks/
rsync -rlptD --chown=root:root "${repo_root}/scripts/server/" /opt/stacks/scripts/
find /opt/stacks/scripts -type f -name '*.sh' -exec chmod 0755 {} +
sshd -t
systemctl reload ssh
sysctl --system
augenrules --load
systemctl restart auditd fail2ban systemd-journald

systemctl enable --now unattended-upgrades || true
