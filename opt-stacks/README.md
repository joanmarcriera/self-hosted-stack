# `/opt/stacks` mirror

This directory mirrors the intended on-server `/opt/stacks` layout.

Use it as the repo-backed source of truth for:
- `core/docker-compose.yml`
- `platform/docker-compose.yml`
- `identity/docker-compose.yml`
- `automation/docker-compose.yml`
- `business/docker-compose.yml`
- `monitoring/docker-compose.yml`
- per-stack `.env.example` files
- helper scripts under `scripts/`

Current scope:
- `core`: Traefik, Docker socket proxy, landing page
- `platform`: shared Postgres, shared MariaDB
- `identity`: Authentik
- `automation`: n8n
- `business`: BookStack, EspoCRM, Vikunja
- `monitoring`: Grafana, Prometheus, Blackbox Exporter

Live-state note:
- The checked-in compose files pin the exact image digests captured from `root@joanmarcriera.es` after the fresh rebuild on 2026-03-10.
- Secrets stay in host-local `.env` files under `/opt/stacks/*/.env`; only `.env.example` is committed.
