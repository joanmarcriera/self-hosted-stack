**Complete Self-Hosted Software Tool Stack for a 1–2 Person Startup Scaling to ~50 People**

This stack is built exclusively around **free, open-source, self-hosted tools** that run on a single Linux server (or small cluster) via Docker. It emphasizes **automation-first design** with n8n/ActivePieces as the central glue, a unified identity provider for SSO, and API/webhook integration everywhere. Paid tools are avoided except for truly negligible extras (e.g., a €5–10/mo VPS or cheap SMTP relay if email deliverability becomes an issue).

The design covers **all 20 requested domains** and most day-to-day operations (sales, support, finance, projects, knowledge, comms, marketing, analytics, backups, internal tools, AI agents, DevOps for your own code if needed).

### Two Main Architectural Approaches
**Option A: ERP-Centric (Heavier, highly integrated – recommended for scaling to 50)**  
One powerful core (ERPNext) handles ERP + CRM + accounting + invoicing + sales pipeline + projects + HR. Everything else plugs in via APIs.  
**Pros**: Minimal integration work, single source of truth for business data, excellent for manufacturing/services/retail.  
**Cons**: Steeper initial learning curve; heavier resource use (~4–8 GB RAM at start).  
**Best for**: Companies that want “one system to rule them all” and plan to grow fast.

**Option B: Modular Lightweight (Best for 1–2 people, maximum flexibility)**  
Nextcloud as file/collaboration hub + Dolibarr (or EspoCRM) for light CRM/ERP + n8n for orchestration.  
**Pros**: Extremely lightweight, easy to start, swap any component later.  
**Cons**: More initial wiring via n8n.  
**Best for**: Freelancers, consultants, or teams that value simplicity and want to avoid “ERP bloat” early on.

You can start with **Option B** and migrate the core to ERPNext later (both export/import data easily).

### Per-Domain Recommendations
All tools below are **100 % open-source** and **self-hostable** (official Docker images or easy Docker Compose). I list 1–3 options per domain with open-source status, short description, pros/cons, and fit for 1–50 people.

**1. Automation / Workflow Orchestration**  
- **Primary: n8n** (source-available / fair-code, fully free self-hosted) – Visual no/low-code workflow automation (Zapier alternative).  
  **Pros**: 400+ native nodes + HTTP/JS/Python, AI nodes, scaling worker mode, webhooks everywhere.  
  **Cons**: Some enterprise nodes behind paid cloud (irrelevant for self-host).  
  **Fit**: Runs on 1 GB RAM; scales to thousands of executions/day on a small VPS. Glue for the entire stack.  
- **Alternative: ActivePieces** (MIT, 100 % OSS) – Simpler Zapier-like UI with AI agents built-in.  
  **Why choose**: Easier for non-technical founders; growing faster in 2026.

**2. CRM / Customer Management + 9. Sales Pipeline**  
- **Primary (in ERP-centric)**: ERPNext built-in CRM + Sales module.  
- **Primary (modular)**: Twenty or EspoCRM (both AGPL-3.0, PHP/TS, Docker). Modern, beautiful, pipeline + contacts + deals.  
  **Pros**: Clean UI, REST API, custom fields, email integration.  
  **Cons**: Twenty is newer (fast-moving).  
  **Fit**: Handles 50 users + thousands of contacts easily; n8n syncs pipeline to projects/invoices.

**3. ERP / Accounting / Invoicing**  
- **Primary: ERPNext** (GPL-3.0, Python/JS + MariaDB/Postgres, Docker) – Full ERP (accounting, inventory, manufacturing, multi-currency invoicing, POS).  
  **Pros**: 100 % free forever, double-entry accounting, automatic invoice → payment reconciliation, API-first.  
  **Cons**: Requires MariaDB tuning for very high volume.  
  **Fit**: Designed exactly for small businesses scaling to medium; used by 15 000+ companies.  
- **Light alternative: Dolibarr** (GPL-3.0, PHP) – Modular ERP/CRM for very small teams.  
- **Secondary: Odoo Community** (LGPL-3.0) – If you love its app marketplace (but beware enterprise upsell pressure).

**4. Project Management / Task Management**  
- **Primary: Plane** (open-core, self-host free) – Modern Jira alternative (issues, cycles, roadmaps, real-time).  
  **Pros**: Beautiful UI, GitHub/GitLab sync, excellent mobile.  
  **Cons**: Still maturing compared to OpenProject.  
- **Alternative: OpenProject** (GPL-3.0) – Mature Gantt, agile boards, time tracking.  
- **Light: Nextcloud Deck** or **Vikunja** (for simple Kanban).

**5. Documentation / Knowledge Base**  
- **Primary: BookStack** (MIT, PHP/MySQL) – Books/shelves/pages structure, beautiful WYSIWYG + Markdown.  
  **Pros**: Extremely intuitive, permissions per shelf, export to PDF.  
  **Cons**: Less “wiki-link” heavy than Wiki.js.  
- **Alternative: Wiki.js** (AGPL-3.0, Node.js) – Modern, multi-DB, Git sync.  
**Fit**: Both handle 50 users with almost zero resources.

**6. File Storage and Collaboration**  
- **Primary: Nextcloud** (AGPL-3.0, PHP) – Full Dropbox/Office 365 replacement + calendar, contacts, Deck tasks, OnlyOffice/Collabora integration.  
  **Pros**: End-to-end encryption option, huge app ecosystem, Talk (chat/video).  
  **Cons**: Can be chatty on resources if you enable many apps.  
**Fit**: Scales to 50 users on a single server with proper Redis + object storage backend.

**7. Internal Communication (Chat, Video)**  
- **Primary: Mattermost** (Apache 2.0 / source-available, Docker) – Slack clone with threads, channels, plugins, Playbooks.  
  **Pros**: Excellent compliance, GitLab integration, self-hosted calls.  
- **Alternative: Rocket.Chat** (MIT) – Omni-channel (WhatsApp, SMS, web widget).  
- **Video: Jitsi Meet** (Apache 2.0) – Unlimited video rooms.  
**Fit**: Mattermost handles 50 concurrent users comfortably.

**8. Email and Marketing Automation**  
- **Full email server: Mailcow** (GPL-3.0, Docker) – Postfix + Dovecot + webmail + SOGo calendar.  
- **Marketing: Mautic** (GPL-3.0) – Campaigns, lead scoring, landing pages, n8n integration.  
- **Newsletters: Listmonk** or **Keila** (both AGPL-3.0, Go, tiny).  
**Note**: For best deliverability, use a cheap external SMTP relay (€5/mo) with your own domain; Mailcow for receiving.

**10. Support / Ticketing**  
- **Primary: Zammad** (AGPL-3.0, Ruby) – Beautiful ticketing with email, chat, phone, knowledge base.  
  **Pros**: n8n/Zapier-like automations inside, SLA, reporting.  
**Fit**: Perfect bridge between Mattermost and CRM.

**11. Data Storage / Database**  
- **Primary: PostgreSQL** (with pgAdmin or Adminer).  
- **No-code DB: Baserow** (Airtable self-hosted alternative).  
All apps use their own DB or share Postgres.

**12. API Layer / Integration Layer**  
- n8n + **Hasura** or **PostgREST** (instant GraphQL/REST on Postgres).  
- Reverse proxy: Traefik or Caddy.

**13. Low-code / Internal Tools**  
- **Primary: Appsmith** or **ToolJet** (both Apache 2.0 / GPL, Docker) – Build internal dashboards, CRUD apps, admin panels connected to your DBs and APIs.  
**Fit**: Non-devs can build “add client” forms that trigger n8n flows.

**14. Monitoring / Observability**  
- **Primary: Prometheus + Grafana + Loki** (all OSS) – Metrics, logs, dashboards, alerts to Mattermost.  
- **Simple alternative: Netdata** (real-time, zero-config).  
**Fit**: Tiny footprint; alerts on high CPU or failed n8n jobs.

**15. Authentication / Identity Management**  
- **Primary: Authentik** (AGPL-3.0, Python) – Modern SSO, MFA, social login, LDAP, OIDC/SAML for every tool.  
  **Why better than Keycloak in 2026**: Much lighter, beautiful UI, built-in proxy.  
- **Enterprise alternative: Keycloak** (if you need extreme federation).

**16. Website / CMS**  
- **Primary: Strapi** (MIT, Node.js, headless) – Modern API-first CMS.  
- **Alternative: WordPress** (with proper security hardening) or **Payload CMS**.

**17. Analytics / Dashboards**  
- **Primary: Matomo** (GPL-3.0) – Google Analytics alternative.  
- **Product analytics: PostHog** or **Metabase** (on your DBs).

**18. AI Assistants / Automation Agents**  
- **Ollama** + **Open-WebUI** (MIT) – Run Llama 3 / Mistral / DeepSeek locally.  
- Integrate into n8n (AI nodes) and Appsmith for auto-summaries, email replies, invoice categorization, RAG over your knowledge base.  
**Fit**: Runs on the same server (GPU optional); zero cost, private.

**19. Backup and Disaster Recovery**  
- **Primary: Restic** (or BorgBackup) + automated scripts to Backblaze B2 or Hetzner Storage Box.  
- Nextcloud built-in versioning + ERPNext database dumps.  
- Tool: **Duplicati** or **Borgmatic** for scheduling.

**20. DevOps / CI/CD (if you ship code)**  
- **Gitea/Forgejo** (Git) + **Woodpecker CI** (lightweight) or **Drone**.  
Everything else (monitoring, backups) is already covered.

### 1. Suggested Overall Architecture
- **Identity Provider**: Authentik (central SSO/OIDC for every single tool).  
- **Automation Hub**: n8n (listens to webhooks from CRM/ERP/Nextcloud/Zammad/Mattermost and triggers actions).  
- **Shared Event Bus**: n8n internal + Redis (for high-volume).  
- **API Gateway**: Traefik (auto-SSL, routing, basic auth fallback).  
- **File & Object Storage**: Nextcloud (with S3-compatible backend for scale).  
- **Databases**: One central Postgres + per-app DBs.  
- **Monitoring Layer**: Prometheus/Grafana scraping everything.  
- **Backup Layer**: Restic nightly → offsite.  

All services run in isolated Docker containers behind Traefik. One `docker-compose.yml` (or Coolify) manages everything.

### 2. Automation Strategy (Examples)
- **Lead capture** → form (Strapi/Appsmith) → n8n → create contact in ERPNext/Twenty → create project in Plane → welcome email (Mautic) → Mattermost notification + Nextcloud folder.  
- **New invoice paid** (ERPNext webhook) → n8n → mark ticket closed in Zammad → thank-you email → update analytics.  
- **Support ticket** → Zammad → n8n → create task in Plane + @mention in Mattermost + AI summary via Ollama.  
- **Onboarding new employee** → Appsmith form → Authentik user + Mattermost account + Nextcloud home folder + welcome tasks in Plane.  

n8n workflows are version-controlled in Git and can be triggered by schedules, webhooks, email, or AI agents.

### 3. Deployment Strategy
- **Single VPS** (recommended start): Hetzner CX51 or similar (8 GB RAM, 4 vCPU, 160 GB NVMe) – €20–35/mo.  
- **Homelab**: Proxmox LXC + Docker or bare-metal.  
- **Cloud**: Any provider (Linode, OVH, DigitalOcean).  
- **Management layer**: **Coolify** (self-hosted PaaS – one-click deploy from Git, SSL, backups, resource monitoring) or CapRover/Portainer.  
- **Orchestration**: Single `docker-compose.yml` with Traefik + Authentik + all services. For production: add Redis, separate DB container, and optional object storage.  
- **Kubernetes** (at ~30+ users): Use official Helm charts or K3s on 2–3 nodes.

All tools have official Docker images and compose examples.

### 4. Cost Analysis (Monthly, Self-Hosted)
- VPS/server: €15–40 (8–16 GB RAM sufficient until ~30 users).  
- Storage (100–500 GB + backups): €5–10.  
- Domain + cheap SMTP relay (optional): €5.  
- **Total**: €25–60/month even at 50 users (no per-user fees ever).  
Compare to SaaS equivalent (Salesforce + Slack + QuickBooks + Zapier + Notion): easily $800–2000+/month.

### 5. Scaling Considerations
- **1–2 people**: Everything on one 4 GB VPS. You use 80 % of features yourself.  
- **10 people**: Add Redis caching + more RAM (8 GB). n8n workers can scale horizontally. Nextcloud/ERPNext still fine.  
- **50 people**:  
  - Possible bottlenecks: Nextcloud file sync, ERPNext database, Mattermost concurrent connections.  
  - Fixes: Move DB to separate container/instance, use S3 backend for Nextcloud, enable n8n scaling mode, add second VPS for workers or go K3s.  
  - Authentik, Zammad, Plane, BookStack all scale linearly with almost no extra work.  
  - Monitoring becomes critical – Grafana alerts save you.  
  No tool in this stack has hard user limits or forces you to paid plans.

### 6. Minimal Stack (5–7 Tools – Covers 90 % of Needs for 1–10 People)
1. **ERPNext** (ERP + CRM + accounting + projects + sales)  
2. **Nextcloud** (files + calendar + basic tasks + Talk)  
3. **n8n** (automation glue)  
4. **Mattermost** (chat + video)  
5. **Authentik** (SSO)  
6. **BookStack** (knowledge base)  
7. **Zammad** (support) + **Matomo** (analytics)  

Deploy with Coolify in <2 hours. Total cost ~€25/mo.

### 7. Advanced / Complete Stack (15–25 Tools – Full Automation & Observability)
Add:  
- Plane or OpenProject  
- Appsmith/ToolJet  
- Mautic + Listmonk  
- Strapi (website)  
- Prometheus/Grafana + Netdata  
- Ollama + Open-WebUI (AI agents)  
- Restic backups  
- Forgejo + Woodpecker (if coding)  
- Hasura/PostgREST  
- Baserow (no-code DB)  
- Jitsi (extra video)  

Still runs on 1–2 servers with Coolify.

### 8. Tools to Avoid (Even If They Look Attractive)
- **Odoo full reliance** – Community edition is good, but many useful modules push you to expensive Enterprise.  
- **SuiteCRM** – Dated UI and heavy maintenance.  
- **Full self-hosted email without experience** (Mailcow works but spam blacklisting is painful; use external relay).  
- **Zabbix** – Overkill and complex for <100 users (use Prometheus/Netdata).  
- **Keycloak** (unless you need Java enterprise features) – Authentik is far easier in 2026.  
- **Anything with per-user licensing in “enterprise” edition** that locks core features (some tools do this subtly).  
- **Huge all-in-one suites** like ADempiere or Tryton unless you have dedicated IT.

This stack gives you **enterprise-grade capabilities at near-zero cost**, total data ownership, and automation that actually saves time instead of creating more work. Start with the minimal stack + Coolify on a €20 VPS – you’ll have a production-ready company backbone in one weekend.

If you want the full `docker-compose.yml` template, Coolify project blueprint, or n8n workflow examples for common automations (onboarding, invoicing, support escalation), just ask and I’ll provide them. This exact combination is running successfully for many small teams in 2026.