# Reproducible Stack Guide

This repo now contains the deployable assets for the rebuilt March 10, 2026 SME stack, not just prose about a prior host state.

## Canonical assets

- Server config fragments: `server-config/etc/`
- Stack files mirrored to `/opt/stacks`: `opt-stacks/`
- Server bootstrap scripts: `scripts/server/` and mirrored host copies in `/opt/stacks/scripts/`
- Landing page template: `scripts/server/templates/landing-page.html`
- Pre-reset handoff guide: `docs/server-reset-handoff.md`
- n8n instance discovery helper: `scripts/n8n/discover_ids.sh`
- Curated workflow examples: `n8n/workflows/`
- Private exact n8n exports: keep them under `.secrets/n8n-live-export/`

## Target stack

- `core`: Traefik, Docker socket proxy, apex/`www` landing page
- `platform`: shared Postgres, shared MariaDB
- `identity`: Authentik
- `automation`: n8n
- `business`: BookStack, EspoCRM, Vikunja
- `monitoring`: Grafana, Prometheus, Blackbox Exporter
- `backups`: local tar/sql dumps, optional restic off-host sync

## 1) Fresh-host build path

From the repo on your workstation:

```bash
bash scripts/server/export_reset_handoff_from_live.sh
bash scripts/server/validate_reset_handoff.sh
scripts/server/push_repo_assets.sh
bash scripts/server/push_reset_handoff.sh
```

On the target Debian 12 host:

```bash
cd /root/self-hosted-stack
bash scripts/server/rebuild_from_handoff.sh
```

## 2) What `bootstrap_host.sh` applies

- Docker Engine + Compose v2
- `ufw`, `fail2ban`, `unattended-upgrades`
- `auditd` command/config auditing
- `tlog` SSH session recording to journald
- persistent journald
- 4 GiB swap
- `/etc/profile.d/10-history-settings.sh`
- `/etc/profile.d/20-selfhost-prompt.sh`

Expected shell effects:

- large history (`HISTSIZE=50000`, `HISTFILESIZE=200000`)
- timestamped commands (`HISTTIMEFORMAT="%F %T "`)
- history merge across concurrent shells
- prompt with timestamp, exit code, host, cwd, and git branch

## 3) Generated state under `/opt/stacks`

`render_stack_envs.sh` creates:

- `.env` files for `core`, `platform`, `identity`, `automation`, `business`, `monitoring`, and `backups`
- initial Vikunja config at `/opt/stacks/business/config/vikunja/config.yml`
- repo-backed landing page rendered to `/opt/stacks/core/site/index.html`
- Postgres init script for `authentik` + `n8n`
- MariaDB init SQL for `bookstack` + `espocrm`
- app data directories and permissions

The generated env files are the source of truth for live secrets on the host. They are intentionally not committed.

When `/opt/stacks/secrets/server-reset-handoff.env` exists, `render_stack_envs.sh` uses it as the preferred rebuild input.

Important live-only password locations:

- Authentik bootstrap and SMTP settings: `/opt/stacks/identity/.env`
- Grafana admin/OIDC secrets: `/opt/stacks/monitoring/.env`
- Reset handoff pack on host: `/opt/stacks/secrets/`

The compose files in `opt-stacks/` pin the exact image digests captured from the rebuilt host on 2026-03-10.

`configure_sso.sh` then:

- waits for an authenticated `core/users/me` response from Authentik before making API changes, to avoid fresh-boot races
- creates the Authentik groups `automation-founders`, `automation-delivery`, and `automation-ops`
- creates or updates the Authentik OIDC providers and applications for BookStack, Vikunja, and EspoCRM
- creates or updates the Authentik OIDC provider and application for Grafana
- patches the embedded Authentik outpost with the public `https://auth.<domain>` host so forward-auth redirects never emit `0.0.0.0`
- maps the initial BookStack admin to the Authentik bootstrap email without breaking reruns
- turns on OpenID login in Vikunja and OIDC login in BookStack and EspoCRM
- creates the EspoCRM teams `Founders`, `Delivery`, and `Operations`
- links the founder admin user to the `Founders` team and enables team sync from Authentik groups
- enables Grafana login at `status.<domain>` through Authentik OIDC while keeping a local break-glass admin

`configure_authentik_recovery.sh` then:

- waits for the Authentik API to accept the bootstrap token before checking recovery-flow state
- imports Authentik's built-in `default-recovery-flow` blueprint when it is missing
- binds the recovery flow to the default Authentik brand
- leaves SMTP delivery dependent on the `AUTHENTIK_EMAIL_*` values in `/opt/stacks/identity/.env`
- expects a real SMTP secret such as a Gmail app password, documented in `docs/authentik-email-password-recovery.md`

`import_authentik_reset_users.sh` then:

- reads `/opt/stacks/secrets/server-reset-users.csv`
- creates or updates the declared Authentik users
- replaces only `automation-*` group membership while preserving built-in Authentik admin groups
- sets each declared Authentik password

`configure_grafana_monitoring.sh` then:

- redeploys Grafana, Prometheus, and Blackbox Exporter with the repo-backed provisioning files
- verifies Prometheus config with `promtool`
- probes every public hostname plus direct `SSH`, `Postgres`, and `MariaDB` reachability
- provisions the `SME Stack Overview` dashboard at `https://status.<domain>/d/stack-overview/stack-overview`

`seed_demo_content.sh` then:

- creates or updates the `Demo Clients` shelf and `Acme Bakery Automation` book in BookStack
- seeds demo delivery projects and tasks in Vikunja when at least one local Vikunja user exists, including Alex and Marta shares when those users exist
- seeds demo accounts, contacts, and opportunities in EspoCRM
- keeps the content idempotent so reruns refresh the demo instead of duplicating it
- should be rerun after the founder first logs into Vikunja, and again after Alex or Marta first log in if you want their seeded task shares to appear immediately

## 4) Service map

- `https://joanmarcriera.es` and `https://www.joanmarcriera.es`: landing page
- `https://auth.joanmarcriera.es`: Authentik
- `https://n8n.joanmarcriera.es`: n8n
- `https://docs.joanmarcriera.es`: BookStack
- `https://tasks.joanmarcriera.es`: Vikunja
- `https://crm.joanmarcriera.es`: EspoCRM
- `https://status.joanmarcriera.es`: Grafana
- `https://status.joanmarcriera.es/d/stack-overview/stack-overview`: seeded monitoring overview

## 5) Backup path

Backup job:

- script: `/opt/stacks/scripts/backup-stack.sh`
- systemd service: `selfhost-backup.service`
- systemd timer: `selfhost-backup.timer`
- local output: `/opt/stacks/backups/runs/`

Optional off-host backup:

- set `RESTIC_REPOSITORY` and `RESTIC_PASSWORD` in `/opt/stacks/backups/.env`

## 6) Workflow recovery

Two sources exist on purpose:

- `n8n/workflows/`: curated examples for ongoing edits
- `.secrets/n8n-live-export/`: exact live export kept out of git

Refresh the live export:

```bash
scripts/n8n/export_workflows_ssh.sh .secrets/n8n-live-export/$(date +%F)
```

Discover the current live owner/project IDs after a rebuild:

```bash
scripts/n8n/discover_ids.sh
```

Deploy a curated workflow:

```bash
scripts/n8n/deploy_workflow.sh n8n/workflows/001-tls-expiry-guard.json <project-id> --publish
```

## 7) Verification

```bash
ssh root@joanmarcriera.es 'hostnamectl --static; systemctl is-active docker fail2ban auditd selfhost-backup.timer; docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
ssh root@joanmarcriera.es 'ufw status numbered'
ssh root@joanmarcriera.es 'systemctl status selfhost-backup.timer --no-pager -l | sed -n "1,20p"'
ssh root@joanmarcriera.es 'journalctl -t tlog-rec-session -n 5 --no-pager'
ssh root@joanmarcriera.es '/opt/stacks/scripts/verify_stack.sh'
ssh root@joanmarcriera.es 'docker exec prometheus promtool check config /etc/prometheus/prometheus.yml'
ssh root@joanmarcriera.es 'docker exec prometheus promtool query instant http://127.0.0.1:9090 "probe_success"'
ssh root@joanmarcriera.es 'curl -ksSI https://status.joanmarcriera.es/api/health | sed -n "1,12p"'
scripts/n8n/discover_ids.sh
ssh root@joanmarcriera.es 'echo | openssl s_client -servername n8n.joanmarcriera.es -connect n8n.joanmarcriera.es:443 2>/dev/null | openssl x509 -noout -issuer -subject -dates'
ssh root@joanmarcriera.es 'curl -ksS https://docs.joanmarcriera.es/login | grep -n "Login with Authentik"'
ssh root@joanmarcriera.es 'curl -ksS https://tasks.joanmarcriera.es/api/v1/info | jq ".auth.openid_connect"'
ssh root@joanmarcriera.es 'curl -ksSI https://crm.joanmarcriera.es/ | sed -n "1,8p"'
ssh root@joanmarcriera.es 'curl -ksSI https://status.joanmarcriera.es/ | sed -n "1,8p"'
ssh root@joanmarcriera.es 'curl -ksS https://auth.joanmarcriera.es/api/v3/core/brands/current/ | jq ".flow_recovery"'
```

Unknown / Not verified yet:

- full browser click-through for non-founder users into BookStack, Vikunja, EspoCRM, and Grafana has not been exercised in this repo session
- Authentik group membership exists, but per-group authorization and role mapping inside BookStack, Vikunja, EspoCRM, and Grafana remain a follow-up
- off-host restic target is optional and remains unset until configured
- `n8n` still keeps a first-owner bootstrap edge case after a full wipe, so the owner email is preserved but one browser registration step may still be required
