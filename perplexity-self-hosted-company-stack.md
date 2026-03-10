# Complete Self-Hosted Company Stack: From 1 Person to 50

## Architecture Philosophy

This stack follows a **modular, Docker-first architecture** where each tool runs as an independent container, connected through a shared identity provider (Authentik), a central automation hub (n8n), and a reverse proxy (Traefik). PostgreSQL serves as the shared database engine for most tools, and all services communicate via REST APIs and webhooks.

---

## Domain-by-Domain Tool Recommendations

### 1. Automation / Workflow Orchestration

| Tool | Licence | Type | Best For |
|------|---------|------|----------|
| **n8n** | Fair Code (Sustainable Use) | Self-hosted | Complex workflows, 400+ integrations, mature ecosystem |
| **Activepieces** | MIT | Self-hosted | Simpler UI, fully open-source, growing fast |

**n8n** is the recommended primary choice. It has the largest integration library (~400 nodes), a visual workflow builder, supports webhooks, custom code nodes (JS/Python), and handles branching/error-handling elegantly. Its Fair Code licence means it's free to self-host for internal use. The main trade-off vs Activepieces is that n8n requires slightly more technical ramp-up, but its maturity and plugin ecosystem are unmatched.

**Activepieces** is a valid Option B if you want a pure MIT licence and a cleaner step-based builder. It's growing rapidly but has fewer integrations today.

**Verdict:** Start with n8n. It becomes the central nervous system of your entire stack.

---

### 2. CRM / Customer Management

| Tool | Licence | Tech Stack | Best For |
|------|---------|-----------|----------|
| **Twenty CRM** | AGPL-3.0 | TypeScript, React, PostgreSQL | Modern startups wanting clean UI and API-first design |
| **EspoCRM** | AGPL-3.0 | PHP 8, MySQL/PostgreSQL | Feature-rich CRM for SMBs with workflow automation |

**Twenty CRM** is a newer entrant with a modern interface inspired by Salesforce, strong GraphQL/REST APIs, and excellent developer experience. It's lightweight and scales well.

**EspoCRM** is more established, with built-in workflow automation, a REST API, customisable modules, and an intuitive interface. It handles sales pipelines, email integration, and contact management out of the box.

**Verdict:** Twenty CRM for tech-forward teams; EspoCRM for more traditional CRM needs.

---

### 3. ERP / Accounting / Invoicing

| Tool | Licence | Modules | Best For |
|------|---------|---------|----------|
| **ERPNext** | GPL v3 | 20+ (Accounting, HR, Stock, CRM, Projects) | Small-medium businesses wanting a full free ERP |
| **Odoo Community** | LGPL-3.0 | 1 free app; 40+ in Enterprise | Teams wanting polished UI and massive app ecosystem |

**ERPNext** is the strongest recommendation. It's genuinely free for self-hosting with all modules included: double-entry accounting, invoicing, inventory, HR, payroll, project management, and CRM. Built on the Frappe framework (Python), it has strong APIs and webhook support. UK tax compliance is well-supported.

**Odoo Community Edition** is more limited — you get one free app, and advanced features (multi-company, Studio, full accounting) are locked behind the Enterprise licence (~€20-30/user/month). However, its UI is more polished and its app marketplace is enormous (30,000+ apps).

| Dimension | ERPNext | Odoo CE |
|-----------|---------|---------|
| All modules free | ✅ Yes | ❌ One app only |
| Self-hosted cost | Free | Free (limited) |
| UK accounting | ✅ Strong | ✅ Strong |
| Learning curve | Moderate-High | Moderate |
| Community size | Moderate | Very Large |
| Customisation | Python/JS (Frappe) | Python (limited in CE) |

**Verdict:** ERPNext for a truly free, full-featured ERP. Odoo only if you're prepared to pay for Enterprise.

---

### 4. Project Management / Task Management

| Tool | Licence | Style | Best For |
|------|---------|-------|----------|
| **Plane** | AGPL-3.0 | Modern (Kanban, List, Calendar, Timeline) | Teams wanting a Jira/Linear alternative |
| **OpenProject** | GPL-3.0 | Traditional PM (Gantt, Agile, Docs) | Waterfall/hybrid project management |
| **Taiga** | AGPL-3.0 | Agile (Scrum + Kanban) | Developer-focused agile teams |

**Plane** is the top recommendation. It installs with a single command, has 100% feature parity between cloud and self-hosted, supports unlimited issues/projects, and has a beautiful modern UI. It handles sprints, modules, epics, and pages (built-in wiki).

**OpenProject** is better for traditional project management with Gantt charts, resource planning, and time tracking, but has a steeper learning curve and heavier resource requirements.

**Verdict:** Plane for most teams. OpenProject if you need Gantt-heavy waterfall PM.

---

### 5. Documentation / Knowledge Base

| Tool | Licence | Style | Best For |
|------|---------|-------|----------|
| **BookStack** | MIT | Book → Chapter → Page hierarchy | Structured technical documentation |
| **Outline** | BSL 1.1 | Notion-like, flat documents | Modern wiki with real-time collaboration |
| **Wiki.js** | AGPL-3.0 | Flexible, multiple editors | Teams wanting maximum customisation |

**BookStack** is the easiest to set up and use. Its book/chapter/page metaphor makes organising documentation intuitive. Built on PHP/Laravel with MySQL, it's lightweight and has excellent search. Free, MIT-licensed, with LDAP/SAML/OAuth support.

**Outline** feels more like Notion — great for real-time collaboration and modern teams. However, it requires SSO (Authentik/Keycloak) as it has no standalone auth, and uses BSL 1.1 (not truly open-source).

**Verdict:** BookStack for simplicity and true open-source; Outline if you want a Notion-like experience and already have SSO.

---

### 6. File Storage and Collaboration

| Tool | Licence | Features | Best For |
|------|---------|----------|----------|
| **Nextcloud** | AGPL-3.0 | Files, Calendar, Contacts, Talk, Office | All-in-one private cloud replacement |

**Nextcloud** is the undisputed choice here. It replaces Google Drive/Workspace with file sync, shared folders, online document editing (via Collabora or OnlyOffice), calendars, contacts, and even video calls (Nextcloud Talk). It supports SSO via SAML/OIDC, has granular permissions, and scales to enterprise level.

**Resource needs:** ~512MB–1GB RAM for small teams, 2–4GB for 50 users with document editing enabled.

---

### 7. Internal Communication

| Tool | Licence | Channels | Best For |
|------|---------|----------|----------|
| **Mattermost** | MIT (Free tier) | Chat, threads, boards | DevOps teams, developer-heavy orgs |
| **Rocket.Chat** | MIT | Chat, video, omnichannel, federation | Customer-facing + internal comms |

**Mattermost** offers the most Slack-like experience with excellent DevOps integrations (GitLab, Jenkins, Jira plugins). The free self-hosted edition covers most needs. It runs on a tiny VPS comfortably.

**Rocket.Chat** provides omnichannel capabilities (WhatsApp, Instagram, Twitter, live chat widget), making it ideal if you need both internal team chat AND customer communication from one platform.

**Verdict:** Mattermost for pure internal comms; Rocket.Chat if you also need customer-facing channels.

---

### 8. Email and Marketing Automation

| Tool | Licence | Approach | Best For |
|------|---------|----------|----------|
| **Listmonk** | AGPL-3.0 | Newsletter manager (Go + PostgreSQL) | Fast bulk email, simple newsletters |
| **Mautic** | GPL-3.0 | Full marketing automation (PHP + MySQL) | Lead nurturing, drip campaigns, landing pages |

**Listmonk** is incredibly lightweight — a single Go binary + PostgreSQL. It handles subscriber management, templating, campaign scheduling, and multi-threaded bulk sending of millions of emails. Its simplicity is its strength.

**Mautic** is a full HubSpot alternative with visual workflow automation, lead scoring, behavioural tracking, multi-channel campaigns, landing pages, and CRM integration. It's heavier (PHP/Symfony) and needs tuning for performance at scale.

Both require an SMTP relay (Amazon SES at ~$0.10/1000 emails, or self-hosted Postal for zero cost).

**Verdict:** Listmonk for newsletters; Mautic if you need full marketing automation. They can coexist.

---

### 9. Sales Pipeline

The CRM tools above (Twenty CRM or EspoCRM) handle sales pipelines natively. ERPNext also includes a sales pipeline module. For a dedicated approach, use **EspoCRM** with its drag-and-drop pipeline editor and visual Kanban boards.

Alternatively, n8n can automate the pipeline: **Lead capture → CRM entry → Email sequence via Listmonk → Task creation in Plane → Notification in Mattermost**.

---

### 10. Support / Ticketing

| Tool | Licence | Features | Best For |
|------|---------|----------|----------|
| **Zammad** | AGPL-3.0 | Full ticketing: email, chat, phone, social, KB, SLAs | Growing teams needing enterprise features |
| **FreeScout** | AGPL-3.0 | Shared inbox, lightweight, modular | 1-3 person support with simple needs |

**Zammad** ships every feature in its open-source edition: knowledge base, live chat, phone/CTI integration, LDAP/SAML/OAuth, SLAs, macros, triggers, webhooks, text modules, time accounting, and reporting. No paid add-ons needed. Requires PostgreSQL + Redis + Elasticsearch (~4GB RAM minimum).

**FreeScout** is a lightweight Help Scout clone. Its core is free but many features (KB, satisfaction ratings, time tracking) require paid modules at £2–20 each. Best for very small teams.

**Verdict:** Zammad for serious support. FreeScout for minimal needs.

---

### 11. Data Storage / Database

| Tool | Licence | Type | Use |
|------|---------|------|-----|
| **PostgreSQL** | PostgreSQL Licence | Relational | Primary database for most tools |
| **Redis** | BSD-3 | In-memory KV | Caching, sessions, queues |
| **ClickHouse** | Apache-2.0 | Columnar analytics | Analytics (used by Plausible) |

PostgreSQL is the shared backbone — ERPNext, n8n, Nextcloud, Authentik, Plane, Twenty CRM, Listmonk, and Zammad all support it. Running a single PostgreSQL instance (or cluster) with multiple databases simplifies backup and maintenance.

Redis is required by several tools (Authentik, Zammad, Mattermost) for caching and message queuing.

---

### 12. API Layer / Integration Layer

| Tool | Licence | Function | Best For |
|------|---------|----------|----------|
| **Traefik** | MIT | Reverse proxy + API gateway + auto-SSL | Routing all traffic, auto Let's Encrypt |
| **n8n** | Fair Code | Webhook endpoints + API orchestration | Connecting tools via REST/webhooks |

**Traefik** is the recommended reverse proxy and API gateway. It auto-discovers Docker containers via labels, provisions Let's Encrypt SSL certificates automatically, handles load balancing, rate limiting, and supports OIDC/OAuth middleware. It's the single entry point for all your services.

n8n doubles as an integration layer — exposing webhook URLs that external services can call, and orchestrating API calls between your internal tools.

---

### 13. Low-Code / Internal Tools

| Tool | Licence | Approach | Best For |
|------|---------|----------|----------|
| **Appsmith** | Apache-2.0 | Drag-and-drop UI + data connectors | Admin panels, internal dashboards |
| **NocoDB** | AGPL-3.0 | Airtable-like spreadsheet UI over SQL | No-code database management |
| **Budibase** | GPL-3.0 | Internal apps with strong security | Data-driven internal tools |

**NocoDB** turns any PostgreSQL/MySQL database into a spreadsheet-like interface. Non-technical team members can view and edit data without touching SQL. It's the quickest win for bridging technical and non-technical users.

**Appsmith** is ideal for building custom admin panels, customer dashboards, or operational tools by connecting to your databases and APIs via drag-and-drop widgets.

---

### 14. Monitoring / Observability

| Tool | Licence | Scope | Best For |
|------|---------|-------|----------|
| **Uptime Kuma** | MIT | Uptime monitoring (HTTP, TCP, Ping, DNS) | Simple service health checks |
| **Grafana + Prometheus** | AGPL-3.0 / Apache-2.0 | Full metrics, dashboards, alerting | Deep infrastructure observability |
| **Netdata** | GPL-3.0 | Real-time system metrics | Per-server resource monitoring |

**Uptime Kuma** is dead simple — checks every 20 seconds, sends alerts via email/Slack/Telegram/webhook, and has a beautiful status page. Use it for service-level monitoring.

**Grafana + Prometheus** is the standard for infrastructure observability. Prometheus scrapes metrics; Grafana visualises them. Add Loki for log aggregation. This is the stack to adopt when scaling beyond 10 people.

---

### 15. Authentication / Identity Management

| Tool | Licence | Architecture | Best For |
|------|---------|-------------|----------|
| **Authentik** | MIT + Enterprise | Full IdP (OIDC, OAuth2, SAML, LDAP) | SMB/teams wanting modern SSO |
| **Keycloak** | Apache-2.0 | Full IdP (enterprise-grade) | Large orgs with complex AD/LDAP |

**Authentik** is the recommended choice. It provides a modern, clean admin UI with a visual flow builder for custom authentication journeys (conditional MFA, enrollment, password reset). It supports OIDC, OAuth2, SAML, and LDAP, and integrates cleanly with every tool in this stack. Nearly 20,000 GitHub stars and rapid community growth.

**Keycloak** is the enterprise heavyweight backed by Red Hat. More features, but steeper learning curve and heavier resource usage. Choose it only if you need complex Active Directory federation or fine-grained authorization policies.

**Verdict:** Authentik for this stack size. It's the SSO backbone that ties everything together.

---

### 16. Website / CMS

| Tool | Licence | Focus | Best For |
|------|---------|-------|----------|
| **Ghost** | MIT | Publishing, newsletters, memberships | Content-focused businesses |
| **WordPress** | GPL-2.0 | Everything (plugins, themes, e-commerce) | Maximum flexibility and ecosystem |

**Ghost** is a modern Node.js-based CMS built for professional publishing. It includes built-in newsletter functionality, membership/subscription management, and a clean Markdown editor. Self-hosted via Docker, it's lightweight and fast.

**WordPress** remains the most flexible option with 60,000+ plugins. If you need e-commerce (WooCommerce), complex forms, multilingual support, or deep customisation, WordPress is the pragmatic choice.

**Verdict:** Ghost for clean publishing; WordPress for everything else.

---

### 17. Analytics / Dashboards

| Tool | Licence | Resource Usage | Best For |
|------|---------|---------------|----------|
| **Umami** | MIT | ~50MB RAM, 2KB script | Simple, lightweight analytics |
| **Plausible CE** | AGPL-3.0 | ~700MB RAM (needs ClickHouse) | Beautiful dashboards, goal tracking |
| **Matomo** | GPL-3.0 | ~350MB RAM | Full Google Analytics replacement |

**Umami** is the lightest option — 50MB RAM, 2KB tracking script, city-level geo data, easy script/endpoint renaming to bypass ad blockers. Perfect for most small businesses.

**Plausible Community Edition** has the most beautiful dashboard but requires ClickHouse alongside PostgreSQL, increasing RAM needs to ~700MB+.

**Matomo** is the full GA replacement with funnels, cohorts, e-commerce tracking, session recording, and heatmaps, but has a 22KB script and heavier server footprint.

**Verdict:** Umami for simplicity; Matomo for full analytics power.

---

### 18. AI Assistants / Automation Agents

| Tool | Licence | Approach | Best For |
|------|---------|----------|----------|
| **Open WebUI** | MIT | Self-hosted ChatGPT-like interface | Enterprise teams, plugin extensibility |
| **AnythingLLM** | MIT | All-in-one AI desktop/Docker app | Small teams, RAG over documents |
| **Ollama** | MIT | Local LLM runner | Running models locally (Llama, Mistral) |

**Open WebUI** provides a polished web interface for interacting with any LLM (local via Ollama, or cloud via OpenAI/Anthropic APIs). It supports multi-user with role-based access, document RAG, plugins, and custom workflows.

**AnythingLLM** bundles LLM chat + document ingestion + AI agents in a single app. Excellent for small teams wanting RAG over company documents without complex setup.

**Ollama** runs LLMs locally on your hardware. Pair it with Open WebUI for a fully private AI assistant stack.

**Verdict:** Ollama + Open WebUI for the self-hosted AI layer. Use n8n AI nodes for automated AI workflows.

---

### 19. Backup and Disaster Recovery

| Tool | Licence | Strength | Best For |
|------|---------|----------|----------|
| **Restic** | BSD-2 | Cross-platform, S3/B2/SFTP support | Cloud + local backups, simple CLI |
| **BorgBackup** | BSD-3 | Fastest local/SSH backups, best dedup | Local/remote server backups |
| **Borgmatic** | GPL-3.0 | Borg wrapper with YAML config | Automated Borg scheduling |

**Restic** is recommended as the primary backup tool. It supports every major cloud backend (S3, Backblaze B2, Azure, SFTP, REST), has strong encryption, deduplication, and comes as a single static binary. Pair it with **Backrest** for a web UI to browse snapshots.

**BorgBackup** is faster for local/SSH backups with superior deduplication ratios (70-85%), but its cloud support is limited (requires rclone). **Borgmatic** wraps Borg with simple YAML configuration and cron scheduling.

**Strategy:** Restic to Backblaze B2 (or Hetzner Storage Box) for offsite + Borg for local NAS backups. Follow the 3-2-1 rule.

---

### 20. DevOps / CI/CD

| Tool | Licence | Integration | Best For |
|------|---------|------------|----------|
| **Gitea** | MIT | Lightweight GitHub alternative (Go) | Self-hosted Git with actions support |
| **Woodpecker CI** | Apache-2.0 | Native Gitea integration | Lightweight CI/CD pipelines |

**Gitea** is a lightweight, fast, self-hosted Git service that can run on minimal resources (a $5 VPS). It supports pull requests, code review, issue tracking, and now has built-in Actions (GitHub Actions compatible).

**Woodpecker CI** integrates natively with Gitea via OAuth. It runs pipelines in Docker containers defined by simple YAML files. Push code → webhook fires → pipeline runs → deploy. No Jenkins bloat required.

**Verdict:** Gitea + Woodpecker CI is the perfect lightweight DevOps stack.

---

## Suggested Overall Architecture

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
    │  Authentik (SSO)  │  │  n8n (Automation Hub) │  │  User-facing Apps │
    │  Identity Provider│  │  Webhooks + Workflows │  │  Ghost, Nextcloud │
    └──────────┬────────┘  └───────────┬──────────┘  └───────────────────┘
               │                       │
    ┌──────────▼───────────────────────▼──────────────────────────────────┐
    │                     Internal Services Layer                         │
    │  ERPNext │ Plane │ CRM │ Mattermost │ Zammad │ Listmonk │ BookStack│
    └──────────────────────────┬──────────────────────────────────────────┘
                               │
    ┌──────────────────────────▼──────────────────────────────────────────┐
    │                     Data Layer                                      │
    │         PostgreSQL  │  Redis  │  Object Storage (MinIO/S3)          │
    └──────────────────────────┬──────────────────────────────────────────┘
                               │
    ┌──────────────────────────▼──────────────────────────────────────────┐
    │                  Infrastructure Layer                                │
    │  Docker/Compose │ Uptime Kuma │ Grafana │ Restic Backups │ Gitea    │
    └─────────────────────────────────────────────────────────────────────┘
```

**Key architectural principles:**

1. **Traefik** is the single entry point — all HTTP/HTTPS traffic routes through it
2. **Authentik** is the identity backbone — every app authenticates via OIDC/SAML through it
3. **n8n** is the automation hub — it connects all tools via webhooks and APIs
4. **PostgreSQL** is the shared database — most tools use it, simplifying backups
5. **Redis** provides caching and message queuing for tools that need it

---

## Automation Strategy

### Example Workflow: Client Onboarding

```
1. New lead fills form on Ghost website
   → Webhook fires to n8n
2. n8n creates contact in Twenty CRM / EspoCRM
3. n8n creates project in Plane
4. n8n sends welcome email via Listmonk
5. n8n posts notification in Mattermost #sales channel
6. n8n creates initial invoice in ERPNext
```

### Example Workflow: Invoice Generation

```
1. Project milestone completed in Plane
   → n8n webhook trigger
2. n8n pulls billing data from ERPNext
3. n8n generates and sends invoice via ERPNext
4. n8n updates CRM record
5. n8n sends payment link to client via email
6. When payment received → n8n marks invoice as paid → notifies Mattermost
```

### Example Workflow: Support Ticket Escalation

```
1. Customer emails support@company.com
   → Zammad creates ticket
2. If ticket unresolved after SLA threshold
   → Zammad webhook fires to n8n
3. n8n creates task in Plane with high priority
4. n8n sends alert in Mattermost #support channel
5. n8n optionally pages on-call via webhook
```

### Example Workflow: Lead Capture → Deal Close

```
1. Visitor fills contact form on website
   → n8n captures via webhook
2. n8n enriches lead data (optional API call)
3. n8n creates lead in CRM pipeline
4. n8n triggers email drip sequence in Listmonk/Mautic
5. When lead converts → n8n creates project + invoice in ERPNext
6. n8n archives lead and notifies team
```

---

## Deployment Strategy

### Option A: Single VPS (1-10 people) — Recommended Start

**Server:** Hetzner CCX23 (4 dedicated vCPUs, 16GB RAM, 160GB NVMe) — ~€28/month

```yaml
# docker-compose.yml structure (simplified)
services:
  traefik:        # Reverse proxy + SSL
  authentik:      # SSO/Identity
  postgresql:     # Shared database
  redis:          # Caching
  n8n:            # Automation
  erpnext:        # ERP/Accounting
  plane:          # Project management
  bookstack:      # Documentation
  nextcloud:      # File storage
  mattermost:     # Chat
  listmonk:       # Email marketing
  uptime-kuma:    # Monitoring
  gitea:          # Git hosting
  umami:          # Analytics
  ghost:          # Website/CMS
```

This entire stack fits comfortably on 16GB RAM for a small team. Use Docker Compose with a `.env` file for secrets and a shared Docker network.

### Option B: Small Homelab (Proxmox + Docker)

Run Proxmox on a dedicated mini-PC or NAS:
- **LXC Container 1:** Core stack (Traefik, Authentik, PostgreSQL, Redis, n8n)
- **LXC Container 2:** Business apps (ERPNext, CRM, Plane, Zammad)
- **LXC Container 3:** Collaboration (Nextcloud, Mattermost, BookStack)
- **LXC Container 4:** Public-facing (Ghost, Umami, Listmonk)

### Option C: Kubernetes (15-50 people)

When scaling beyond ~15 people, consider migrating to K3s (lightweight Kubernetes):
- Helm charts available for most tools
- Horizontal scaling per service
- Proper resource limits and auto-restart
- Traefik runs natively as K3s ingress controller

### Network Architecture

```
Internet → Cloudflare (DNS + DDoS) → VPS/Homelab
  → Traefik :443 → service.company.com
  → Authentik handles SSO for all services
  → Tailscale/WireGuard for admin access (no SSH exposed)
```

---

## Cost Analysis

### Monthly Cost: Self-Hosted (1-2 people)

| Item | Provider | Cost/Month |
|------|----------|-----------|
| VPS (4 vCPU, 16GB RAM) | Hetzner CCX23 | €28 |
| Backup storage (100GB) | Hetzner Storage Box | €3.50 |
| Domain name | Annual (~€12/yr) | €1 |
| SMTP relay (10k emails) | Amazon SES | €1 |
| Object storage (50GB) | Hetzner / Backblaze B2 | €0.50 |
| **Total** | | **~€34/month** |

### Monthly Cost: Self-Hosted (10-20 people)

| Item | Provider | Cost/Month |
|------|----------|-----------|
| VPS (8 vCPU, 32GB RAM) | Hetzner CCX33 | €49 |
| Second VPS (failover) | Hetzner CX23 | €6.50 |
| Backup storage (500GB) | Hetzner Storage Box | €10 |
| Domain + DNS | Cloudflare | €1 |
| SMTP relay (50k emails) | Amazon SES | €5 |
| Object storage (200GB) | Backblaze B2 | €1 |
| **Total** | | **~€73/month** |

### Monthly Cost: Self-Hosted (50 people)

| Item | Provider | Cost/Month |
|------|----------|-----------|
| 3x VPS (K3s cluster) | Hetzner CCX33 × 3 | €147 |
| Load balancer | Hetzner LB | €6 |
| Managed PostgreSQL | Hetzner or self-managed | €0-30 |
| Backup storage (1TB) | Hetzner + B2 | €15 |
| SMTP relay (200k emails) | Amazon SES | €20 |
| Object storage (1TB) | Backblaze B2 | €5 |
| **Total** | | **~€195-225/month** |

### Comparison: SaaS Equivalent for 50 People

| SaaS Tool | Approximate Monthly Cost |
|-----------|------------------------|
| Salesforce CRM | €1,250+ |
| Jira + Confluence | €500+ |
| Slack Business+ | €625+ |
| Google Workspace | €600+ |
| HubSpot Marketing | €800+ |
| Zendesk | €500+ |
| **Total SaaS** | **€4,000-8,000+/month** |

Self-hosting saves **~95%** at the 50-person scale.

---

## Scaling Considerations

### 1-2 People → 10 People

| What Changes | Action Required |
|-------------|----------------|
| Auth becomes critical | Ensure Authentik SSO is configured for all apps |
| File storage grows | Add external volume or NAS mount to Nextcloud |
| Database load increases | Tune PostgreSQL (shared_buffers, work_mem) |
| Chat becomes noisy | Set up proper Mattermost channels/teams |
| Backup window grows | Schedule backups during off-hours, increase storage |

### 10 People → 50 People

| What Changes | Action Required |
|-------------|----------------|
| Single VPS hits limits | Migrate to K3s cluster or split services across VPSes |
| PostgreSQL needs HA | Consider PgBouncer for connection pooling, read replicas |
| ERPNext gets heavy | Dedicated server or container with more RAM |
| Monitoring is essential | Deploy full Grafana + Prometheus + Loki stack |
| Nextcloud needs scaling | Separate PHP workers, add Redis caching, external storage |
| Search performance | Elasticsearch/Meilisearch for Zammad, BookStack |
| Email volume | Dedicated SMTP or move to higher SES tier |
| CI/CD pipelines | Add Woodpecker agents on separate machines |

---

## Minimal Stack (5-7 Tools)

For a solo founder or 2-person team who needs to cover the essentials:

| # | Domain | Tool | Why |
|---|--------|------|-----|
| 1 | ERP + CRM + Invoicing | **ERPNext** | Covers accounting, CRM, invoicing, HR, projects |
| 2 | Automation | **n8n** | Connects everything, handles workflows |
| 3 | File Storage + Collab | **Nextcloud** | Files, calendar, contacts, document editing |
| 4 | Documentation | **BookStack** | Internal wiki and knowledge base |
| 5 | Communication | **Mattermost** | Team chat (or just use email at this scale) |
| 6 | Website | **Ghost** | Company website + blog + newsletter |
| 7 | Reverse Proxy | **Traefik** | Routes traffic, auto-SSL |

**Total RAM needed:** ~8-10GB — fits on a Hetzner CX32 (~€18/month).

This covers: CRM, invoicing, accounting, project management, file sharing, documentation, internal chat, website, and newsletter — for under €20/month.

---

## Advanced Stack (20+ Tools)

| # | Domain | Tool(s) |
|---|--------|---------|
| 1 | Reverse Proxy / API Gateway | **Traefik** |
| 2 | Identity / SSO | **Authentik** |
| 3 | Automation | **n8n** |
| 4 | ERP / Accounting | **ERPNext** |
| 5 | CRM | **Twenty CRM** or **EspoCRM** |
| 6 | Project Management | **Plane** |
| 7 | Documentation | **BookStack** |
| 8 | File Storage | **Nextcloud** |
| 9 | Internal Chat | **Mattermost** |
| 10 | Email Marketing | **Listmonk** |
| 11 | Marketing Automation | **Mautic** |
| 12 | Support / Ticketing | **Zammad** |
| 13 | Website / CMS | **Ghost** |
| 14 | Analytics | **Umami** |
| 15 | Low-Code / Internal Tools | **NocoDB** + **Appsmith** |
| 16 | Monitoring (uptime) | **Uptime Kuma** |
| 17 | Monitoring (infra) | **Grafana + Prometheus** |
| 18 | AI Assistant | **Open WebUI + Ollama** |
| 19 | Git Hosting | **Gitea** |
| 20 | CI/CD | **Woodpecker CI** |
| 21 | Backup | **Restic** + **Borgmatic** |
| 22 | Database | **PostgreSQL** + **Redis** |

---

## Tools to Avoid

| Tool | Why Avoid |
|------|----------|
| **SuiteCRM** | Outdated codebase and UI, steep learning curve, heavy server requirements. Fork of SugarCRM with lots of legacy baggage. |
| **Odoo Community Edition** | Misleadingly "free" — one app limit makes it near-useless without Enterprise licence. Creates lock-in. |
| **Wekan** | Kanban-only, limited features, poor scaling, minimal integration options. Plane/Taiga are strictly better. |
| **Jenkins** | Massively over-engineered for small teams. Plugin hell, Java memory hog, terrible UX. Use Woodpecker or Gitea Actions. |
| **GitLab (self-hosted)** | Requires 4-8GB RAM just to run. Extremely heavy for small teams. Use Gitea instead. |
| **Discourse** | Great forum software, but overkill if you only need internal comms. Uses 2GB+ RAM. |
| **Keycloak** (at this scale) | Too heavy and complex for <50 people. Authentik covers the same protocols with far less overhead. |
| **Directus** | Excellent headless CMS, but not a good fit as an all-purpose low-code tool. Better alternatives exist for each specific use case. |
| **Redmine** | Ancient UI, minimal modern integrations, Ruby stack is hard to maintain. |
| **MediaWiki** | Built for Wikipedia, not for company knowledge bases. Complex, ugly, hard to customise. |
| **Duplicati** | Unreliable at scale, known for database corruption issues. Use Restic or Borg instead. |

---

## Final Recommendation: Two Approaches

### Approach A: Lightweight Modular Stack (Recommended)
Pick the best tool for each domain and connect them via n8n + Authentik + Traefik. Maximum flexibility, easy to swap individual tools, each tool does one thing well.

### Approach B: ERP-Centric Monolith
Use ERPNext/Frappe as the core and extend with Frappe apps (Frappe HR, Frappe CRM, Frappe Helpdesk, Frappe Wiki). Fewer tools to manage, but deeper vendor lock-in to the Frappe ecosystem, and individual modules are less polished than dedicated tools.

**For most small companies scaling to 50:** Approach A is superior. You get the best tool in each category, loose coupling, and the freedom to replace any component without rebuilding everything.
