# Account And Access Policy

## Short answer

No: do not create local accounts in every service.

Current policy for this stack:
- `n8n`: local accounts are acceptable and expected
- `BookStack`, `Vikunja`, `EspoCRM`: use Authentik SSO
- `Grafana`: use Authentik OIDC

## Why

- Local accounts created too early become migration cleanup later.
- The point of `auth.joanmarcriera.es` is to centralize identity and access decisions.
- n8n is the exception because the self-hosted free setup is not the same SSO path as the rest of the stack.

## Current state

- Authentik is deployed at `https://auth.joanmarcriera.es`
- n8n is live and uses local login
- BookStack is live and uses Authentik OIDC
- Vikunja is live and uses Authentik OpenID, with the web entrypoint redirected to the Authentik provider
- EspoCRM is live and uses Authentik OIDC with team sync
- Grafana is live and uses Authentik OIDC
- `automation-founders`, `automation-delivery`, and `automation-ops` exist in Authentik
- Alex Serra is active in `automation-delivery`
- Marta Costa is active in `automation-ops`

## Target state

### Authentik groups

- `automation-founders`
- `automation-delivery`
- `automation-ops`

### Intended app access

| Group | Apps | Notes |
|---|---|---|
| `automation-founders` | all apps | business and technical oversight |
| `automation-delivery` | BookStack, Vikunja, EspoCRM, Grafana, selective n8n | implementation team |
| `automation-ops` | BookStack, Vikunja, EspoCRM, Grafana | client coordination |

## Who should get local accounts right now

- n8n:
  - Joan Marc
- BookStack: none
- Vikunja: none
- EspoCRM: none
- Grafana: none

## When to create accounts in the other apps

BookStack, Vikunja, EspoCRM, and Grafana are ready now:
1. create the user once in Authentik
2. place them in the right group
3. let `https://docs.joanmarcriera.es`, `https://tasks.joanmarcriera.es`, `https://crm.joanmarcriera.es`, and `https://status.joanmarcriera.es` create the user session on first login
4. EspoCRM will sync the first matching team from the Authentik `groups` claim on login
5. Grafana stays on Authentik OIDC, with its local admin kept only as break-glass access

Current onboarding rule:
- Joan Marc: use Authentik for BookStack, Vikunja, EspoCRM, and Grafana; local auth for n8n
- Alex Serra: already created in Authentik, validated in `automation-delivery`, then use BookStack/Vikunja/EspoCRM/Grafana through SSO
- Marta Costa: already created in Authentik, validated in `automation-ops`, then use BookStack/Vikunja/EspoCRM/Grafana through SSO

## Operational rule for future changes

- If I am still bootstrapping or wiring auth for a service, wait before creating users manually.
- If a service is declared ready for user onboarding, I will give you the exact user-creation sequence.

## Recommended next access rollout

1. Have Alex and Marta sign into BookStack, Vikunja, and EspoCRM once so the live access paths are exercised.
2. Keep n8n on local auth plus API key unless a second operator truly needs workflow-edit access.
3. Decide whether Grafana should stay a pure status/dashboard surface or become the place for later funnel and revenue metrics too.

Unknown / Not verified yet:
- whether Alex and Marta's first real browser login into EspoCRM should trigger exactly the team mapping expected from the current group claims
- whether the Vikunja API will ever reflect `auth.local.enabled=false` cleanly, or whether the Authentik-first redirect should remain the stable UX path
