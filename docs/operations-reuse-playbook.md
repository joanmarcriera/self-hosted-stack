# Operations Reuse Playbook

Last updated: 2026-03-10

## 1) Current Production Snapshot
- Host: `root@joanmarcriera.es` (`server2026`)
- OS baseline: Debian 12
- Runtime: Docker + Docker Compose
- Stack root: `/opt/stacks`
- Live public apps:
  - `https://joanmarcriera.es`
  - `https://auth.joanmarcriera.es`
  - `https://n8n.joanmarcriera.es`
  - `https://docs.joanmarcriera.es`
  - `https://tasks.joanmarcriera.es`
  - `https://crm.joanmarcriera.es`
  - `https://status.joanmarcriera.es`
- Repo-backed source of truth:
  - `opt-stacks/`
  - `server-config/etc/`
  - `scripts/server/`
  - `docs/reproducible-stack.md`

## 2) Security + Logging State
- `ufw`: only `OpenSSH`, `80/tcp`, `443/tcp`
- `fail2ban`: active for SSH
- `auditd`: active for root command/config auditing
- `tlog`: active for interactive SSH recording to journald
- shell history:
  - `HISTSIZE=50000`
  - `HISTFILESIZE=200000`
  - `HISTTIMEFORMAT="%F %T "`
  - prompt-time history append + reload
- prompt:
  - timestamp
  - exit code when non-zero
  - `user@host`
  - cwd
  - git branch when inside a repo

## 3) Live Service Inventory
- `core`: Traefik, Docker socket proxy, landing page
- `platform`: Postgres, MariaDB
- `identity`: Authentik
- `automation`: n8n
- `business`: BookStack, EspoCRM, Vikunja
- `monitoring`: Grafana, Prometheus, Blackbox Exporter
- `backups`: `selfhost-backup.timer` -> `/opt/stacks/scripts/backup-stack.sh`

Image pinning note:
- the repo compose files now pin the exact digests captured from the rebuilt host on 2026-03-10
- host-local secrets stay in `/opt/stacks/*/.env`

## 4) n8n Ownership and IDs
- Discover the current live IDs with:

```bash
scripts/n8n/discover_ids.sh
```

- Current owner, user, and project IDs are intentionally not tracked in the public repo.
- Discover them from the live instance before any import or deploy step.

Workflow handling:
- curated repo examples: `n8n/workflows/`
- exact pre-reinstall export: `.secrets/n8n-live-export/`
- deploy one workflow:

```bash
scripts/n8n/deploy_workflow.sh n8n/workflows/001-tls-expiry-guard.json <project-id> --publish
```

## 5) Fast Verification Commands
Host baseline:

```bash
ssh root@joanmarcriera.es 'hostnamectl --static; systemctl is-active docker fail2ban auditd selfhost-backup.timer; docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"'
```

Firewall:

```bash
ssh root@joanmarcriera.es 'ufw status numbered'
```

Shell policy:

```bash
ssh root@joanmarcriera.es 'sed -n "1,40p" /etc/profile.d/10-history-settings.sh; sed -n "1,40p" /etc/profile.d/20-selfhost-prompt.sh'
```

Recent session recording:

```bash
ssh root@joanmarcriera.es 'journalctl -t tlog-rec-session -n 5 --no-pager'
```

n8n owner/project IDs:

```bash
scripts/n8n/discover_ids.sh
```

## 6) Known Issues, Fixes, Next-Time Guidance
1. Issue: bootstrap initially copied `/etc` files with wrong ownership from macOS metadata.
   Fix: `bootstrap_host.sh` now uses `rsync -rlptD --chown=root:root`.
   Next time: do not use raw ownership-preserving sync from a non-Linux workstation for `/etc`.
2. Issue: Postgres init scripts were created unreadable and with broken `DO $$` quoting.
   Fix: `render_stack_envs.sh` now restores `umask`, applies explicit perms, and escapes `$$`.
   Next time: keep generated init scripts executable/readable by container users and verify them before first DB bootstrap.
3. Issue: floating tags (`latest`, major-only tags) undermined reproducibility.
   Fix: compose files now pin the exact digests from the rebuilt host.
   Next time: update digests intentionally after validation, not during emergency rebuilds.
4. Issue: n8n IDs changed after reinstall.
   Fix: use `scripts/n8n/discover_ids.sh` instead of relying on stale notes.
   Next time: refresh IDs immediately after any clean rebuild before importing workflows.
5. Issue: app-level SSO was missing after the clean rebuild.
   Fix: `configure_sso.sh` now creates Authentik groups plus BookStack, Vikunja, EspoCRM, and Grafana OIDC providers, then restarts those apps with the right config.
   Next time: keep the whole business-app auth layer in one scripted rollout instead of splitting CRM off.
6. Issue: the BookStack bootstrap admin step was not idempotent and broke later SSO reruns.
   Fix: `configure_sso.sh` now checks the BookStack database first and only runs `bookstack:create-admin --initial` when the owner record is absent.
   Next time: treat all bootstrap-only commands as one-time initialization and guard them before rerunning the stack config.
7. Issue: adding a second Traefik service on `authentik-server` broke the `auth` router until it was explicitly pinned.
   Fix: `opt-stacks/identity/docker-compose.yml` now sets `traefik.http.routers.auth.service=auth` before adding the status-host outpost service.
   Next time: whenever a container exposes more than one Traefik service, bind every router explicitly instead of relying on automatic selection.

## 7) Canonical Doc Index
- `docs/reproducible-stack.md`
- `docs/server-reset-handoff.md`
- `docs/account-and-access-policy.md`
- `docs/authentik-email-password-recovery.md`
- `docs/demo-consultancy-blueprint.md`
- `docs/tool-relationship-map.md`
- `n8n/SSH-API-quickstart.md`

## 8) Reuse Checklist
1. Push repo assets to the host and rerun `bootstrap_host.sh` only on fresh hosts.
2. Run `render_stack_envs.sh`, `deploy_stack.sh`, `configure_sso.sh`, and `verify_stack.sh`.
3. Confirm app HTTP status, firewall, audit/tlog state, and backup timer.
4. Run `scripts/n8n/discover_ids.sh` before any workflow import.
5. Keep any host-specific evidence or exports in a local ignored path such as `.secrets/notes/` or `.secrets/n8n-live-export/`.

Unknown / Not verified yet:
- full browser validation for Alex and Marta across BookStack, Vikunja, EspoCRM, and Grafana is still pending
- Authentik group membership exists, but group-based authorization inside BookStack, Vikunja, EspoCRM, and Grafana is not enforced yet
- off-host restic destination is still unset
- pre-reinstall workflows should be preserved in a local ignored export, but are not re-imported automatically on a fresh host
