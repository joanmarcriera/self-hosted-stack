# Demo Workflows (003-005)

Demo files:
- `n8n/workflows/003-demo-gmail-potato-to-telegram.json`
- `n8n/workflows/004-demo-telegram-reply-to-gmail.json`
- `n8n/workflows/005-demo-webhook-lead-to-sheets.json`

Use the centralized setup guide:
- `n8n/TOMORROW-CONFIG.md`

Discover the current project first:
```bash
scripts/n8n/discover_ids.sh
```

Import one by one (inactive):
```bash
scripts/n8n/deploy_workflow.sh n8n/workflows/003-demo-gmail-potato-to-telegram.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/004-demo-telegram-reply-to-gmail.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/005-demo-webhook-lead-to-sheets.json <project-id>
```
