# Self-Hosted Company Tool Stack: 1–50 People

A complete infrastructure blueprint for running a small company on free/open-source, self-hosted software — from day one through scaling to ~50 employees.

---

## Table of Contents

1. [Domain-by-Domain Tool Selection](#1-domain-by-domain-tool-selection)
2. [Suggested Overall Architecture](#2-suggested-overall-architecture)
3. [Automation Strategy](#3-automation-strategy)
4. [Deployment Strategy](#4-deployment-strategy)
5. [Cost Analysis](#5-cost-analysis)
6. [Scaling Considerations](#6-scaling-considerations)
7. [Minimal Stack (5–7 tools)](#7-minimal-stack)
8. [Advanced Stack (15–25 tools)](#8-advanced-stack)
9. [Tools to Avoid](#9-tools-to-avoid)

---

## 1. Domain-by-Domain Tool Selection

### 1.1 Automation / Workflow Orchestration

| Tool | Type | Description |
|------|------|-------------|
| **n8n** | OSS, self-hosted | Visual workflow automation with 400+ integrations. Node-based editor, webhook triggers, cron scheduling. The glue layer for your entire stack. |
| **Rundeck** | OSS, self-hosted | Job scheduler and runbook automation. Better for ops/infra tasks (server maintenance, deployments) than business workflows. |
| **Temporal** | OSS, self-hosted | Durable workflow engine for complex, long-running processes. Overkill at 1–2 people but excellent at 20+. |

**Recommendation:** n8n is the primary automation hub. It connects everything.

| | n8n | Rundeck | Temporal |
|---|-----|---------|----------|
| **Pros** | Huge connector library, visual editor, webhook-native, active community | Strong RBAC, audit trail, CLI/API-first, good for infra ops | Fault-tolerant, handles complex state machines, code-first |
| **Cons** | Single-threaded worker by default, UI can lag on huge workflows | Not suited for business process automation, dated UI | Complex to deploy, needs developers, heavy for small teams |
| **Scale fit** | 1–50 easily | 1–50 for ops tasks | 20+ with dev team |

---

### 1.2 CRM / Customer Management

| Tool | Type | Description |
|------|------|-------------|
| **Twenty** | OSS, self-hosted | Modern CRM inspired by Salesforce. Clean UI, GraphQL API, extensible data model. Relatively new but very active. |
| **SuiteCRM** | OSS, self-hosted | Mature fork of SugarCRM. Full-featured: contacts, leads, opportunities, campaigns, reporting. |
| **ERPNext CRM module** | OSS, self-hosted | CRM built into ERPNext ERP. Good if you're already running ERPNext. |

**Recommendation:** Twenty for a modern, lightweight start. SuiteCRM if you need a battle-tested, full CRM from day one.

| | Twenty | SuiteCRM |
|---|--------|----------|
| **Pros** | Beautiful UI, API-first, fast, modern stack (React/Node/Postgres) | Very mature, extensive modules, large community, migration tools |
| **Cons** | Young project, smaller plugin ecosystem, some features still in progress | Dated UI, PHP stack, heavier resource usage, steeper learning curve |
| **Scale fit** | 1–30 comfortably, growing fast | 1–50+, enterprise-proven |

---

### 1.3 ERP / Accounting / Invoicing

| Tool | Type | Description |
|------|------|-------------|
| **ERPNext** | OSS, self-hosted | Full ERP: accounting, invoicing, inventory, HR, payroll, manufacturing. Built on Frappe framework (Python). |
| **InvoiceNinja** | OSS, self-hosted | Focused invoicing/billing tool. Clients, invoices, payments, expenses, time-tracking. |
| **Crater** | OSS, self-hosted | Lightweight invoicing app (Laravel/Vue). Simple and effective for freelancers and micro-businesses. |

**Recommendation:** InvoiceNinja for pure invoicing at 1–5 people. ERPNext if you want a unified ERP that grows with you.

| | ERPNext | InvoiceNinja | Crater |
|---|--------|--------------|--------|
| **Pros** | All-in-one ERP, multi-currency, multi-company, huge module set | Focused and polished, great client portal, Stripe/PayPal integration | Dead simple, fast setup, low resources |
| **Cons** | Resource-heavy (2GB+ RAM), complex setup, learning curve | Not a full ERP, limited inventory/HR | Very basic, no ERP features, small community |
| **Scale fit** | 5–50+ (overkill for 1–2) | 1–30 | 1–10 |

**Two valid approaches:**

- **Option A — Modular:** InvoiceNinja (invoicing) + separate tools per domain. Lighter, simpler.
- **Option B — Monolithic:** ERPNext covers CRM + accounting + HR + inventory in one system. Heavier but fewer integrations needed.

---

### 1.4 Project Management / Task Management

| Tool | Type | Description |
|------|------|-------------|
| **Plane** | OSS, self-hosted | Modern project management (issues, cycles, modules, views). Clean Jira/Linear alternative. |
| **Vikunja** | OSS, self-hosted | Lightweight task manager. Lists, kanban, gantt, caldav. Low resource usage. |
| **Taiga** | OSS, self-hosted | Agile project management (Scrum/Kanban). Good for dev teams. |

**Recommendation:** Plane for teams that want a modern PM tool. Vikunja for ultra-lightweight task tracking.

| | Plane | Vikunja | Taiga |
|---|-------|---------|-------|
| **Pros** | Modern UI, GitHub/GitLab integration, cycles/sprints, active dev | Tiny footprint (~50MB RAM), CalDAV sync, simple | Native Scrum/Kanban, wiki built-in, mature |
| **Cons** | Younger project, some enterprise features still developing | Limited reporting, no advanced PM features | UI feels dated, smaller community recently |
| **Scale fit** | 1–50 | 1–15 | 5–50 |

---

### 1.5 Documentation / Knowledge Base

| Tool | Type | Description |
|------|------|-------------|
| **BookStack** | OSS, self-hosted | Structured wiki: shelves → books → chapters → pages. WYSIWYG + markdown. LDAP/SAML support. |
| **Wiki.js** | OSS, self-hosted | Modern wiki with Git-backed storage, multiple editors (markdown, WYSIWYG, code), search, diagrams. |
| **Outline** | OSS, self-hosted | Team knowledge base. Notion-like editor, nested documents, Slack integration, real-time collaboration. |

**Recommendation:** BookStack for structured documentation (SOPs, runbooks). Outline for a Notion-like team wiki.

| | BookStack | Wiki.js | Outline |
|---|-----------|---------|---------|
| **Pros** | Intuitive hierarchy, low resources, great search, built-in diagrams | Git sync, multiple editors, i18n, diagram support | Beautiful editor, real-time collab, Slack integration |
| **Cons** | Less flexible structure, no real-time collab | More complex setup, can be overkill for small teams | Requires S3-compatible storage, heavier |
| **Scale fit** | 1–50 | 1–50 | 5–50 |

---

### 1.6 File Storage and Collaboration

| Tool | Type | Description |
|------|------|-------------|
| **Nextcloud** | OSS, self-hosted | File sync/share, calendar, contacts, office suite (Collabora/OnlyOffice), apps ecosystem. The Google Workspace replacement. |
| **Seafile** | OSS, self-hosted | Focused file sync. Faster sync than Nextcloud, better large-file handling. Less app ecosystem. |
| **MinIO** | OSS, self-hosted | S3-compatible object storage. Backend for other tools (backups, media, logs) rather than end-user file sharing. |

**Recommendation:** Nextcloud as the primary user-facing file platform. MinIO as backend object storage for other services.

| | Nextcloud | Seafile | MinIO |
|---|-----------|---------|-------|
| **Pros** | Huge app ecosystem, office integration, CalDAV/CardDAV, E2E encryption | Faster sync engine, lower resource usage, good dedup | S3-compatible, excellent performance, erasure coding |
| **Cons** | Can be slow with many files, PHP stack, needs tuning | Smaller ecosystem, no built-in office suite, C code harder to debug | Not end-user friendly, no GUI file browsing (use with other tools) |
| **Scale fit** | 1–50 | 1–50 | 1–50 (as backend) |

---

### 1.7 Internal Communication

| Tool | Type | Description |
|------|------|-------------|
| **Rocket.Chat** | OSS, self-hosted | Team chat with channels, DMs, threads, video calls, bots, federation. Slack alternative. |
| **Mattermost** | OSS, self-hosted | Team messaging. Channels, threads, integrations, playbooks. Strong DevOps integrations. |
| **Jitsi Meet** | OSS, self-hosted | Video conferencing. No account needed for guests. Can embed in other tools. |
| **Element (Matrix)** | OSS, self-hosted | Matrix protocol client. Federated, E2E encrypted, bridges to Slack/IRC/Telegram. |

**Recommendation:** Mattermost for team chat (better resource usage than Rocket.Chat). Jitsi for video. Element if you need federation or strong encryption.

| | Mattermost | Rocket.Chat | Element/Matrix |
|---|------------|-------------|----------------|
| **Pros** | Clean UI, good integrations, playbooks, lower RAM than Rocket.Chat | Feature-rich, built-in video, omnichannel, bots | Federated, E2E encrypted, bridges to other platforms |
| **Cons** | Some features enterprise-only, Go stack | Resource-heavy (1GB+ RAM), can feel bloated | Complex setup (Synapse server), higher resource usage |
| **Scale fit** | 1–50 | 1–50 | 1–50 (with effort) |

---

### 1.8 Email and Marketing Automation

| Tool | Type | Description |
|------|------|-------------|
| **Listmonk** | OSS, self-hosted | High-performance mailing list manager. Campaigns, templates, analytics, subscriber management. Single Go binary + Postgres. |
| **Mautic** | OSS, self-hosted | Full marketing automation: campaigns, email, landing pages, lead scoring, forms, segments. |
| **Mailu** | OSS, self-hosted | Full mail server (SMTP, IMAP, webmail, antispam, antivirus) in Docker. |

**Recommendation:** Listmonk for newsletters/campaigns (simple, fast). Mautic if you need full marketing automation with lead scoring. Mailu or docker-mailserver for self-hosted email (but consider the deliverability headaches).

| | Listmonk | Mautic | Mailu |
|---|----------|--------|-------|
| **Pros** | Tiny footprint, fast (Go), simple API, templating engine | Full marketing suite, campaign builder, lead scoring, forms | Complete mail server, Docker-native, admin UI |
| **Cons** | No lead scoring, no landing pages, purely email-focused | PHP/Symfony, resource-heavy, complex, can be buggy | Email deliverability is hard (SPF/DKIM/DMARC), IP reputation issues |
| **Scale fit** | 1–50 | 10–50 | 1–50 (with caveats) |

> **Note on self-hosted email:** Running your own SMTP for transactional/marketing email is possible but painful. Many self-hosted stacks use a cheap external relay (Mailgun, Amazon SES, Brevo — ~$0–20/month for low volume) for deliverability while keeping everything else self-hosted. This is the pragmatic approach.

---

### 1.9 Sales Pipeline

Most CRM tools (§1.2) include a sales pipeline. Dedicated options:

| Tool | Type | Description |
|------|------|-------------|
| **Twenty** | OSS, self-hosted | Has a pipeline view built into its CRM. |
| **SuiteCRM** | OSS, self-hosted | Full opportunity/pipeline management with forecasting. |
| **n8n + CRM** | Integration | Build custom pipeline automations (lead capture → CRM → notifications → follow-ups). |

**Recommendation:** Use your CRM's pipeline (Twenty or SuiteCRM). Automate transitions with n8n.

---

### 1.10 Support / Ticketing

| Tool | Type | Description |
|------|------|-------------|
| **Zammad** | OSS, self-hosted | Help desk with email, chat, phone, social media channels. Knowledge base, SLAs, LDAP. |
| **FreeScout** | OSS, self-hosted | Lightweight help desk (Help Scout alternative). Shared inbox, collision detection, modules. |
| **Trudesk** | OSS, self-hosted | Simple ticketing system with real-time updates, knowledge base, teams. |

**Recommendation:** Zammad for a full-featured help desk. FreeScout for a lightweight shared inbox approach.

| | Zammad | FreeScout | Trudesk |
|---|--------|-----------|---------|
| **Pros** | Multi-channel, SLAs, knowledge base, REST API, beautiful UI | Very lightweight (PHP), modular, familiar UI | Simple, real-time, Socket.io-based |
| **Cons** | Resource-heavy (Elasticsearch, Ruby), needs 4GB+ RAM | Some modules are paid, smaller community | Smaller community, fewer integrations |
| **Scale fit** | 5–50 | 1–30 | 1–20 |

---

### 1.11 Data Storage / Database

| Tool | Type | Description |
|------|------|-------------|
| **PostgreSQL** | OSS, self-hosted | The default choice. ACID, JSON support, extensions (PostGIS, pgvector), used by most tools in this stack. |
| **Redis / Valkey** | OSS, self-hosted | In-memory key-value store. Caching, queues, sessions. Valkey is the post-Redis-license community fork. |
| **MariaDB** | OSS, self-hosted | MySQL-compatible. Required by some tools (BookStack, Mautic). Use where Postgres isn't an option. |

**Recommendation:** PostgreSQL as the primary database. Most tools in this stack use it natively. Run a single shared Postgres instance with separate databases per service at small scale.

---

### 1.12 API Layer / Integration Layer

| Tool | Type | Description |
|------|------|-------------|
| **n8n** | OSS, self-hosted | Already your automation hub — also serves as an API/webhook bridge between tools. |
| **Traefik** | OSS, self-hosted | Reverse proxy with automatic HTTPS, Docker-native service discovery, middleware (rate limiting, auth). |
| **Kong / APISIX** | OSS, self-hosted | Full API gateway with rate limiting, auth, plugins. Only needed at scale. |

**Recommendation:** Traefik as reverse proxy + API gateway. n8n as the integration/webhook layer. Skip Kong until you have public APIs to manage.

---

### 1.13 Low-Code / Internal Tools

| Tool | Type | Description |
|------|------|-------------|
| **Budibase** | OSS, self-hosted | Low-code platform for internal apps. Connect to databases, REST APIs, build CRUD apps fast. |
| **NocoDB** | OSS, self-hosted | Airtable alternative. Turns any database into a smart spreadsheet with views, forms, automations. |
| **Appsmith** | OSS, self-hosted | Low-code for internal tools. Drag-and-drop UI builder, connect to APIs/DBs. |

**Recommendation:** NocoDB for spreadsheet-style data views and forms. Budibase for more complex internal apps.

| | NocoDB | Budibase | Appsmith |
|---|--------|----------|----------|
| **Pros** | Sits on top of existing Postgres, familiar spreadsheet UX, API auto-generated | Full app builder, automation built-in, self-contained | Powerful widget library, JS everywhere, git sync |
| **Cons** | Not a full app builder, limited logic | Heavier, smaller community than Appsmith | Resource-heavy, steeper learning curve |
| **Scale fit** | 1–50 | 1–50 | 5–50 |

---

### 1.14 Monitoring / Observability

| Tool | Type | Description |
|------|------|-------------|
| **Uptime Kuma** | OSS, self-hosted | Simple uptime monitor. HTTP, TCP, DNS, ping checks. Status pages. Notifications via 90+ channels. |
| **Prometheus + Grafana** | OSS, self-hosted | Industry-standard metrics collection + dashboarding. Pull-based, PromQL, alerting. |
| **Loki** | OSS, self-hosted | Log aggregation by Grafana Labs. Pairs with Grafana for log querying without heavy indexing (cheaper than ELK). |

**Recommendation:** Uptime Kuma for basic uptime monitoring from day one. Add Prometheus + Grafana + Loki when you need metrics and logs (usually 5+ people or production workloads).

---

### 1.15 Authentication / Identity Management

| Tool | Type | Description |
|------|------|-------------|
| **Authentik** | OSS, self-hosted | Full IdP: SSO (SAML, OIDC, LDAP), MFA, user management, enrollment flows, admin UI. Python/Django. |
| **Keycloak** | OSS, self-hosted | Enterprise IdP by Red Hat. SAML, OIDC, LDAP federation, fine-grained auth, admin console. |
| **LLDAP** | OSS, self-hosted | Lightweight LDAP server with a web UI. For tools that only support LDAP auth. |

**Recommendation:** Authentik for a modern, Docker-friendly IdP with great UX. Keycloak if you need enterprise-grade policy engine. LLDAP as a lightweight LDAP backend for legacy tools.

| | Authentik | Keycloak | LLDAP |
|---|-----------|----------|-------|
| **Pros** | Beautiful UI, flow designer, proxy provider, Docker-native | Very mature, enterprise features, huge community | Tiny footprint (~10MB RAM), simple, fast |
| **Cons** | Python stack (higher RAM), younger project | Java/heavy (512MB+ RAM), complex config, XML-heavy | LDAP only, no SSO/OIDC, very basic |
| **Scale fit** | 1–50 | 10–50+ | 1–30 (as LDAP complement) |

---

### 1.16 Website / CMS

| Tool | Type | Description |
|------|------|-------------|
| **WordPress** | OSS, self-hosted | The CMS. 40%+ of the web. Huge plugin/theme ecosystem. |
| **Ghost** | OSS, self-hosted | Modern publishing platform. Memberships, newsletters, clean editor. Node.js. |
| **Hugo / Astro** | OSS, self-hosted | Static site generators. Blazing fast, secure (no server-side runtime), deploy anywhere. |

**Recommendation:** Hugo/Astro for a simple company site (generate static HTML, serve via Nginx/Caddy). Ghost if you need a blog with memberships. WordPress if you need the plugin ecosystem.

| | Hugo/Astro | Ghost | WordPress |
|---|------------|-------|-----------|
| **Pros** | Zero attack surface, fastest possible, free hosting (Cloudflare Pages, etc.) | Clean editor, built-in newsletter, membership/paywall, SEO tools | Massive ecosystem, any feature exists as a plugin |
| **Cons** | Requires dev skills to customize, no admin UI for non-technical users | Smaller plugin ecosystem, Node.js memory usage | Security target, plugin bloat, needs constant updates |
| **Scale fit** | 1–50 | 1–50 | 1–50 |

---

### 1.17 Analytics / Dashboards

| Tool | Type | Description |
|------|------|-------------|
| **Plausible** | OSS, self-hosted | Lightweight, privacy-friendly web analytics. No cookies, GDPR-compliant. Single binary. |
| **Umami** | OSS, self-hosted | Similar to Plausible. Simple, fast, privacy-focused. Node.js + Postgres. |
| **Metabase** | OSS, self-hosted | Business intelligence / dashboards. Connect to any database, build charts, share reports. SQL or visual query builder. |
| **Grafana** | OSS, self-hosted | Already in monitoring stack — also excellent for business dashboards if data is in Postgres/Prometheus. |

**Recommendation:** Plausible or Umami for web analytics. Metabase for business intelligence and reporting.

---

### 1.18 AI Assistants / Automation Agents

| Tool | Type | Description |
|------|------|-------------|
| **Ollama** | OSS, self-hosted | Run LLMs locally (Llama, Mistral, Qwen, etc.). REST API. GPU or CPU inference. |
| **Open WebUI** | OSS, self-hosted | ChatGPT-like UI for Ollama/OpenAI-compatible backends. Multi-user, RAG, tool calling. |
| **AnythingLLM** | OSS, self-hosted | All-in-one: chat UI, RAG, document ingestion, agents, multi-provider. |
| **LocalAI** | OSS, self-hosted | OpenAI API-compatible server. Drop-in replacement for API calls to local models. |

**Recommendation:** Ollama + Open WebUI for internal AI chat. Use n8n AI nodes to integrate LLMs into workflows (summarise tickets, draft emails, classify leads).

---

### 1.19 Backup and Disaster Recovery

| Tool | Type | Description |
|------|------|-------------|
| **Restic** | OSS, self-hosted | Deduplicating backup tool. Encrypts at rest. Supports S3, SFTP, local, B2, Azure, GCS backends. |
| **BorgBackup** | OSS, self-hosted | Deduplicating archiver. Compression, encryption, pruning. Slightly faster dedup than Restic but SSH-only remote. |
| **Velero** | OSS, self-hosted | Kubernetes backup/restore. Snapshots of cluster state and persistent volumes. |
| **rclone** | OSS, self-hosted | Swiss army knife for cloud storage. Sync/copy to 50+ backends. Good for offsite replication. |

**Recommendation:** Restic for encrypted, deduplicated backups to MinIO (local) + B2/S3 (offsite). rclone for file-level sync and offsite replication.

**Backup strategy:**
- PostgreSQL: `pg_dump` via cron → Restic → MinIO → offsite (B2/S3)
- File data (Nextcloud, uploads): Restic → MinIO → offsite
- Docker volumes: Restic with pre/post hooks to stop containers if needed
- Config/IaC: Git (already versioned)
- Test restores monthly

---

### 1.20 DevOps / CI/CD

| Tool | Type | Description |
|------|------|-------------|
| **Gitea** | OSS, self-hosted | Lightweight Git forge. Repos, issues, PRs, CI/CD (Gitea Actions, GitHub Actions compatible), packages. Single binary. |
| **Woodpecker CI** | OSS, self-hosted | Lightweight CI/CD. YAML pipelines, Docker-native. Drone fork (after license change). |
| **Portainer** | OSS (CE), self-hosted | Docker/Swarm/K8s management UI. Deploy stacks, monitor containers, manage images. |

**Recommendation:** Gitea for code hosting + built-in CI. Portainer for container management. Skip Jenkins — it's bloated for small teams.

---

## 2. Suggested Overall Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     REVERSE PROXY (Traefik)                 │
│           TLS termination, routing, rate limiting           │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                    IDENTITY LAYER                           │
│              Authentik (SSO/OIDC/SAML/LDAP)                 │
│         All services authenticate through here              │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────┬───────────────┼───────────────┬────────────────┐
│  BUSINESS  │   INTERNAL    │   PLATFORM    │   INFRA        │
│            │               │               │                │
│ Twenty     │ Mattermost    │ Gitea         │ Prometheus     │
│ (CRM)      │ (Chat)        │ (Code/CI)     │ Grafana        │
│            │               │               │ Loki           │
│ InvoiceN.  │ Jitsi         │ Portainer     │ Uptime Kuma    │
│ (Billing)  │ (Video)       │ (Containers)  │                │
│            │               │               │ Restic         │
│ Plane      │ Nextcloud     │ MinIO         │ (Backups)      │
│ (Projects) │ (Files)       │ (Object Store)│                │
│            │               │               │                │
│ Zammad     │ BookStack     │ NocoDB        │                │
│ (Support)  │ (Wiki)        │ (Low-code)    │                │
│            │               │               │                │
│ Listmonk   │ Ollama+OWUI   │ Budibase      │                │
│ (Email)    │ (AI)          │ (Internal Apps)│               │
└────────────┴───────────────┴───────┬───────┴────────────────┘
                                     │
┌────────────────────────────────────┼────────────────────────┐
│              AUTOMATION LAYER (n8n)                         │
│     Webhooks, cron, event-driven workflows between all      │
│     services. Central integration point.                    │
└────────────────────────────────────┬────────────────────────┘
                                     │
┌────────────────────────────────────┼────────────────────────┐
│               DATA LAYER                                    │
│  PostgreSQL (shared, per-service DBs)  │  Valkey (cache)    │
└─────────────────────────────────────────────────────────────┘
```

### Key architectural principles

**Authentik is the single sign-on gateway.** Every tool authenticates via OIDC/SAML through Authentik. One user directory, one MFA policy, one place to provision/deprovision users.

**n8n is the event bus.** Webhooks from tools feed into n8n workflows. n8n calls APIs on other tools. This replaces point-to-point integrations with a central hub.

**PostgreSQL is the shared data layer.** One Postgres instance, multiple databases. Simplifies backups, monitoring, and resource management. At ~20+ users consider splitting to dedicated instances.

**Traefik is the front door.** All HTTP traffic enters through Traefik. Automatic Let's Encrypt certificates, middleware for auth forwarding to Authentik, rate limiting.

**MinIO is the object store.** S3-compatible backend for Nextcloud, Restic backups, Loki logs, and any tool that supports S3.

---

## 3. Automation Strategy

### Core automation patterns (all via n8n)

**Lead capture → CRM → Pipeline:**
1. Web form (Hugo/Ghost) submits to n8n webhook
2. n8n creates contact in Twenty CRM
3. n8n posts notification to Mattermost #sales channel
4. n8n creates follow-up task in Plane
5. n8n triggers welcome email via Listmonk

**Client onboarding:**
1. Deal marked "won" in Twenty → webhook to n8n
2. n8n creates project in Plane with template tasks
3. n8n creates shared folder in Nextcloud
4. n8n creates BookStack book for client documentation
5. n8n sends onboarding email via Listmonk
6. n8n creates initial invoice in InvoiceNinja

**Support ticket → Task → Resolution:**
1. Email arrives at Zammad → customer ticket created
2. Zammad webhook → n8n
3. n8n uses Ollama to classify ticket priority/category
4. If bug: n8n creates issue in Gitea + task in Plane
5. n8n posts to Mattermost #support with context
6. On resolution: n8n updates Zammad ticket + notifies customer

**Invoice automation:**
1. Cron trigger in n8n (monthly)
2. n8n queries Plane for completed billable tasks
3. n8n creates invoice in InvoiceNinja
4. n8n sends invoice email
5. On payment: InvoiceNinja webhook → n8n → updates CRM + Mattermost notification

**Employee onboarding:**
1. n8n workflow triggered manually or via form
2. Creates user in Authentik (propagates to all SSO-connected tools)
3. Adds user to appropriate Mattermost channels
4. Creates Nextcloud folder with onboarding docs
5. Creates Plane tasks for onboarding checklist
6. Sends welcome email via Listmonk

**Monitoring → Incident response:**
1. Uptime Kuma detects downtime → webhook to n8n
2. n8n posts alert to Mattermost #ops
3. n8n creates Zammad ticket for tracking
4. n8n creates Plane task for investigation
5. On resolution: n8n updates all channels

---

## 4. Deployment Strategy

### Option A: Single VPS / Homelab Server (1–10 people)

**Hardware:**
- 8 cores, 32GB RAM, 500GB NVMe SSD + 2TB HDD for data
- Or equivalent VPS (Hetzner CX41 / Contabo VPS L)

**Stack:** Docker Compose. One `docker-compose.yml` per logical group.

```
/opt/stacks/
├── core/              # Traefik, Authentik, PostgreSQL, Valkey
│   └── docker-compose.yml
├── business/          # Twenty, InvoiceNinja, Plane
│   └── docker-compose.yml
├── comms/             # Mattermost, Jitsi
│   └── docker-compose.yml
├── platform/          # Gitea, Nextcloud, MinIO, NocoDB
│   └── docker-compose.yml
├── automation/        # n8n, Listmonk
│   └── docker-compose.yml
├── monitoring/        # Uptime Kuma, Prometheus, Grafana, Loki
│   └── docker-compose.yml
├── ai/                # Ollama, Open WebUI
│   └── docker-compose.yml
└── support/           # Zammad, BookStack
    └── docker-compose.yml
```

Shared Docker network (`stack-net`) for inter-service communication. Traefik labels on each container for routing.

### Option B: Small Cluster (10–30 people)

**Hardware:** 3 nodes (bare metal or VPS), each 8 cores / 32GB RAM.

**Stack:** Docker Swarm (simpler) or K3s (Kubernetes-lite).

- Node 1: Core services (Authentik, Postgres, Traefik, n8n)
- Node 2: Business apps (CRM, Invoicing, PM, Support)
- Node 3: Platform + Monitoring (Gitea, Nextcloud, MinIO, Grafana)

Shared overlay network. GlusterFS or Longhorn for distributed storage.

### Option C: Cloud / Kubernetes (30–50 people)

K3s or managed Kubernetes. Helm charts for each service. Persistent volumes via Longhorn or cloud block storage. External managed Postgres (or CrunchyData operator) for reliability.

### Deployment automation

```bash
# All config in Git (Gitea)
# Deploy with:
cd /opt/stacks/core && docker compose pull && docker compose up -d
# Or via Portainer stacks (Git-backed)
# Or via Gitea Actions → SSH deploy
```

---

## 5. Cost Analysis

### Monthly cost: Self-hosted on a single VPS (1–10 people)

| Item | Provider | Cost/month |
|------|----------|------------|
| VPS (8 cores, 32GB, 500GB NVMe) | Hetzner CX41 | ~€16 |
| Domain | Cloudflare | ~€1 |
| Email relay (transactional) | Amazon SES / Brevo | €0–5 |
| Offsite backup (500GB) | Backblaze B2 | ~€2.50 |
| DNS/CDN | Cloudflare Free | €0 |
| **Total** | | **~€20–25/month** |

### Scaling cost: 3-node cluster (10–30 people)

| Item | Provider | Cost/month |
|------|----------|------------|
| 3× VPS (8c/32GB) | Hetzner | ~€48 |
| Managed Postgres (optional) | - | €0 (self-managed) |
| Email relay | SES | ~€5–10 |
| Offsite backup (2TB) | B2 | ~€10 |
| Domain + DNS | Cloudflare | ~€1 |
| **Total** | | **~€65–70/month** |

### Comparison: SaaS equivalent for 10 people

| SaaS | Cost/month |
|------|------------|
| Google Workspace | €120 |
| Slack | €80 |
| Jira | €80 |
| HubSpot CRM (paid) | €450+ |
| Notion | €80 |
| Freshdesk | €150 |
| Mailchimp | €50+ |
| **Total** | **€1,000+/month** |

Self-hosting saves **€900+/month at 10 people**, though it costs your time to maintain.

---

## 6. Scaling Considerations

### 1–2 people

Everything runs on one machine. Single Postgres instance. No clustering. Minimal monitoring (Uptime Kuma only). Backups via cron + Restic. This works fine.

### 10 people

**What starts to strain:**
- PostgreSQL needs tuning (shared_buffers, work_mem, connections). Consider PgBouncer for connection pooling.
- Nextcloud file sync gets slower — tune PHP-FPM workers, add Redis caching.
- Mattermost needs more RAM for concurrent WebSocket connections.
- n8n workflows may queue — add worker mode.
- Authentik session storage grows — ensure Valkey is persistent.

**Action:** Tune configs, add monitoring (Prometheus + Grafana), consider splitting database to dedicated host.

### 30 people

**What breaks or needs change:**
- Single server runs out of RAM. Move to multi-node.
- PostgreSQL needs its own dedicated node or managed service.
- Nextcloud may need to move to Seafile or cluster with external S3 (MinIO).
- Jitsi video conferencing needs a dedicated JVB (video bridge) node for 10+ simultaneous participants.
- n8n needs queue mode with separate workers.
- Zammad Elasticsearch needs its own node (memory hungry).
- Backups take longer — consider incremental snapshots, parallel Restic jobs.

### 50 people

**What needs a rethink:**
- Kubernetes (K3s) becomes justified for scheduling and scaling.
- Database: dedicated Postgres cluster (Patroni for HA) or managed service.
- Storage: MinIO cluster (4+ nodes for erasure coding) or external S3.
- Monitoring: full Prometheus + Grafana + Loki + Alertmanager stack.
- Identity: Authentik or Keycloak with HA (multiple replicas).
- Chat: Mattermost high-availability mode (multiple app nodes + shared DB).
- Consider moving to ERPNext (replaces separate CRM + invoicing + HR).

---

## 7. Minimal Stack (5–7 tools)

For the solo founder or 2-person team who needs to get running **today**.

| # | Domain | Tool | Why |
|---|--------|------|-----|
| 1 | Identity + Files + Calendar | **Nextcloud** | SSO, file storage, calendar, contacts, basic collaboration — covers 4 domains in one |
| 2 | Automation + Integration | **n8n** | Glue everything together. Webhooks, cron, API calls |
| 3 | Project Management | **Vikunja** | Lightweight tasks, kanban, CalDAV sync with Nextcloud |
| 4 | Invoicing | **InvoiceNinja** | Professional invoices, client portal, payment tracking |
| 5 | Communication | **Mattermost** | Team chat, integrations, webhook-ready |
| 6 | Documentation | **BookStack** | SOPs, runbooks, client docs — structured and searchable |
| 7 | Monitoring | **Uptime Kuma** | Know when things break. Status page for clients. |

**Deployment:** Single `docker-compose.yml`, one Postgres instance, Nginx Proxy Manager or Traefik in front.

**RAM requirement:** ~8GB total. Runs on a €8/month Hetzner VPS.

**What's missing:** CRM (use a spreadsheet or NocoDB), support ticketing (use email + Mattermost), CI/CD (use GitHub/GitLab free tier), analytics (add later), AI (use cloud APIs).

---

## 8. Advanced Stack (15–25 tools)

The full stack for a team of 5–50 with strong automation.

| # | Domain | Tool(s) |
|---|--------|---------|
| 1 | Reverse Proxy | Traefik |
| 2 | Identity / SSO | Authentik |
| 3 | Automation | n8n |
| 4 | CRM | Twenty |
| 5 | ERP / Invoicing | InvoiceNinja (or ERPNext at 20+) |
| 6 | Project Management | Plane |
| 7 | Documentation | BookStack + Outline |
| 8 | File Storage | Nextcloud + MinIO |
| 9 | Chat | Mattermost |
| 10 | Video | Jitsi Meet |
| 11 | Email Marketing | Listmonk |
| 12 | Support | Zammad |
| 13 | Database | PostgreSQL + Valkey |
| 14 | Low-Code | NocoDB + Budibase |
| 15 | Monitoring | Uptime Kuma + Prometheus + Grafana + Loki |
| 16 | Website/CMS | Hugo (static) or Ghost |
| 17 | Analytics | Plausible + Metabase |
| 18 | AI | Ollama + Open WebUI |
| 19 | Backup | Restic + rclone |
| 20 | DevOps | Gitea + Portainer |
| 21 | Email Server (optional) | docker-mailserver or Mailu |

**Total: 21 core services** (plus supporting infrastructure like Postgres, Valkey, MinIO).

---

## 9. Tools to Avoid

| Tool | Why to avoid |
|------|-------------|
| **GitLab (self-hosted)** | Massive resource hog (8GB+ RAM minimum). Gitea does 90% of what you need at 1/10th the resources. |
| **Jenkins** | Ancient UI, Groovy DSL pain, plugin dependency hell. Use Gitea Actions or Woodpecker CI instead. |
| **Odoo** | "Free" but the community edition is crippled. Key modules require the enterprise license (~€20/user/month). ERPNext is genuinely open. |
| **Elasticsearch (for logs)** | Memory monster. Loki + Grafana gives you 80% of the value at 10% of the resources. |
| **OpenProject** | Heavy (Ruby + Postgres + lots of RAM), slow, over-engineered for small teams. Plane or Vikunja is better. |
| **Rocket.Chat** | Resource-heavy and the company has been aggressive about pushing paid features. Mattermost Community is more stable. |
| **Discourse** | Great for public forums, but overkill and resource-heavy as an internal tool. Use BookStack or Outline instead. |
| **Kubernetes (at 1–10 people)** | Massive operational overhead for small teams. Docker Compose or Swarm is sufficient until 20–30+. |
| **Proxmox Mail Gateway** | Complex to maintain, deliverability issues. Use SES/Brevo as a relay. |
| **Taiga** | Development has slowed significantly. Plane is the better bet for new deployments. |
| **Wekan** | Kanban-only, limited features, slow development. Vikunja or Plane covers more ground. |
| **OnlyOffice Workspace** | Tries to be everything (mail, CRM, projects, docs) and does nothing particularly well. Use purpose-built tools. |

### General patterns to avoid

- **All-in-one suites** that claim to do everything (Bitrix24, OnlyOffice Workspace, HumHub). They're typically mediocre at each function. Better to compose purpose-built tools connected via n8n.
- **Tools that changed their license recently** (Elasticsearch → SSPL, Redis → RSAL, Terraform → BSL, Grafana → AGPL). Check the license. AGPL is fine for self-hosting. SSPL/RSAL/BSL may restrict usage.
- **Tools without active development.** Check GitHub commits. If the last commit was 6+ months ago, the project may be dying.
- **Single-maintainer projects** for critical infrastructure. If one person gets bored, your CRM disappears.

---

## Summary Decision Matrix

| If you need... | Use this | Instead of... |
|----------------|----------|---------------|
| Quick start, 1–2 people | Minimal stack (§7) | Overthinking it |
| Full company ops, 5–50 | Advanced stack (§8) | SaaS at €1000+/month |
| CRM without complexity | Twenty | Salesforce, HubSpot |
| Invoicing without ERP | InvoiceNinja | QuickBooks, Xero |
| Full ERP at 20+ people | ERPNext | Odoo, SAP |
| Team chat | Mattermost | Slack (€8/user/month) |
| Automation glue | n8n | Zapier (€20+/month) |
| SSO for everything | Authentik | Okta (€2/user/month) |
| Code hosting + CI | Gitea | GitLab (resource hog) |
| File storage | Nextcloud | Google Drive, Dropbox |
| Monitoring | Uptime Kuma + Grafana | Datadog (€15/host/month) |
| Backups | Restic + B2 | Veeam, Acronis |
