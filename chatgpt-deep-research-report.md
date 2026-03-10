# Open‑source, self‑hosted tool stack for a 1–2 person company scaling to ~50 people

## Design assumptions and selection criteria

This stack is designed around a few practical realities of running company operations on self‑hosted software:

A small company needs **one “identity centre”**, **one “automation hub”**, and **a small number of “systems of record”** (where the truth lives for customers, invoices, projects, files, and support). Everything else is an interface, a workflow, or a reporting layer. Identity via OIDC/SAML is foundational for this: tools like Keycloak use open standards like **OpenID Connect** and **SAML 2.0** and are designed to secure applications as a dedicated authentication server. citeturn34search12turn34search4

Self‑hosting for 1–2 people works best when you keep the **operational surface area** small: fewer databases, fewer message brokers, fewer bespoke integrations, and strong defaults like containerised deployment (Docker Compose) for “single‑box” mode. Docker Compose is explicitly designed to define and run **multi‑container applications** from a Compose file, which maps well to small‑company deployments. citeturn33search2turn33search6

Scaling to ~50 people typically breaks in predictable places: (a) identity and permissions, (b) file collaboration performance, (c) email deliverability (if self‑hosted), (d) reporting governance, and (e) backups/restore confidence. The tool choices below prioritise:
- **OSI‑approved open‑source licenses** where possible (MIT/Apache/GPL/AGPL/MPL/PostgreSQL License), with clear flags whenever a tool is “source‑available” rather than open source.
- **Self‑hostability** on a **single server** or small cluster.
- **Integration friendliness** (webhooks, APIs, database accessibility, plugins).
- **Automation‑first** (workflow orchestration + eventing patterns).
- **Low licensing cost**, with paid options treated as optional upgrades rather than hidden requirements.

## Domain recommendations

The tables below give you 1–3 recommended tools per domain, including what they do, pros/cons, and why they fit both “solo founder mode” and “up to ~50 people” mode.

### Business operations and collaboration

| Domain | Recommended tools (status) | What it does | Pros | Cons | Why it scales from 1–2 → ~50 |
|---|---|---|---|---|---|
| CRM / customer management | entity["organization","SuiteCRM","open-source crm"] (open source; self‑host) citeturn2search16turn2search19; entity["organization","EspoCRM","open-source crm"] (open source; self‑host; AGPLv3) citeturn2search20; ERPNext (open source; self‑host; CRM module) citeturn34search10turn34search6 | Tracks accounts/contacts/leads, activities, and customer history | Mature CRM workflows; self‑host control; extensible | Admin/config overhead; CRM adoption requires discipline | For 1–2: simple pipeline + notes. For 50: roles, auditability, and segmentation. EspoCRM’s license is explicitly AGPLv3 now, which is suitable for self‑hosting but important for compliance. citeturn2search20 |
| Sales pipeline | SuiteCRM (pipeline/opportunities); EspoCRM (sales pipeline); ERPNext (CRM + quotations) citeturn2search16turn2search20turn34search10 | Opportunity stages, forecasts, quotes → orders | Keeps revenue process visible; integrates with invoicing/ERP if ERPNext is used | Forecast accuracy depends on usage; may need custom fields | Same underlying data model scales well. The key is enforcing “stage gate” workflow and automations (see automation section). |
| ERP / accounting / invoicing | entity["organization","ERPNext","open-source erp"] (GPLv3; self‑host) citeturn34search6turn3search6; entity["organization","Dolibarr","open-source erp crm"] (open source; self‑host) citeturn3search3turn3search14; Akaunting (open source; self‑host, but watch add‑on model) citeturn2search15 | Invoicing, accounting ledgers, customers/suppliers, sometimes inventory/projects | ERPNext has documented accounting features like general ledger/journal entry flows citeturn3search6turn3search2; Dolibarr supports invoicing and “double entry accounting” features citeturn3search18turn3search14 | ERPNext is heavier operationally; Dolibarr UI can feel dated; Akaunting ecosystem sometimes pushes paid add‑ons (community reports) citeturn2search15 | ERPNext is “suite‑like”, so you can start small then turn on modules. Its licensing is clearly GPLv3. citeturn34search6turn34search10 Dolibarr is modular and often easier for very small teams. citeturn3search10 |
| Project / task management | entity["organization","OpenProject","open-source project mgmt"] (GPLv3; self‑host) citeturn4search20turn4search11; entity["organization","Plane","open-source project mgmt"] (AGPLv3; self‑host) citeturn4search6turn4search9; entity["organization","Redmine","open-source project mgmt"] (GPLv2) citeturn4search3 | Projects, backlogs/boards, timelines, issues | OpenProject supports classic/agile workflows and is explicitly GPLv3 citeturn4search20; Plane is modern and publishes self‑host sizing guidance (Docker/K8s) citeturn4search9turn4search6 | OpenProject can be “process heavy” if misconfigured; Redmine UI looks older; Plane is newer (watch upgrade cadence) | For 1–2: one board. For 50: permissions, templates, portfolio views, and API automation. Plane’s published minimum/recommended resources help plan scaling. citeturn4search9 |
| Documentation / knowledge base | entity["organization","BookStack","open-source wiki"] (MIT; self‑host) citeturn5search8turn5search0; entity["organization","Wiki.js","open-source wiki"] (AGPLv3; self‑host) citeturn5search1; entity["organization","Docusaurus","static docs generator"] (MIT; generate and host anywhere) citeturn5search6turn5search2 | Internal wiki / SOPs / runbooks; optionally docs‑as‑code | BookStack is explicitly MIT licensed citeturn5search8; Wiki.js is explicitly AGPLv3 citeturn5search1; Docusaurus is MIT licensed citeturn5search6 | Wiki sprawl without governance; search quality varies; docs‑as‑code requires Git habits | Small teams get immediate value (1 source of truth). At ~50, permissioning + review/approval workflows matter; choose one tool and enforce ownership per area. |
| File storage and collaboration | entity["company","Nextcloud","self-hosted collaboration"] (AGPL; self‑host) citeturn0search16turn6search14; entity["organization","Seafile","self-hosted file sync"] (open source CE; self‑host) citeturn6search0turn6search8; ONLYOFFICE Docs (AGPLv3; self‑host) citeturn7search0turn7search9 | Dropbox/Drive replacement; shared folders; optional online editing | Nextcloud + office stack enables collaborative editing; Nextcloud Office positioning is explicitly about collaborative editing with broad format support citeturn6search14; ONLYOFFICE Docs CE is AGPLv3 citeturn7search0turn7search9 | Nextcloud can be heavy on CPU/IO; online office editing adds memory/CPU load; Seafile has “Pro” feature separation (plan carefully) | For 1–2: one shared workspace. For 50: storage performance and permissions are critical; plan object storage and/or externalised DB early if Nextcloud becomes central. |
| Internal communication (chat + video) | entity["organization","Matrix","open protocol messaging"] server (self‑host; pick homeserver carefully) citeturn8search4turn8search12 + Element clients citeturn8search1turn8search13; entity["company","Mattermost","self-hosted team chat"] Team Edition (MIT; self‑host) citeturn8search6turn8search2; entity["organization","Jitsi","video conferencing"] (open source; self‑host) citeturn8search11turn8search19 | Chat, channels, calls; video meetings | Mattermost Team Edition is MIT and described as a free self‑hosted collaboration platform (with explicit constraints) citeturn8search6; Jitsi is positioned as open source and self‑hostable citeturn8search19turn8search11 | Matrix ecosystem has moving parts; Synapse licensing changed (AGPL move) and there are multiple homeserver options citeturn8search12turn8search4; Mattermost Team has SSO limitations stated in its docs citeturn8search6 | For 1–2: keep it simple (Mattermost or a small Matrix homeserver). For 50: federation/security policies/retention become real; choose a stable homeserver and integrate SSO. |
| Email and marketing automation | entity["organization","Mautic","open-source marketing automation"] (GPLv3; self‑host) citeturn9search4turn9search0; entity["organization","listmonk","newsletter manager"] (AGPL; self‑host) citeturn9search5turn9search1; Mailu or mailcow for mail server (open source; self‑host) citeturn9search2turn9search15 | Newsletters, campaigns, segmentation, email workflows; optionally run your own SMTP/IMAP | Mautic is explicitly GPLv3 and positioned as self‑hostable citeturn9search4turn9search0; listmonk is AGPL and uses PostgreSQL citeturn9search5; Mailu is explicitly positioned as free software and Docker‑based citeturn9search2 | Self‑hosting email deliverability is hard; you may still need an SMTP relay; Mautic can be heavy vs listmonk | For 1–2: listmonk + a cheap relay. For 50: Mautic’s richer automation pays off, but you must invest in deliverability practices (SPF/DKIM/DMARC, reputation). |
| Support / ticketing | entity["organization","Zammad","open-source helpdesk"] (open source; self‑host) citeturn10search4turn10search0; entity["organization","FreeScout","self-hosted help desk"] (open source; self‑host) citeturn10search1turn10search5; entity["organization","Chatwoot","open-source customer support"] (MIT Community edition; self‑host) citeturn10search17turn10search3 | Email ticketing/shared inbox, SLAs, help centre/live chat (depending on tool) | Zammad is explicitly open source and self‑hostable citeturn10search4turn10search0; Chatwoot Community edition is MIT licensed citeturn10search17 | Many support stacks sprawl into “mini‑CRMs”; integrations matter | For 1–2: FreeScout is lightweight. For 50: Zammad’s workflow depth and Chatwoot omnichannel capability become more valuable. |
| Website / CMS | entity["organization","WordPress","cms"] (GPL; self‑host) citeturn18search13; entity["organization","Ghost","open-source publishing platform"] (MIT; self‑host) citeturn18search14turn18search6; entity["organization","Strapi","open-source headless cms"] (MIT; self‑host) citeturn18search15turn18search7 | Public website, blog, docs/marketing pages; optionally headless CMS | Strapi Community is presented as open source (MIT) citeturn18search15turn18search7; Ghost is MIT licensed per reference sources citeturn18search14 | Plugin security and patching burden; headless CMS adds backend complexity | For 1–2: simplest CMS that matches your site. For 50: role separation (editors vs admins), staging environments, and security patch cadence become requirements. |

### Platform, integration, and operations

| Domain | Recommended tools (status) | What it does | Pros | Cons | Why it scales from 1–2 → ~50 |
|---|---|---|---|---|---|
| Automation / workflow orchestration | entity["organization","Node-RED","flow automation"] (Apache; self‑host) citeturn1search0; entity["organization","Kestra","workflow orchestration"] (Apache 2.0; self‑host) citeturn24search9turn24search6; entity["organization","Temporal","workflow engine"] (MIT; self‑host) citeturn1search2 | Cross‑tool workflows, scheduled tasks, event‑driven processes | Node‑RED is approachable for non‑engineers; Kestra is explicitly positioned as open source and exportable (avoid lock‑in) citeturn24search9; Temporal provides durable workflow guarantees (useful if you build your own product workflows) citeturn1search2 | Node‑RED can become “spaghetti flows”; Temporal requires engineering discipline; Kestra adds another service to operate | For 1–2: Node‑RED is fastest to value. For 10–50: move critical processes into versioned workflows (Kestra YAML and/or Temporal code). |
| Data storage / database | entity["organization","PostgreSQL","open-source database"] (PostgreSQL License) citeturn22search0; entity["organization","MariaDB","open-source database"] (GPLv2) citeturn22search1turn22search9; entity["organization","Valkey","open-source key value store"] (BSD 3‑clause) citeturn20search7turn20search19 | Relational DBs + cache/queue-ish KV store | PostgreSQL explicitly uses a liberal OSI‑style license citeturn22search0; MariaDB Foundation states GPLv2 and “guaranteed to remain open source” citeturn22search1; Valkey is positioned as BSD‑licensed and Linux Foundation backed citeturn20search19turn20search7 | Data migrations and backups require care; MariaDB vs Postgres mismatch across apps | For 1–2: single Postgres + MariaDB. For 50: consider managed HA Postgres or at least replication; isolate “mission critical” DB storage onto dedicated volumes. |
| API layer / integration layer | entity["organization","Kong Gateway","api gateway"] (Apache 2.0) citeturn15search1; entity["organization","KrakenD","api gateway"] CE (Apache 2.0) citeturn15search2turn15search5; entity["organization","PostgREST","postgres to rest api"] (MIT) citeturn24search0turn24search4 | Central routing/auth/rate‑limits; expose internal APIs; simplify integrations | Kong is Apache‑licensed citeturn15search1; KrakenD CE is Apache‑licensed citeturn15search2; PostgREST turns Postgres into REST endpoints based on DB permissions citeturn24search4 | Adds a gateway layer to operate; API design still matters | For 1–2: skip gateway until needed; start with direct service URLs behind SSO. For 50: gateway becomes useful for governance, rate limits, consistent auth, and internal developer experience. |
| Low‑code / internal tools | entity["organization","Appsmith","open-source internal tools"] (Apache 2.0) citeturn16search0turn16search4; entity["organization","Budibase","open-source low-code"] (GPLv3 overall) citeturn16search10turn17search3; ToolJet (AGPL, but “open core” feel—check feature gating) citeturn17search1turn17search10 | Build admin panels, ops consoles, internal workflows quickly | Appsmith emphasises an Apache 2.0 open‑source edition citeturn16search0; Budibase explicitly explains licensing and that apps you build aren’t packaged with GPL code citeturn17search3 | Low‑code sprawl; access control and secrets management must be handled carefully | For 1–2: internal console replaces “spreadsheet ops”. For 50: role‑based access, audit trails, and staging environments matter; Appsmith/Budibase support team workflows. |
| Monitoring / observability | entity["organization","Prometheus","metrics monitoring"] (Apache 2.0) citeturn11search12; entity["company","Grafana","dashboards"] (AGPLv3) citeturn11search0turn11search6; entity["organization","OpenTelemetry","observability framework"] (open source) citeturn11search1 plus entity["organization","Jaeger","distributed tracing"] (Apache 2.0) citeturn12search18turn12search10 | Metrics, dashboards, tracing; alerting | Prometheus is “100% open source” under Apache 2.0 citeturn11search12; Grafana’s licensing moved to AGPLv3 for core projects citeturn11search0; OpenTelemetry provides APIs/collectors for traces/metrics citeturn11search1; Jaeger is Apache licensed citeturn12search18 | Observability isn’t free: you must instrument apps and manage retention | For 1–2: minimal Prometheus + Grafana, basic alerts. For 50: OpenTelemetry + tracing becomes material for incident response and release confidence. |
| Authentication / identity management | entity["organization","Keycloak","openid connect saml server"] (open source; self‑host) citeturn34search12turn34search8; entity["organization","authentik","open-source idp"] (open source; self‑host) citeturn34search16turn34search5; entity["organization","Authelia","open-source access gateway"] (Apache 2.0; self‑host) citeturn20search5turn20search1 | SSO (OIDC/SAML), MFA, user lifecycle; reverse‑proxy authentication | Keycloak uses OIDC/SAML and is intended as a dedicated auth server citeturn34search12turn34search4; authentik supports common providers like OIDC/SAML/LDAP citeturn34search5turn34search16; Authelia is Apache 2.0 and positioned as an IAM companion for reverse proxies citeturn20search5turn20search1 | Identity is high‑stakes; misconfigurations can lock you out; migrations are nontrivial | For 1–2: SSO reduces password sprawl. For 50: identity becomes the backbone for least‑privilege access, onboarding/offboarding, and audit. |
| Analytics / dashboards | entity["organization","Metabase","open-source bi"] (AGPL) citeturn19search4turn19search11; entity["organization","Apache Superset","data visualization platform"] (Apache 2.0) citeturn19search1turn19search5; entity["organization","Matomo","web analytics"] (self‑host) citeturn19search6turn19search2 or entity["organization","Plausible Analytics","web analytics"] (AGPL; self‑host) citeturn19search7turn19search3 | BI over your databases + website analytics | Metabase includes an AGPL open source edition and also commercial editions citeturn19search4turn19search11; Superset is an Apache project built for exploration/viz citeturn19search1; Plausible is open source AGPL and self‑hostable citeturn19search7 | Data governance (metrics definitions) becomes a job; dashboards can be misused | For 1–2: quick visibility into sales/support. For 50: you need canonical metrics models, permissions, and “one version of truth” datasets. |
| AI assistants / automation agents | entity["organization","Ollama","local llm runtime"] (MIT; self‑host) citeturn31search0; entity["organization","Open WebUI","self-hosted ai ui"] (self‑host; open source repo) citeturn31search1turn31search9; entity["organization","LangChain","agent framework"] (MIT) citeturn31search2 | Local AI chat, internal “ops copilot”, RAG over docs, automation assistants | Ollama is MIT licensed citeturn31search0; Open WebUI is positioned as offline/self‑hosted and supports Ollama/OpenAI‑compatible APIs citeturn31search9turn31search1; LangChain is MIT licensed citeturn31search2 | Hardware needs can be real; prompt/data leakage risks; patching is critical—Open WebUI has had high‑severity security issues (example CVE and upgrade guidance) citeturn31news39 | For 1–2: huge leverage (drafting emails, proposals, summaries). For 50: treat as a governed internal service with access controls, logging, and a clear “no secrets in prompts” policy. |
| Backup and disaster recovery | entity["organization","restic","backup tool"] (BSD 2‑clause) citeturn23search0turn23search3; entity["organization","BorgBackup","backup tool"] (BSD) citeturn23search4turn23search8; entity["company","Proxmox Backup Server","backup server"] (AGPLv3) citeturn23search10turn23search18 | Encrypted, deduplicated backups; snapshots; VM/container backups | restic explicitly states BSD 2‑Clause citeturn23search0; Borg is BSD‑licensed and emphasises dedup+encryption citeturn23search4; Proxmox Backup Server is AGPLv3 citeturn23search10 | Backups fail silently unless tested; restore drills take time | For 1–2: restic + scheduled DB dumps + config backup. For 50: formal RPO/RTO targets, immutable/off‑site backups, and quarterly restore testing. |
| DevOps / CI/CD (if you ship software) | entity["organization","Forgejo","self-hosted git forge"] (self‑host; FOSS) citeturn21search1turn21search12; entity["organization","Woodpecker CI","ci cd engine"] (open source) citeturn21search14turn21search7; entity["organization","Harbor","container registry"] (Apache 2.0) citeturn25search1turn25search5 **or** GitLab CE (MIT; integrated) citeturn21search19turn21search13 | Git hosting, PRs/issues, CI pipelines, container registry/scanning | GitLab CE licensing is documented as MIT (CE) with Enterprise under different terms citeturn21search19turn21search13; Harbor is Apache 2.0 and designed as an “open source registry” with policy/RBAC/scanning focus citeturn25search5turn25search1 | GitLab can be heavy on a single VPS; Forgejo+Woodpecker is modular (more moving pieces) | For 1–2: Forgejo+Woodpecker is lightweight. For 50: GitLab’s integrated governance can win—if you can afford the infra and operational time. |

## Stack approaches

You can build more than one “correct” stack. The difference is where you accept complexity: in one big system, or in many smaller ones.

**Option A: Modular best‑of‑breed (recommended default for most small companies)**  
Core idea: pick a small set of best tools per domain and integrate them via SSO + automation workflows. You keep each tool relatively replaceable, and you avoid a monolithic ERP being “the place where everything happens”.

Where it shines:
- You can adopt tools incrementally.
- You can swap a tool without migrating your entire business.
- Strong fit for “1–2 people now” because you can defer optional subsystems.

Costs/trade‑offs:
- Integration work is continuous (webhooks, event schemas, permissions).
- Data duplication is a risk unless you define “systems of record”.

**Option B: ERP‑centric (use one suite as the operational core)**  
Core idea: use ERPNext (GPLv3) as the main system of record for customers, invoices, and often projects, because it is explicitly GPLv3 and is positioned as open source. citeturn34search6turn34search10  
You then complement it with a collaboration layer (files/docs/chat) and observability.

Where it shines:
- Fewer integrations for finance/sales/projects because much is in one system.
- Clear “single source of truth” for money and customer entities.

Costs/trade‑offs:
- ERP systems are *organisational change projects*, not just software installs.
- Upgrades, customisations, and workflows require sustained attention.
- If you outgrow the suite, migration is painful.

**Option C: Dev‑platform‑first (if you are building software as your product)**  
Core idea: prioritise a strong engineering platform (Git, CI, registry, observability, identity) so shipping software is highly automated; then add business ops tools. This is a good fit if “the product” is your main activity and everything else is support.

Where it shines:
- Strong release discipline, auditability, and operational confidence.
- Excellent integration capabilities (internal APIs, automated pipelines).

Costs/trade‑offs:
- Easy to overbuild for a 1–2 person company.
- You must still choose business systems (CRM/ERP/support).

## Suggested overall architecture

A robust, automation‑first architecture for this stack typically looks like this (conceptually):

**Edge / ingress**
- Reverse proxy terminates TLS and routes to internal services (Traefik is MIT licensed and explicitly an open‑source reverse proxy; Nginx Proxy Manager is MIT licensed per its GitHub license file). citeturn30search1turn30search11
- Optional API gateway for shared concerns (routing, rate limits, auth) using Kong Gateway (Apache 2.0) or KrakenD (Apache 2.0). citeturn15search1turn15search2

**Identity centre**
- SSO provider (Keycloak or authentik); enforce OIDC/SAML across as many apps as possible. Keycloak’s docs explicitly describe it as a server you manage that secures apps using OIDC/SAML. citeturn34search12turn34search4  
- For apps that don’t support modern SSO, use “SSO at the proxy” (Authelia as a reverse‑proxy companion). citeturn20search5turn20search13

**Systems of record (databases and core apps)**
- Finance system of record: ERPNext or Dolibarr.
- Customer system of record: CRM (SuiteCRM/EspoCRM) or ERPNext CRM module.
- Support system of record: Zammad/FreeScout/Chatwoot.
- File system of record: Nextcloud or Seafile.

**Automation hub**
- Workflow/orchestration engine (Node‑RED for fast automation; Kestra/Temporal to harden and version critical processes). citeturn1search0turn24search9turn1search2  
- Integrations through webhooks, APIs, and a small set of shared automation patterns:
  - “Pull” from APIs on schedule (for tools that lack webhooks)
  - “Push” via webhooks/events when possible
  - “Human‑in‑the‑loop” queues for risky actions (e.g., sending invoices or bulk emails)

**Eventing (optional, but powerful at ~10–50 people)**
- Introduce a lightweight message broker when webhooks become unmanageable:
  - RabbitMQ is explicitly free/open source under MPL 2.0. citeturn14search3  
  - NATS is described as an Apache 2.0 open‑source messaging system. citeturn14search18turn14search6  
Use it primarily as a **buffer** between systems (durable retries, back‑pressure), not as an excuse to rebuild everything “microservices style”.

**Observability + audit**
- Metrics: Prometheus (Apache 2.0). citeturn11search12  
- Dashboards: Grafana (AGPLv3). citeturn11search0turn11search6  
- Traces: OpenTelemetry + Jaeger. citeturn11search1turn12search18  
- Error tracking: GlitchTip (MIT) as a lighter self‑hostable Sentry‑compatible option. citeturn13search0turn13search2

**Backups and DR**
- File‑level and DB‑level backups with restic or Borg; optionally Proxmox Backup Server for VM/container environments. citeturn23search0turn23search4turn23search10  
- Off‑site storage (object storage) for immutable backups, ideally in a different provider/region.

## Automation strategy with concrete playbooks

The value of this stack comes from **automating cross‑domain operations**. Below are examples using “automation hub + SSO + APIs/webhooks” patterns.

**Lead capture → CRM → sales pipeline → project creation**
1. Website form submission creates/updates a Lead in CRM (SuiteCRM/EspoCRM) and tags source/UTM campaign.
2. If lead score passes threshold (rule in automation engine), create an Opportunity and schedule a follow‑up task.
3. When Opportunity moves to “Won”, automation:
   - Creates a project template in project tool (OpenProject/Plane) linked to customer ID
   - Creates a shared folder in Nextcloud/Seafile with permissions for team + customer (if you do shared workspaces)
   - Creates a billing entity in ERP (customer + draft invoice schedule)
4. Sends a “welcome pack” email via listmonk/Mautic and posts a notification into chat (Matrix/Mattermost).

**Client onboarding**
1. In identity provider, create user accounts and groups for the client‑facing area (if any).
2. Provision access to:
   - Files folder
   - Project board
   - Support channel or ticket queue
3. Generate a standard onboarding doc page in BookStack/Wiki.js with checklist and critical links.

**Invoice generation and reminders**
1. ERP system generates invoices based on project milestones or subscription schedule.
2. Automation syncs invoice metadata into CRM (status, amount, due date).
3. If overdue:
   - Automatic reminder emails (polite templates)
   - Internal escalation: create task + notify in chat
4. Weekly finance dashboard in Metabase shows AR aging and overdue invoices.

**Support ticket → engineering task → customer update**
1. Ticket created in Zammad/FreeScout/Chatwoot.
2. Automation routes ticket based on tags/keywords:
   - “Bug” creates an issue in project management (or in your Git forge)
   - “Billing” creates a finance follow‑up task
3. SLA timer triggers alerts in chat and marks risk.
4. When issue is resolved, automation posts back to the ticket and emails the customer.

The key “engineering discipline” element: **every automation should have** (a) an owner, (b) a retry strategy, (c) a dead‑letter queue or “failed runs” inbox, and (d) logging/metrics so failures aren’t silent.

## Deployment strategy, cost analysis, and scaling considerations

### Deployment strategy

**Single VPS (fastest path)**
- Docker Compose for everything (apps + databases) while the company is tiny. Docker Compose is explicitly built for defining and running multi‑container apps. citeturn33search2  
- Split persistent volumes by concern:
  - `/data/db-postgres`
  - `/data/db-mariadb`
  - `/data/nextcloud`
  - `/data/backups`
- Reverse proxy provides TLS termination and routing; keep all admin UIs behind SSO.

**Small homelab**
- Same architecture as VPS, but treat the homelab as a “mini‑data centre”:
  - ZFS snapshots (if available)
  - UPS + monitoring
  - Off‑site backups are mandatory (fire/theft/ransomware).

**Small cluster / Kubernetes**
- Move to a lightweight Kubernetes distribution when you need multi‑node resilience or easier rollouts. K3s is positioned as a production‑ready Kubernetes distribution packaged as a single binary with optional external DB backends and minimal dependencies. citeturn33search1turn33search5  
- Typical breakpoint for “K3s becomes worth it” is ~10+ users with multiple critical apps, or when uptime expectations rise.

### Approximate monthly cost if self‑hosted

Costs vary wildly by workload, but you can estimate with a few consistent components. Below is a reasonable “self‑hosted but realistic” monthly model (excluding labour).

**Compute**
- VPS can be very cheap; for example OVHcloud publishes a “VPS 2026” table showing monthly prices (ex‑VAT) across tiers. citeturn27search5turn27search1  
- If you prefer Hetzner, note that Hetzner has documented price adjustments effective April 1, 2026. citeturn28search1turn28search4  

**Backups (off‑site object storage)**
- Backblaze B2 lists storage pricing after a free tier (e.g., per‑GB‑month pricing on their transaction pricing page). citeturn27search6  

**Email sending relay (recommended instead of self‑hosting outbound SMTP at scale)**
- Amazon SES pricing is explicitly published as $0.10 per 1,000 emails for outbound sending (plus data/attachment charges). citeturn27search3  

A practical ballpark range:
- **1–2 people**: £15–£60/month all‑in (small VPS + modest storage + domain + minimal email relay usage).
- **~10 people**: £60–£200/month (bigger box or two‑node setup + more storage + higher email volume + better monitoring retention).
- **~50 people**: £200–£800+/month (multiple nodes, dedicated DB/storage, higher backup volumes, more logging/metrics retention, maybe dedicated video server capacity).

The dominant cost is rarely licenses; it is usually **storage + backups + compute headroom** and, if you hire help, professional ops time.

### Scaling considerations: what changes at each stage

**From 1–2 people**
- You can run “all‑in‑one” on a single server.
- Bottlenecks: memory (Nextcloud + office editing), email deliverability, and human attention.
- Priority: SSO, backups, low‑friction workflows.

**To ~10 people**
- Start separating **data services** from **apps**:
  - Dedicated Postgres instance/volume.
  - Separate storage (object store or dedicated disk) for files.
- Observability becomes non‑optional; Prometheus + Grafana should be in place, with basic alerts. citeturn11search12turn11search0  
- Introduce “workflow versioning”: move key automations from ad‑hoc flows into revisioned workflows (Kestra YAML and/or Git‑stored automation definitions). citeturn24search9turn24search6  

**To ~50 people**
- Identity becomes the backbone; require OIDC/SAML everywhere possible. Keycloak is documented as a separate server securing apps via OIDC/SAML. citeturn34search12  
- You will likely need:
  - Multi‑node deployment (K3s or similar) citeturn33search1
  - DB replication/HA strategy
  - Formal backup policy + restore testing
  - Log retention strategy and incident response playbooks
- Collaboration suite performance becomes a first‑class SRE concern (files + office editing + chat/video). For video, Jitsi is open and self‑hostable but requires bandwidth planning. citeturn8search19turn8search11  

## Minimal stack and advanced stack

### Minimal stack (5–7 tools) that still covers most company needs

This minimal set aims to cover: CRM/sales, invoicing/accounting, projects, docs, files, chat, automation.

1. **ERPNext** (customers + invoicing/accounting + basic CRM/projects) citeturn34search10turn3search6  
2. **Nextcloud** (files + collaboration; optionally office editing via Nextcloud Office/ONLYOFFICE) citeturn6search14turn7search0  
3. **OpenProject** (project management as the “work execution” layer) citeturn4search20turn4search11  
4. **BookStack** (lightweight internal wiki/SOPs) citeturn5search8turn5search0  
5. **Keycloak** (SSO) citeturn34search12turn34search4  
6. **Node‑RED** (automation glue) citeturn1search0  
7. **Prometheus + Grafana** (basic monitoring) citeturn11search12turn11search0  

This is “monolithic enough to be easy”, while still being modular.

### Advanced stack (15–25 tools) with strong automation and integration

This is a fuller “small‑company operating system” that stays self‑hostable on a small cluster.

**Core platform**
- Reverse proxy: Traefik (MIT) citeturn30search1  
- Identity: Keycloak or authentik citeturn34search12turn34search16  
- API gateway: Kong or KrakenD citeturn15search1turn15search2  
- Workflow orchestration: Kestra + Node‑RED (fast + robust) citeturn24search9turn1search0  
- Eventing (optional): RabbitMQ or NATS citeturn14search3turn14search18  

**Business operations**
- CRM: SuiteCRM or EspoCRM citeturn2search16turn2search20  
- ERP: ERPNext or Dolibarr citeturn34search10turn3search14  
- Support: Zammad + Chatwoot (ticketing + chat) citeturn10search4turn10search17  
- Marketing: Mautic + listmonk citeturn9search4turn9search5  
- Website: WordPress or Ghost; Strapi if you want headless citeturn18search13turn18search14turn18search15  

**Collaboration**
- Files: Nextcloud or Seafile citeturn6search14turn6search8  
- Online docs: ONLYOFFICE Docs CE (AGPLv3) citeturn7search0turn7search9  
- Chat/video: Mattermost + Jitsi or Matrix + Jitsi citeturn8search6turn8search19  

**Data + analytics**
- Databases: PostgreSQL + MariaDB citeturn22search0turn22search1  
- Cache/KV: Valkey citeturn20search7turn20search19  
- BI: Metabase or Superset citeturn19search4turn19search1  
- Web analytics: Plausible or Matomo citeturn19search7turn19search6  

**Engineering / delivery**
- Git forge: Forgejo or GitLab CE citeturn21search1turn21search19  
- CI: Woodpecker citeturn21search14turn21search7  
- Registry: Harbor citeturn25search1turn25search5  
- CD (K8s): Argo CD (Apache 2.0) citeturn25search0turn25search12  

**Reliability**
- Backups: restic or Borg; Proxmox Backup Server if you operate VMs/containers heavily citeturn23search0turn23search10  
- Observability: Prometheus + Grafana + OpenTelemetry + Jaeger citeturn11search12turn11search0turn11search1turn12search18  
- Error tracking: GlitchTip (MIT) citeturn13search0turn13search2  

**Optional AI layer**
- Local LLM runtime: Ollama (MIT) citeturn31search0  
- AI UI: Open WebUI (patch aggressively) citeturn31search9turn31news39  

## Tools to avoid or treat with caution

Some tools are popular in the self‑hosting ecosystem but conflict with “FOSS‑first” or “low‑maintenance” goals.

**n8n as “open source”**  
n8n explicitly states that although its source is available under the **Sustainable Use License**, it does **not** call itself open source because OSI licenses can’t include use limitations. citeturn32search0  
It can still be a pragmatic internal tool, but it breaks a strict “OSI‑open‑source‑only” requirement.

**Redis (licensing volatility)**
Redis publicly acknowledges its March 2024 change to dual RSAL/SSPL (not OSI‑approved) and subsequent community frustration. citeturn20search4  
If you want “boringly open”, Valkey is positioned as a BSD‑licensed fork backed by the Linux Foundation. citeturn20search7turn20search19

**Sentry self‑hosted for small teams**
Sentry’s licensing and self‑hosting footprint make it a poor fit for most tiny companies. Sentry’s community FAQ explicitly notes that BSL is not OSI‑approved and describes the restrictions and conversion model. citeturn29search1  
If you want something simpler to run, GlitchTip is MIT licensed and positioned as a Sentry‑compatible alternative. citeturn13search0turn13search2

**Terraform and HashiCorp Vault (BSL era)**
HashiCorp’s BSL moves created operational and compliance ambiguity for FOSS‑centric stacks; OpenTofu is explicitly MPL‑2.0 licensed per its LICENSE and is a common alternative. citeturn26search4  
For secrets management, OpenBao is positioned as an open‑source community fork of Vault under MPL‑2.0. citeturn29search12turn29search3  
(Secrets management isn’t in your required domains, but it becomes relevant once automations touch credentials.)

**Tools marketed as open source but with heavy “license gating”**
Some tools remain open source at the core but push key operational features behind paid licenses (e.g., identity integrations, enterprise SSO, scaling limits). Rocket.Chat, for example, has documented premium licensing/plan management flows. citeturn32search14turn32search6  
This isn’t automatically “bad”, but it undermines the “minimal licensing costs” goal unless you verify your must‑have features are in the community tier.

**Self‑hosting outbound email as a deliverability strategy**
Mail servers like Mailu/mailcow are legitimate open‑source projects. citeturn9search2turn9search15  
However, at meaningful sending volume, deliverability/reputation is often the real problem—not SMTP software—so many teams use an SMTP relay such as Amazon SES, whose pricing is published and very low per 1,000 emails. citeturn27search3