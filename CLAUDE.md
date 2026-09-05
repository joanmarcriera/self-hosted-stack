# CLAUDE.md — self-hosted-stack

## Purpose
Deployable assets and reproducible rebuild playbook for Marc's production self-hosted SME stack at `joanmarcriera.es` (Hetzner VPS, Debian 12). Contains Docker Compose configurations, server hardening scripts, n8n workflow examples, and operational documentation. **Live state tracked:** exact image digests pinned from 2026-03-10 rebuild; published docs at `sme.riera.co.uk`.

## How to Run/Test

### Fresh-host rebuild (on-workstation steps)
```bash
bash scripts/server/export_reset_handoff_from_live.sh
bash scripts/server/validate_reset_handoff.sh
bash scripts/server/push_repo_assets.sh
bash scripts/server/push_reset_handoff.sh
```

### On target Debian 12 host
```bash
cd /root/self-hosted-stack
bash scripts/server/rebuild_from_handoff.sh
```

### Validation
- SSH config/audit rules: `sshd -t && systemctl reload ssh`
- Docker stacks: `cd /opt/stacks/<stack> && docker compose up -d`
- Monitoring: Grafana/Uptime Kuma served via Traefik at whatever `STATUS_HOST` is set to in the
  live `.env` (placeholder in `.env.example` is `status.example.com`; the real value is not
  committed)

## Layout

```
docs/                          # Operational guides
  reproducible-stack.md        # Main rebuild playbook
  operations-reuse-playbook.md # SME ops patterns
  account-and-access-policy.md # SSO/RBAC setup
  server-reset-handoff.md      # Pre-reset checklist
  
opt-stacks/                    # Docker Compose source of truth
  core/                        # Traefik, docker-socket-proxy, landing page
  platform/                    # Postgres, MariaDB
  identity/                    # Authentik (SSO/RBAC)
  automation/                  # n8n (workflows)
  business/                    # BookStack, EspoCRM, Vikunja
  monitoring/                  # Grafana, Prometheus, Blackbox
  scripts/                     # Stack-specific helpers

server-config/etc/             # Debian host config snapshot
  sshd_config, ufw, fail2ban, auditd, tlog config

scripts/server/                # Bootstrap & rebuild automation
  bootstrap_host.sh            # Docker, UFW, fail2ban, auditd, tlog
  rebuild_from_handoff.sh      # Full stack rebuild
  export_reset_handoff_from_live.sh  # Snapshot for disaster recovery

n8n/                           # Workflow inventory
  workflows/                   # Example business automation
  TOMORROW-CONFIG.md           # n8n setup checklist
  family-workflows-starter-pack.md

.secrets/                      # (gitignored) Live n8n exports, .env files
reports/                       # (gitignored) Operational reports (YYYY-MM-DD format)
```

## Conventions

**AGENTS.md rules (token-efficient context):**
- Prefer targeted grep → partial file reads → full files only if decision-critical
- Summaries max 8 bullets; use compact command tables
- Always include "Unknown / Not verified yet" when data missing
- Report new findings to `reports/YYYY-MM-DD-<topic>.md` using standard structure

**File retention:**
- Keep markdown concise; bulky command output → `reports/*.txt`
- Image digests in compose files are pinned from live capture (do not auto-upgrade)
- Secrets only in `.env` files (never committed); `.env.example` is committed

**Deployment:**
- All services behind Traefik (DNS via OVH, TLS via Let's Encrypt)
- Shared databases (`platform` stack) for scalability
- n8n workflows in `automation` stack; exported backups → `.secrets/n8n-live-export/`

## Gotchas

1. **Live state is pinned:** Compose files contain exact image digests from the 2026-03-10 rebuild. Do not manually upgrade without exporting a new handoff snapshot.
2. **Secrets management:** `.env` files under `/opt/stacks/*/` are never committed. Sync manually or via secure handoff script (`push_reset_handoff.sh`).
3. **SSH session recording:** `tlog` logs all interactive SSH sessions to journald; verify connectivity once after config reload.
4. **Disk-critical:** Watch `/var/lib/docker` and `/opt/stacks` free space; full disk can corrupt TLS store and Postgres.
5. **Handoff validation:** Always run `validate_reset_handoff.sh` before `push_reset_handoff.sh` to catch missing assets.
6. **n8n exports are private:** Live exports belong in `.secrets/n8n-live-export/` (gitignored); only commit workflow examples to `n8n/workflows/`.

## Key References

- **Rebuild start:** `docs/reproducible-stack.md`
- **Operations reuse:** `docs/operations-reuse-playbook.md`
- **Reset checklist:** `docs/server-reset-handoff.md`
- **Tool relationships:** `docs/tool-relationship-map.md`
- **Published docs:** https://sme.riera.co.uk
