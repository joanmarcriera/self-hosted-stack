# Commercial Intake Setup

Commercial intake path for the paid Automation Audit:

`riera.co.uk form` -> `n8n webhook` -> `EspoCRM lead` -> `qualification + payment outside the form`

## Scope

- Public site: `https://riera.co.uk/`
- Webhook path: `https://n8n.joanmarcriera.es/webhook/automation-audit-intake`
- CRM target: `https://crm.joanmarcriera.es/api/v1/LeadCapture/<api key>`
- Docs target: BookStack shelf `Commercial Delivery`, book `Automation Audit Templates`

## Workflow

- `n8n/workflows/027-automation-audit-intake.json`
- Validates the paid-audit form payload from `riera.co.uk`
- Requires contact consent and a reply email
- Normalizes the website URL and writes a lead into EspoCRM via the built-in `LeadCapture` endpoint
- Stores the form detail in the lead description for later qualification

## Required n8n environment variables

Add these to `/opt/stacks/automation/.env` and expose them to the `n8n` service:

- `ESPOCRM_API_BASE_URL=https://crm.joanmarcriera.es`
- `ESPOCRM_LEAD_CAPTURE_API_KEY=<api key generated for the Automation Audit Intake lead capture>`

## Bootstrap flow

After syncing the repo to the server:

```bash
cd /root/self-hosted-stack
bash scripts/server/bootstrap_commercial_assets.sh
bash scripts/n8n/deploy_workflow.sh n8n/workflows/027-automation-audit-intake.json 4JNM30bFLjLyuykQ --publish
```

`bootstrap_commercial_assets.sh` will:

- create or refresh the EspoCRM `LeadCapture` entry `Automation Audit Intake`
- copy the generated lead capture API key into `/opt/stacks/automation/.env`
- restart `n8n` with the new env
- seed the BookStack commercial templates

## Lead field mapping

| Form field | EspoCRM field |
| --- | --- |
| `name` | `firstName`, `lastName` |
| `email` | `emailAddress` |
| `company` | `accountName` |
| `website` | `website` |
| `team_size`, `current_tools`, `repetitive_process`, `admin_time_lost`, `desired_outcome` | `description` |
| `contact_consent` | `description` |
| fixed | `leadSource = Web Site` on the lead capture entry |

## Notes

- The original commercial form spec did not include an email field; the live form adds one because the paid audit cannot be qualified or scheduled without a reply channel.
- The shared demo server remains a back-office and demo host only. Do not reuse it for business-critical client production workloads.
