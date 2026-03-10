# SME Starter Pack: 10 Classical Workflows

Starter files:
- `n8n/workflows/006-sme-lead-intake-sheet-telegram.json`
- `n8n/workflows/007-sme-lead-autoreply-gmail.json`
- `n8n/workflows/008-sme-support-triage-email-telegram.json`
- `n8n/workflows/009-sme-support-reply-command-gmail.json`
- `n8n/workflows/010-sme-invoice-capture-to-sheets.json`
- `n8n/workflows/011-sme-payment-reminder-command-gmail.json`
- `n8n/workflows/012-sme-new-client-onboarding-kickoff.json`
- `n8n/workflows/013-sme-kpi-capture-command-to-sheets.json`
- `n8n/workflows/014-sme-lead-status-update-command.json`
- `n8n/workflows/015-sme-weekly-report-command-gmail.json`

Use the centralized setup guide:
- `n8n/TOMORROW-CONFIG.md`

Discover the current project first:
```bash
scripts/n8n/discover_ids.sh
```

Import everything in one batch:
```bash
scripts/n8n/import_example_workflows.sh <project-id>
```

Or import the SME set one by one (inactive):
```bash
scripts/n8n/deploy_workflow.sh n8n/workflows/006-sme-lead-intake-sheet-telegram.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/007-sme-lead-autoreply-gmail.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/008-sme-support-triage-email-telegram.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/009-sme-support-reply-command-gmail.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/010-sme-invoice-capture-to-sheets.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/011-sme-payment-reminder-command-gmail.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/012-sme-new-client-onboarding-kickoff.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/013-sme-kpi-capture-command-to-sheets.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/014-sme-lead-status-update-command.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/015-sme-weekly-report-command-gmail.json <project-id>
```
