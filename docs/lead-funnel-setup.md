# Lead Funnel Setup Guide

End-to-end setup for the website lead capture funnel:
`sme.riera.co.uk form` → `n8n webhook` → `EspoCRM + Telegram + Vikunja`

---

## Overview

When a prospect fills out the contact form on sme.riera.co.uk:

1. **n8n** receives the POST at `/webhook/lead-intake`
2. **Validates & normalizes** the payload (name, email, company_size, pain)
3. **Creates a Lead** in EspoCRM (status: New, source: Web Site)
4. **Sends a Telegram notification** to Marc with lead details
5. **Emails Marc** at joanmarcriera@gmail.com with a formatted lead summary
6. **Sends a welcome email** to the lead thanking them and linking to the live status page
7. **Creates a follow-up task** in Vikunja (due in 24h)
8. **Returns** `{success: true}` to the form

---

## Prerequisites

- n8n running at `n8n.joanmarcriera.es`
- EspoCRM running at `crm.joanmarcriera.es`
- Vikunja running at `tasks.joanmarcriera.es`
- Telegram bot token + chat ID
- Landing page deployed at `sme.riera.co.uk`

---

## Step 1: Import the workflow

```bash
cd /opt/stacks/automation
bash ../../scripts/n8n/import_example_workflows.sh 026-lead-intake-funnel.json
```

Or import manually via n8n UI: Settings → Import from file → select `n8n/workflows/026-lead-intake-funnel.json`.

---

## Step 2: Configure credentials in n8n

### Gmail OAuth
- In n8n, add a Gmail OAuth2 credential (`gmail_marc_oauth`) connected to joanmarcriera@gmail.com
- Assign it to both "Email Notification to Marc" and "Welcome Email to Lead" nodes

### EspoCRM API
- Create an API User in EspoCRM (Administration → API Users) with Lead create permission
- In n8n, add an HTTP Basic Auth credential with the API User's username and API Key
- Replace `REPLACE_ESPOCRM_URL` in the "Create Lead in EspoCRM" node with `https://crm.joanmarcriera.es`

### Telegram Bot
- Use your existing bot token (same as other SME workflows)
- Replace `REPLACE_CHAT_ID` in the "Validate & Normalize" code node with your chat ID
- Assign the `telegram_bot_main` credential to the "Notify via Telegram" node

### Vikunja API
- Get an API token from Vikunja (Settings → API Tokens)
- In n8n, create an HTTP Header Auth credential: `Authorization: Bearer <token>`
- Replace `REPLACE_VIKUNJA_PROJECT_ID` in the "Create Follow-up Task" node with the target project ID

---

## Step 3: Configure CORS

The form on `sme.riera.co.uk` (GitHub Pages) POSTs to `n8n.joanmarcriera.es`. This is a cross-origin request.

### Option A: n8n webhook CORS (preferred)
The workflow already sets `allowedOrigins: "https://sme.riera.co.uk"` in the webhook node options. This should work with n8n v1.30+.

### Option B: Traefik middleware
If n8n's built-in CORS doesn't work, add a Traefik middleware in `opt-stacks/core/docker-compose.yml`:

```yaml
# Add to n8n service labels
- "traefik.http.middlewares.cors-sme.headers.accesscontrolalloworiginlist=https://sme.riera.co.uk"
- "traefik.http.middlewares.cors-sme.headers.accesscontrolallowmethods=POST,OPTIONS"
- "traefik.http.middlewares.cors-sme.headers.accesscontrolallowheaders=Content-Type"
- "traefik.http.routers.n8n-webhooks.middlewares=cors-sme"
```

---

## Step 4: Test

### Test with curl
```bash
curl -X POST https://n8n.joanmarcriera.es/webhook-test/lead-intake \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Lead","email":"test@example.com","company_size":"6-20","pain":"Too many manual processes"}'
```

Expected response: `{"success":true,"message":"Thanks! We will be in touch within 24 hours."}`

### Verify downstream
- [ ] EspoCRM: New lead appears under Leads with status "New"
- [ ] Telegram: Notification received with lead details
- [ ] Vikunja: Follow-up task created in target project, due tomorrow

### Test from the landing page
1. Open `sme.riera.co.uk` in a browser
2. Scroll to the contact form
3. Fill in test data and submit
4. Verify the success message appears
5. Check EspoCRM, Telegram, and Vikunja

---

## Step 5: Activate

Once all tests pass, activate the workflow in n8n (toggle the Active switch). Change the webhook from `webhook-test` to `webhook` (n8n does this automatically on activation).

---

## EspoCRM Lead Fields Mapping

| Form Field | EspoCRM Field | Notes |
|-----------|---------------|-------|
| name | firstName + lastName | Split on first space |
| email | emailAddress | Primary email |
| company_size | description | Prepended with "Company size:" |
| pain | description | Appended after company size |
| (auto) | status | Set to "New" |
| (auto) | source | Set to "Web Site" |

---

## Troubleshooting

**Form submits but no n8n execution:**
- Check browser devtools Network tab for CORS errors
- Verify the webhook URL is correct and workflow is active

**CORS error in browser:**
- Ensure n8n webhook has `allowedOrigins` set, or Traefik middleware is configured
- Test with `curl` first to isolate whether it's a CORS issue or a workflow issue

**EspoCRM returns 403:**
- Check API User permissions (needs Lead create access)
- Verify Basic Auth credentials in n8n match the API User

**Telegram notification not received:**
- Verify chat ID is correct (use `/getUpdates` on your bot to confirm)
- Check the bot has permission to send messages to the chat
