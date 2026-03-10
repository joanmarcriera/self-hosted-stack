# Demo Consultancy Blueprint

This stack is now framed as a 3-person automation consultancy that designs, deploys, and supports workflow automation for other SMEs.

## Company model

- Company type: boutique automation consultancy
- Core offer:
  - lead intake automation
  - sales/support workflow automation
  - onboarding automation
  - KPI and reporting automation
  - documentation and handover
- Delivery style: fixed-scope discovery, short implementation sprints, ongoing support retainers

## Team personas

### 1. Joan Marc Riera
- Role: Founder and Automation Strategist
- Focus:
  - sales discovery
  - solution design
  - pricing and proposals
  - final approval on production automations
- Main tools:
  - EspoCRM
  - n8n
  - BookStack
  - Grafana

### 2. Alex Serra
- Role: Automation Engineer and Delivery Lead
- Focus:
  - workflow implementation
  - app integration
  - webhook/API work
  - production fixes and releases
- Main tools:
  - n8n
  - Vikunja
  - BookStack
  - Grafana

### 3. Marta Costa
- Role: Client Success and Operations Coordinator
- Focus:
  - lead qualification follow-up
  - kickoff scheduling
  - documentation hygiene
  - recurring client communications
- Main tools:
  - EspoCRM
  - Vikunja
  - BookStack
  - Grafana

## Role model

| Role | Primary outcome | Decision power | Tools with strongest ownership |
|---|---|---|---|
| Founder / Strategist | close deals and approve design | highest | CRM, n8n, docs |
| Delivery Lead | build and operate automations | medium-high | n8n, tasks, docs |
| Client Success / Ops | keep clients informed and work moving | medium | CRM, tasks, docs |

## Access matrix

| App | Joan Marc | Alex | Marta | Why |
|---|---|---|---|---|
| Authentik | admin | user | user | central identity |
| n8n | admin/editor | editor | no routine access | avoid unnecessary production access |
| EspoCRM | admin | contributor | daily user | pipeline and client record |
| Vikunja | admin | admin | manager | sprint and delivery tracking |
| BookStack | admin | editor | editor | SOPs, runbooks, client notes |
| Grafana | admin | viewer | viewer | service health and later funnel metrics |

## Demo operating rhythm

- Joan Marc captures and qualifies demand in EspoCRM.
- Alex translates won work into implementation tasks and automations.
- Marta runs onboarding, keeps documentation current, and follows up on open actions.

## Demo client lifecycle

1. Lead arrives through a form or referral.
2. EspoCRM tracks company, contact, and deal stage.
3. n8n enriches the lead, alerts the team, and updates operational sheets if needed.
4. Once a deal is won, n8n creates kickoff tasks in Vikunja.
5. BookStack gets a client space for requirements, SOPs, and handover notes.
6. Grafana watches public endpoints and gives the team one place to add future funnel metrics.
7. Recurring reporting workflows send weekly summaries or reminders.

## Demo automations to showcase

- Lead intake to sheet + Telegram
- Lead auto-reply by Gmail
- Support inbox triage
- Payment reminder command
- New client onboarding kickoff
- Weekly KPI and report summaries

## Seeded demo records

- BookStack:
  - shelf: `Demo Clients`
  - book: `Acme Bakery Automation`
  - pages: `Discovery Brief`, `Implementation Runbook`, `Weekly KPI Handover`
- Vikunja:
  - projects: `Acme Bakery - Delivery Sprint`, `Internal SME Demo Stack`
  - task examples are assigned across Joan Marc, Alex, and Marta when those users exist
- EspoCRM:
  - accounts: `Acme Bakery`, `Blue Harbor Legal`
  - contacts: `Nora Patel`, `Daniel Ross`
  - opportunities: `Acme Bakery onboarding automation`, `Blue Harbor intake triage`
- Grafana:
  - overview dashboard: `https://status.joanmarcriera.es/d/stack-overview/stack-overview`
  - public group: `Public Services`

## What this demonstrates

- small teams can operate with clear role boundaries
- the CRM, task layer, docs layer, and automation layer can reinforce each other
- production automation work is easier to sell when delivery and handover are visible

Unknown / Not verified yet:
- whether these exact three personas should become real users in the live apps, or stay as a demo operating model only
