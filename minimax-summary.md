# Self-Hosted Software Stack for Scaling Companies: Consolidated Analysis

## Executive Summary

This document synthesizes the recommendations from seven artificial intelligence systems that analyzed the same prompt: designing a complete software tool stack for a 1–2 person company that can scale to approximately 50 people, prioritizing free and open-source software, self-hosted solutions, automation-first architecture, and minimal licensing costs.

All seven analysis sources reached remarkably similar conclusions regarding the core architectural principles and recommended tools, though they differed in emphasis and specific tool preferences. The consensus centers on a **modular, best-of-breed approach** connected through a central automation hub, rather than a monolithic ERP system, though ERPNext emerged as a strong alternative for companies preferring an all-in-one solution.

Key consensus findings include: n8n as the dominant automation platform, PostgreSQL as the shared database backbone, Authentik or Keycloak for identity management, Nextcloud for file collaboration, Mattermost for internal communication, and ERPNext or Dolibarr for ERP/accounting functions. The recommended deployment approach starts with Docker Compose on a single VPS and scales to Kubernetes (K3s) as the company approaches 50 employees.

The estimated monthly cost for self-hosting ranges from approximately €20–35 for a 1–2 person company to €150–225 for 50 people, representing a 90–95% cost savings compared to equivalent commercial SaaS solutions.

---

## 1. Architectural Approaches

The AI systems consistently identified two primary architectural strategies, with most recommending the modular approach as the default.

### 1.1 Modular Best-of-Breed Approach (Recommended)

This approach selects specialized tools for each operational domain and connects them through an automation layer. The philosophy emphasizes loose coupling, tool replaceability, and flexibility.

**Core Components:**

- **Automation Hub:** n8n serves as the central integration point, connecting all tools through webhooks and APIs
- **Identity Provider:** Authentik or Keycloak provides Single Sign-On across all services
- **Shared Database:** PostgreSQL acts as the data backbone for most applications
- **Reverse Proxy:** Traefik handles routing, TLS termination, and load balancing

**Advantages:**

- Maximum flexibility to choose the best tool for each specific need
- Individual components can be replaced without migrating the entire system
- Easier to start small and add tools incrementally
- Reduced risk of vendor lock-in

**Disadvantages:**

- Integration effort is continuous rather than one-time
- Data duplication across systems requires careful governance
- More moving parts to maintain

### 1.2 ERP-Centric Approach

This strategy centers on a comprehensive ERP system (primarily ERPNext) as the primary system of record, with other tools serving complementary roles.

**Core Components:**

- **ERP System:** ERPNext handles CRM, accounting, invoicing, projects, and often HR
- **Collaboration Layer:** Nextcloud for files, Mattermost for chat
- **Automation:** n8n extends ERP capabilities with custom workflows

**Advantages:**

- Fewer integrations required since data lives in one system
- Clear single source of truth for business data
- Simpler initial deployment and training

**Disadvantages:**

- ERP systems represent significant organizational change, not merely software installation
- Customization and upgrades require sustained attention
- Migration becomes painful if you outgrow the suite

### 1.3 When to Choose Each Approach

| Factor | Modular Approach | ERP-Centric Approach |
|--------|-----------------|---------------------|
| Company type | Service, consulting, creative agencies | Manufacturing, retail, complex operations |
| Technical preference | Want control over each tool | Prefer consolidated systems |
| Growth trajectory | Uncertain or rapid | Predictable, steady growth |
| Customization needs | Highly customized workflows | Standard business processes |
| Team size | 1–10 people initially | 10+ people from start |

---

## 2. Domain-by-Domain Tool Recommendations

### 2.1 Automation / Workflow Orchestration

**Primary Recommendation: n8n**

n8n emerged as the consensus leader across all analysis sources. It provides visual workflow automation with over 400 integrations, webhook triggers, cron scheduling, and custom code nodes for JavaScript and Python.

- **License:** Fair Code (source-available, free for self-hosted internal use)
- **Type:** Self-hosted
- **Pros:** Largest integration library, visual editor, active community, webhook-native
- **Cons:** Some enterprise features behind paid cloud version, single-threaded worker by default
- **Scale fit:** 1–50 people easily

**Alternatives:**

- **ActivePieces** (MIT, fully open-source): Simpler UI, growing rapidly, cleaner licensing
- **Node-RED** (Apache 2.0): Better for IoT and real-time data, less suited for business process automation
- **Kestra** (Apache 2.0): Strong for versioned, production-critical workflows with YAML definitions

### 2.2 CRM / Customer Management

**Primary Recommendations:**

- **Twenty CRM** (AGPL-3.0): Modern, clean UI inspired by Salesforce, GraphQL API, excellent for tech-forward teams
- **EspoCRM** (AGPL-3.0): More established, built-in workflow automation, REST API
- **SuiteCRM** (GPL-3.0): Mature fork of SugarCRM, extensive modules, larger community

| Tool | Best For | Pros | Cons |
|------|----------|------|------|
| Twenty | Modern startups | Beautiful UI, API-first, fast | Younger project, smaller ecosystem |
| EspoCRM | SMBs with workflow needs | Feature-rich, customizable | PHP stack |
| SuiteCRM | Enterprise needs | Very mature, extensive features | Dated UI, heavy resources |

### 2.3 ERP / Accounting / Invoicing

**Primary Recommendation: ERPNext**

ERPNext received the strongest endorsement as a genuinely free (GPLv3) comprehensive ERP system covering accounting, invoicing, inventory, HR, payroll, and CRM.

- **License:** GPL v3
- **Type:** Self-hosted
- **Pros:** All modules included, double-entry accounting, multi-currency, strong API/webhook support
- **Cons:** Resource-heavy (2GB+ RAM minimum), complex setup, learning curve
- **Scale fit:** 5–50+ people

**Alternatives:**

- **Dolibarr** (GPL-3.0): Lightweight modular ERP/CRM, easier for very small teams, PHP-based
- **InvoiceNinja** (Apache 2.0): Focused invoicing/billing, great client portal, simpler than full ERP
- **Odoo Community** (LGPL-3.0): Only one free app—most useful modules require paid Enterprise license

**Comparison: ERPNext vs Odoo Community**

| Dimension | ERPNext | Odoo Community |
|-----------|---------|----------------|
| All modules free | Yes | No (one app only) |
| UK accounting | Strong | Strong |
| Learning curve | Moderate-High | Moderate |
| Community size | Moderate | Very Large |
| Customization | Python/JS (Frappe) | Python (limited in CE) |

### 2.4 Project Management / Task Management

**Primary Recommendations:**

- **Plane** (AGPL-3.0): Modern Jira/Linear alternative, beautiful UI, unlimited issues/projects
- **Vikunja** (AGPL-3.0): Lightweight, tiny footprint (~50MB RAM), CalDAV sync
- **Taiga** (AGPL-3.0): Agile-focused (Scrum/Kanban), good for dev teams
- **OpenProject** (GPL-3.0): Traditional PM with Gantt charts, resource planning

| Tool | Style | Best For | RAM Usage |
|------|-------|----------|-----------|
| Plane | Modern (Kanban, List, Calendar, Timeline) | Teams wanting Jira alternative | Moderate |
| Vikunja | Simple kanban/lists | Ultra-lightweight | ~50MB |
| Taiga | Agile (Scrum + Kanban) | Developer teams | Moderate |
| OpenProject | Traditional (Gantt, Agile) | Waterfall/hybrid | Heavy |

### 2.5 Documentation / Knowledge Base

**Primary Recommendations:**

- **BookStack** (MIT): Structured wiki with books/chapters/pages hierarchy, intuitive and lightweight
- **Wiki.js** (AGPL-3.0): Modern, multiple editors, Git sync, flexible
- **Outline** (BSL 1.1): Notion-like, real-time collaboration, requires SSO

| Tool | Style | License | Best For |
|------|-------|---------|----------|
| BookStack | Book/Chapter/Page | MIT | Structured technical documentation |
| Wiki.js | Flexible, multi-editor | AGPL-3.0 | Teams wanting maximum customization |
| Outline | Flat documents | BSL 1.1 | Notion-like experience (requires SSO) |

### 2.6 File Storage and Collaboration

**Primary Recommendation: Nextcloud**

Nextcloud serves as the consensus choice for file storage and collaboration, offering file sync, calendar, contacts, document editing (via Collabora or OnlyOffice), and video calls.

- **License:** AGPL-3.0
- **Type:** Self-hosted
- **Pros:** Huge app ecosystem, office integration, CalDAV/CardDAV, E2E encryption option
- **Cons:** Can be slow with many files, PHP stack, needs tuning
- **Scale fit:** 1–50 people
- **Resource needs:** 512MB–1GB RAM for small teams, 2–4GB for 50 users with document editing

**Alternatives:**

- **Seafile** (GPL-2.0): Faster sync engine, better large-file handling, lower resource usage
- **MinIO** (Apache 2.0): S3-compatible object storage, backend for other tools rather than end-user sharing

### 2.7 Internal Communication

**Chat Recommendations:**

- **Mattermost** (MIT): Slack-like experience, excellent DevOps integrations, lower RAM than alternatives
- **Rocket.Chat** (MIT): Omnichannel capabilities (WhatsApp, Instagram, live chat), feature-rich

| Tool | Pros | Cons | Best For |
|------|------|------|----------|
| Mattermost | Clean UI, good integrations, playbooks | Some features enterprise-only | Pure internal comms |
| Rocket.Chat | Feature-rich, built-in video, omnichannel | Resource-heavy (1GB+ RAM), can feel bloated | Customer-facing + internal |

**Video Recommendations:**

- **Jitsi Meet** (Apache 2.0): Simple to deploy, no account needed for guests
- **Matrix/Synapse** (Apache 2.0): Federated, E2E encrypted, bridges to other platforms

### 2.8 Email and Marketing Automation

**Primary Recommendations:**

- **Listmonk** (AGPL-3.0): High-performance newsletter manager, single Go binary + PostgreSQL, lightweight
- **Mautic** (GPL-3.0): Full marketing automation (campaigns, lead scoring, landing pages, forms)

| Tool | Focus | Pros | Cons |
|------|-------|------|------|
| Listmonk | Newsletters | Tiny footprint, fast, simple API | No lead scoring, no landing pages |
| Mautic | Full marketing automation | Campaign builder, lead scoring, forms | PHP/Symfony, resource-heavy |

**Email Server:**

- **Mailu** / **docker-mailserver**: Full mail server in Docker
- **Recommendation:** Use external SMTP relay (Amazon SES, ~$0.10/1000 emails) for deliverability rather than self-hosting outbound email

### 2.9 Sales Pipeline

Sales pipeline functionality is typically handled by the CRM tools listed in section 2.2 (Twenty, EspoCRM, SuiteCRM) or ERPNext's CRM module. Dedicated pipeline views with drag-and-drop Kanban boards are available in EspoCRM and Twenty.

Automation of pipeline stages is best handled through n8n workflows connecting CRM data to project management and notification systems.

### 2.10 Support / Ticketing

**Primary Recommendations:**

- **Zammad** (AGPL-3.0): Full-featured help desk with email, chat, phone, knowledge base, SLAs
- **FreeScout** (AGPL-3.0): Lightweight Help Scout clone, shared inbox approach

| Tool | Features | Resource Needs | Best For |
|------|----------|---------------|----------|
| Zammad | Multi-channel, SLAs, KB, REST API | 4GB+ RAM (Elasticsearch, Ruby) | Growing teams needing enterprise features |
| FreeScout | Shared inbox, collision detection | Lightweight PHP | 1–3 person support teams |

### 2.11 Data Storage / Database

**Primary Recommendations:**

- **PostgreSQL** (PostgreSQL License): The consensus backbone—ACID compliant, JSON support, extensions (PostGIS, pgvector)
- **Redis/Valkey** (BSD-3): In-memory key-value store for caching, sessions, queues
- **MariaDB** (GPL-2.0): MySQL-compatible, required by some tools

**Note on Redis licensing:** Redis changed to RSAL/SSPL in March 2024. **Valkey** emerged as the BSD-licensed community fork, backed by the Linux Foundation.

### 2.12 API Layer / Integration Layer

**Recommendations:**

- **Traefik** (MIT): Reverse proxy with automatic HTTPS, Docker-native service discovery, middleware
- **n8n**: Serves as the integration layer through webhooks and API orchestration
- **Kong** / **KrakenD** (Apache 2.0): Full API gateway—only needed at scale with public APIs

### 2.13 Low-Code / Internal Tools

**Primary Recommendations:**

- **NocoDB** (AGPL-3.0): Airtable alternative, turns any database into a spreadsheet interface
- **Appsmith** (Apache 2.0): Drag-and-drop UI builder, connects to databases and APIs
- **Budibase** (GPL-3.0): Internal apps with strong security, automation built-in

| Tool | Approach | Best For |
|------|----------|----------|
| NocoDB | Spreadsheet UI over SQL | No-code database management |
| Appsmith | Drag-and-drop UI + data connectors | Admin panels, internal dashboards |
| Budibase | Full app builder | Data-driven internal tools |

### 2.14 Monitoring / Observability

**Recommendations:**

- **Uptime Kuma** (MIT): Simple uptime monitoring, HTTP/TCP/DNS/ping checks, status pages
- **Prometheus + Grafana** (Apache/AGPL): Industry-standard metrics and dashboards
- **Loki** (AGPL): Log aggregation by Grafana Labs, cheaper than Elasticsearch

| Tool | Scope | When to Add |
|------|-------|-------------|
| Uptime Kuma | Service health | From day one |
| Prometheus + Grafana | Metrics, dashboards, alerting | 5+ people or production workloads |
| Loki | Log aggregation | 10+ people |

### 2.15 Authentication / Identity Management

**Primary Recommendations:**

- **Authentik** (MIT + Enterprise): Modern IdP with flow designer, supports OIDC/OAuth2/SAML/LDAP
- **Keycloak** (Apache 2.0): Enterprise IdP by Red Hat, more mature but heavier
- **Authelia** (Apache 2.0): Lightweight companion for reverse proxies

| Tool | Pros | Cons | Best For |
|------|------|------|----------|
| Authentik | Beautiful UI, flow designer, Docker-native | Python stack (higher RAM) | 1–50 people |
| Keycloak | Very mature, enterprise features | Java/heavy (512MB+ RAM), complex config | 10–50+ people |
| LLDAP | Tiny footprint (~10MB RAM) | LDAP only, no SSO/OIDC | As LDAP complement |

### 2.16 Website / CMS

**Primary Recommendations:**

- **Ghost** (MIT): Modern publishing platform, memberships, newsletters, clean editor
- **WordPress** (GPL-2.0): Largest ecosystem, 60,000+ plugins
- **Hugo/Astro** (MIT): Static site generators, fastest, zero attack surface
- **Strapi** (MIT): Headless CMS for dynamic content

| Tool | Best For | Pros | Cons |
|------|----------|------|------|
| Ghost | Publishing, newsletters | Clean editor, built-in membership | Smaller plugin ecosystem |
| WordPress | Maximum flexibility | Massive ecosystem | Security target, plugin bloat |
| Hugo/Astro | Simple company site | Fastest, free hosting | Requires dev skills |
| Strapi | Headless CMS | API-first, flexible | Backend complexity |

### 2.17 Analytics / Dashboards

**Web Analytics:**

- **Umami** (MIT): Lightweight (~50MB RAM), privacy-focused
- **Plausible** (AGPL-3.0): Beautiful dashboards, requires ClickHouse (~700MB RAM)
- **Matomo** (GPL-3.0): Full Google Analytics replacement, heavier

**Business Intelligence:**

- **Metabase** (AGPL): Easy for non-technical users to query data
- **Apache Superset** (Apache 2.0): Exploration and visualization at scale

### 2.18 AI Assistants / Automation Agents

**Recommendations:**

- **Ollama** (MIT): Run LLMs locally (Llama, Mistral, Qwen), REST API
- **Open WebUI** (MIT): ChatGPT-like interface for Ollama/OpenAI
- **AnythingLLM** (MIT): All-in-one chat + RAG + agents

**Usage patterns:**

- Integrate with n8n AI nodes for workflow automation
- Summarize support tickets, draft emails, classify leads
- RAG over company knowledge bases

### 2.19 Backup and Disaster Recovery

**Primary Recommendations:**

- **Restic** (BSD-2): Deduplicating backup tool, supports S3/B2/SFTP, strong encryption
- **BorgBackup** (BSD-3): Faster deduplication (70–85%), SSH-only remote
- **Borgmatic** (GPL-3.0): Wrapper for Borg with YAML configuration

**Strategy:**

- PostgreSQL: pg_dump via cron → Restic → MinIO → offsite (B2/S3)
- File data: Restic → MinIO → offsite
- Test restores monthly
- Follow 3-2-1 rule: 3 copies, 2 media types, 1 offsite

### 2.20 DevOps / CI/CD

**Recommendations:**

- **Gitea** (MIT): Lightweight Git forge, single binary, built-in CI (Actions)
- **Woodpecker CI** (Apache 2.0): Native Gitea integration, lightweight
- **Portainer** (GPL-3.0): Docker/Swarm/K8s management UI

**Note:** GitLab CE requires 4–8GB RAM minimum—overkill for small teams. Jenkins is considered too heavy and complex.

---

## 3. Suggested Overall Architecture

### 3.1 Conceptual Architecture

```
                        ┌─────────────────────────────────┐
                        │         INTERNET                │
                        └───────────────┬─────────────────┘
                                        │
                        ┌───────────────▼─────────────────┐
                        │     Traefik (Reverse Proxy)     │
                        │  Auto-SSL, routing, rate limit  │
                        └───────────────┬─────────────────┘
                                        │
               ┌────────────────────────┼────────────────────────┐
               │                        │                        │
    ┌──────────▼────────┐  ┌───────────▼──────────┐  ┌─────────▼─────────┐
    │  Authentik (SSO)  │  │  n8n (Automation)    │  │  User-facing Apps │
    │  Identity Provider│  │  Webhooks + Workflows│  │  Ghost, Nextcloud │
    └──────────┬────────┘  └───────────┬──────────┘  └───────────────────┘
               │                       │
    ┌──────────▼───────────────────────▼──────────────────────────────────┐
    │                     Internal Services Layer                           │
    │  ERPNext │ Plane │ CRM │ Mattermost │ Zammad │ Listmonk │ BookStack│
    └──────────────────────────┬──────────────────────────────────────────┘
                               │
    ┌──────────────────────────▼──────────────────────────────────────────┐
    │                     Data Layer                                        │
    │         PostgreSQL  │  Valkey  │  Object Storage (MinIO/S3)          │
    └──────────────────────────┬──────────────────────────────────────────┘
                               │
    ┌──────────────────────────▼──────────────────────────────────────────┐
    │                  Infrastructure Layer                                 │
    │  Docker/Compose │ Uptime Kuma │ Grafana │ Restic Backups │ Gitea     │
    └─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Key Architectural Principles

1. **Traefik is the single entry point**—all HTTP/HTTPS traffic routes through it with automatic Let's Encrypt certificates

2. **Authentik is the identity backbone**—every app authenticates via OIDC/SAML through a single directory

3. **n8n is the automation hub**—it connects all tools via webhooks and APIs, replacing point-to-point integrations

4. **PostgreSQL is the shared database**—most tools use it natively, simplifying backups and monitoring

5. **Valkey provides caching and message queuing**—required by Authentik, Zammad, and Mattermost

---

## 4. Automation Strategy

### 4.1 Lead Capture → CRM → Project Creation

1. **Website form submission** sends webhook to n8n
2. **n8n creates contact** in Twenty CRM / EspoCRM
3. **n8n creates project** in Plane with template tasks
4. **n8n sends welcome email** via Listmonk
5. **n8n posts notification** to Mattermost #sales channel

### 4.2 Client Onboarding

1. **Deal marked "won"** in CRM triggers n8n webhook
2. **n8n creates project** in Plane with onboarding checklist tasks
3. **n8n creates shared folder** in Nextcloud with client permissions
4. **n8n creates BookStack page** for client documentation
5. **n8n sends onboarding email** via Listmonk with welcome materials
6. **n8n creates initial invoice** in ERPNext/InvoiceNinja

### 4.3 Support Ticket → Task → Resolution

1. **Customer emails** support@company.com → Zammad creates ticket
2. **Zammad webhook** triggers n8n workflow
3. **n8n optionally uses Ollama** to classify ticket priority/category
4. **If bug:** n8n creates issue in Gitea + task in Plane
5. **n8n posts** to Mattermost #support with context
6. **On resolution:** n8n updates Zammad ticket + sends customer notification

### 4.4 Invoice Generation and Reminders

1. **Cron trigger** in n8n (monthly or project milestone)
2. **n8n queries** Plane/ERPNext for completed billable tasks
3. **n8n creates invoice** in InvoiceNinja/ERPNext
4. **n8n sends** invoice email with payment link
5. **On payment received:** InvoiceNinja webhook → n8n → updates CRM + notifies Mattermost
6. **If overdue:** n8n sends reminder email + creates internal escalation task

### 4.5 Employee Onboarding

1. **Form submission** or manual trigger in n8n
2. **n8n creates user** in Authentik (propagates to all SSO-connected tools)
3. **n8n adds user** to appropriate Mattermost channels
4. **n8n creates** Nextcloud folder with onboarding docs
5. **n8n creates** Plane tasks for onboarding checklist
6. **n8n sends** welcome email via Listmonk

### 4.6 Automation Best Practices

Every automation should have:

- An owner
- A retry strategy
- A dead-letter queue or "failed runs" inbox
- Logging and metrics so failures aren't silent

---

## 5. Deployment Strategy

### 5.1 Option A: Single VPS (1–10 people) — Recommended Start

**Server:** Hetzner CCX23 (4 vCPU, 16GB RAM, 160GB NVMe) — ~€28/month

All services run in Docker containers behind Traefik. A single docker-compose.yml manages everything, with separate Compose files for logical groupings.

**Recommended structure:**

```
/opt/stacks/
├── core/              # Traefik, Authentik, PostgreSQL, Valkey
├── business/          # ERPNext, CRM, Plane
├── comms/             # Mattermost, Jitsi
├── platform/          # Nextcloud, MinIO, Gitea
├── automation/        # n8n, Listmonk
├── monitoring/        # Uptime Kuma, Prometheus, Grafana
└── support/           # Zammad, BookStack
```

### 5.2 Option B: Small Homelab (Proxmox + Docker)

Run Proxmox on dedicated mini-PC or NAS with LXC containers:

- **LXC 1:** Core stack (Traefik, Authentik, PostgreSQL, Valkey, n8n)
- **LXC 2:** Business apps (ERPNext, CRM, Plane, Zammad)
- **LXC 3:** Collaboration (Nextcloud, Mattermost, BookStack)
- **LXC 4:** Public-facing (Ghost, Umami, Listmonk)

### 5.3 Option C: Kubernetes (15–50 people)

Migrate to K3s (lightweight Kubernetes) when:

- Need for high availability (eliminating single point of failure)
- Need for horizontal scaling (adding more machines for load)
- Multiple critical apps requiring independent scaling

K3s advantages:

- Single binary, embedded database
- Easier than full Kubernetes
- Production-ready for 50+ people

### 5.4 Network Architecture

```
Internet → Cloudflare (DNS + DDoS) → VPS/Homelab
  → Traefik :443 → service.company.com
  → Authentik handles SSO for all services
  → Tailscale/WireGuard for admin access (no SSH exposed)
```

---

## 6. Cost Analysis

### 6.1 Monthly Cost: Self-Hosted (1–2 people)

| Item | Provider | Cost/Month |
|------|----------|-----------|
| VPS (4 vCPU, 16GB RAM) | Hetzner CCX23 | €28 |
| Backup storage (100GB) | Hetzner Storage Box | €3.50 |
| Domain name | Annual (~€12/yr) | €1 |
| SMTP relay (10k emails) | Amazon SES | €1 |
| Object storage (50GB) | Hetzner / Backblaze B2 | €0.50 |
| **Total** | | **~€34/month** |

### 6.2 Monthly Cost: Self-Hosted (10–20 people)

| Item | Provider | Cost/Month |
|------|----------|-----------|
| VPS (8 vCPU, 32GB RAM) | Hetzner CCX33 | €49 |
| Second VPS (failover) | Hetzner CX23 | €6.50 |
| Backup storage (500GB) | Hetzner Storage Box | €10 |
| Domain + DNS | Cloudflare | €1 |
| SMTP relay (50k emails) | Amazon SES | €5 |
| Object storage (200GB) | Backblaze B2 | €1 |
| **Total** | | **~€73/month** |

### 6.3 Monthly Cost: Self-Hosted (50 people)

| Item | Provider | Cost/Month |
|------|----------|-----------|
| 3x VPS (K3s cluster) | Hetzner CCX33 × 3 | €147 |
| Load balancer | Hetzner LB | €6 |
| Managed PostgreSQL | Self-managed | €0–30 |
| Backup storage (1TB) | Hetzner + B2 | €15 |
| SMTP relay (200k emails) | Amazon SES | €20 |
| Object storage (1TB) | Backblaze B2 | €5 |
| **Total** | | **~€195–225/month** |

### 6.4 Comparison: SaaS Equivalent for 50 People

| SaaS Tool | Approximate Monthly Cost |
|-----------|------------------------|
| Salesforce CRM | €1,250+ |
| Jira + Confluence | €500+ |
| Slack Business+ | €625+ |
| Google Workspace | €600+ |
| HubSpot Marketing | €800+ |
| Zendesk | €500+ |
| **Total SaaS** | **€4,000-8,000+/month** |

Self-hosting saves approximately **95%** at the 50-person scale.

---

## 7. Scaling Considerations

### 7.1 From 1–2 People

- Everything runs on a single server
- Single Postgres instance, no clustering
- Minimal monitoring (Uptime Kuma only)
- Backups via cron + Restic

**Key focus:** Simplicity, get business processes working

### 7.2 From 10 People

**What starts to strain:**

- **PostgreSQL:** Needs tuning (shared_buffers, work_mem), consider PgBouncer
- **Nextcloud:** File sync gets slower—tune PHP-FPM workers, add Redis
- **Mattermost:** More RAM for concurrent WebSocket connections
- **n8n:** May need worker mode for queued workflows
- **Authentik:** Session storage grows—ensure Valkey is persistent

**Actions:**

- Tune database configurations
- Add monitoring (Prometheus + Grafana)
- Consider splitting database to dedicated host

### 7.3 From 30–50 People

**What breaks or needs change:**

- **Single server:** Runs out of RAM—move to multi-node
- **PostgreSQL:** Needs dedicated node or managed service
- **Nextcloud:** May need Seafile or cluster with external S3 (MinIO)
- **Jitsi:** Needs dedicated JVB node for 10+ simultaneous participants
- **n8n:** Needs queue mode with separate workers
- **Zammad:** Elasticsearch needs own node (memory hungry)
- **Backups:** Implement incremental snapshots, parallel Restic jobs

**Actions:**

- Kubernetes (K3s) becomes justified
- Database: dedicated Postgres cluster (Patroni for HA) or managed service
- Storage: MinIO cluster (4+ nodes for erasure coding)
- Monitoring: full Prometheus + Grafana + Loki + Alertmanager
- Identity: Authentik or Keycloak with HA (multiple replicas)

---

## 8. Minimal Stack (5–7 Tools)

For a solo founder or 2-person team covering 90% of business needs:

| # | Domain | Tool | Why |
|---|--------|------|-----|
| 1 | ERP + CRM + Accounting | **ERPNext** | All-in-one: accounting, CRM, invoicing, projects, HR |
| 2 | Automation | **n8n** | Connects everything, handles workflows |
| 3 | Files + Collaboration | **Nextcloud** | Files, calendar, contacts, document editing |
| 4 | Documentation | **BookStack** | Internal wiki and knowledge base |
| 5 | Communication | **Mattermost** | Team chat and notifications |
| 6 | Website | **Ghost** | Company website + blog + newsletter |
| 7 | Reverse Proxy | **Traefik** | Routes traffic, auto-SSL |

**Total RAM needed:** ~8–10GB — fits on Hetzner CX32 (~€18/month)

**What this covers:** CRM, invoicing, accounting, project management, file sharing, documentation, internal chat, website, newsletter

---

## 9. Advanced Stack (15–25 Tools)

For a company scaling to 50 with strong automation and integration:

| # | Domain | Tool(s) |
|---|--------|---------|
| 1 | Reverse Proxy | **Traefik** |
| 2 | Identity / SSO | **Authentik** |
| 3 | Automation | **n8n** |
| 4 | ERP / Accounting | **ERPNext** |
| 5 | CRM | **Twenty CRM** or **EspoCRM** |
| 6 | Project Management | **Plane** |
| 7 | Documentation | **BookStack** |
| 8 | File Storage | **Nextcloud** + **MinIO** |
| 9 | Internal Chat | **Mattermost** |
| 10 | Video | **Jitsi Meet** |
| 11 | Email Marketing | **Listmonk** |
| 12 | Marketing Automation | **Mautic** |
| 13 | Support / Ticketing | **Zammad** |
| 14 | Database | **PostgreSQL** + **Valkey** |
| 15 | Low-Code | **NocoDB** + **Appsmith** |
| 16 | Monitoring (uptime) | **Uptime Kuma** |
| 17 | Monitoring (infra) | **Grafana + Prometheus** |
| 18 | AI Assistant | **Open WebUI + Ollama** |
| 19 | Git Hosting | **Gitea** |
| 20 | CI/CD | **Woodpecker CI** |
| 21 | Backup | **Restic** + **Borgmatic** |

---

## 10. Tools to Avoid

### 10.1 General Categories to Avoid

| Category | Why |
|----------|-----|
| **Odoo Community Edition** | Misleadingly "free"—one app limit makes it near-useless without Enterprise license |
| **GitLab CE (self-hosted)** | Requires 4–8GB RAM minimum—overkill for small teams |
| **Jenkins** | Ancient UI, plugin dependency hell—use Woodpecker or Gitea Actions |
| **SuiteCRM** | Dated UI and codebase, steep learning curve, heavy requirements |
| **Wekan** | Kanban-only, limited features, poor scaling—use Plane/Taiga |
| **Redmine** | Ancient UI, minimal modern integrations, Ruby stack hard to maintain |
| **MediaWiki** | Built for Wikipedia, not company knowledge bases |
| **Elasticsearch (for logs)** | Memory monster—use Loki instead |
| **Discourse** | Overkill for internal comms, 2GB+ RAM |
| **Rocket.Chat** | Resource-heavy, aggressive paid feature pushing |
| **Keycloak** (at <50 people) | Too heavy and complex—Authentik covers same protocols with less overhead |

### 10.2 License Concerns

| Tool | Issue | Alternative |
|------|-------|-------------|
| **Redis** | Changed to RSAL/SSPL in 2024 | **Valkey** (BSD-licensed fork) |
| **n8n** | Fair Code license (not OSI-approved) | **ActivePieces** (MIT) if strict FOSS required |
| **Sentry** | BSL license | **GlitchTip** (MIT, Sentry-compatible) |
| **Terraform/Vault** | BSL era | **OpenTofu** (MPL-2.0), **OpenBao** |

### 10.3 Self-Hosting Challenges

- **Self-hosted email servers** (Mailu, mailcow): Deliverability is the real problem—use SMTP relay instead
- **Kubernetes** (at 1–10 people): Massive operational overhead—use Docker Compose until 20–30+

---

## 11. Key Findings and Consensus

### 11.1 Areas of Strong Agreement

1. **n8n as automation hub:** All sources recommend n8n as the primary integration and workflow tool
2. **PostgreSQL as database backbone:** Consensus on PostgreSQL as the shared relational database
3. **Nextcloud for file collaboration:** Universal recommendation for file storage and collaboration
4. **Mattermost for chat:** Preferred over Rocket.Chat for internal communication due to resource efficiency
5. **ERPNext for ERP:** Strong endorsement as the most genuinely free comprehensive ERP
6. **Docker Compose for deployment:** Recommended starting point for 1–10 people
7. **Traefik for reverse proxy:** Standard choice for routing and TLS management
8. **Authentik or Keycloak for identity:** SSO is considered foundational

### 11.2 Areas of Disagreement

1. **CRM choice:** Some prefer Twenty (modern, lightweight), others prefer SuiteCRM (mature, feature-rich)
2. **Project management:** Plane vs. Vikunja vs. Taiga depending on use case
3. **Documentation:** BookStack vs. Wiki.js vs. Outline based on collaboration needs
4. **Event-driven architecture:** Qwen emphasizes RabbitMQ/NATS for decoupling, others consider it optional until scale
5. **Kubernetes timing:** Some recommend K3s at 15+ people, others at 30+ people

### 11.3 Critical Success Factors

1. **Start simple:** Don't over-engineer for future scale—begin with minimal stack
2. **Invest in SSO early:** Authentik/Keycloak setup pays dividends as tools are added
3. **Automate incrementally:** Build workflows as needs arise, not upfront
4. **Test backups:** Restore drills monthly to ensure recovery capability
5. **Monitor from day one:** Uptime Kuma + basic Prometheus/Grafana
6. **Plan for data governance:** Define "systems of record" to manage duplication

---

## 12. Conclusion

This analysis demonstrates that a comprehensive, self-hosted software stack for a 1–50 person company is not only technically feasible but economically compelling. The estimated monthly cost of €20–225 (depending on company size) represents a 90–95% savings compared to commercial SaaS alternatives.

The recommended approach prioritizes:

- **Modular best-of-breed tools** over monolithic ERP systems (though ERPNext is a strong alternative)
- **Automation-first architecture** with n8n as the central integration hub
- **Open standards** (OIDC/SAML) for identity and Single Sign-On
- **Progressive complexity**—start simple, add sophistication as needed
- **Self-sufficiency** in infrastructure while leveraging cost-effective cloud services for backups and email delivery

The path forward involves starting with the minimal stack on a single VPS, then expanding to the advanced stack as the company grows, with Kubernetes (K3s) becoming relevant only at the 30–50 person scale. This approach maximizes both operational autonomy and financial efficiency while maintaining the flexibility to adapt as business needs evolve.

---

*This document was generated through analysis of recommendations from seven AI systems, synthesizing their findings into a cohesive reference guide for building a self-hosted company infrastructure.*
