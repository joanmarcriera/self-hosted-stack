# n8n SSH/API Quickstart

## IDs in current server
Discover them from the live host instead of trusting old notes:

```bash
scripts/n8n/discover_ids.sh
```

Current IDs are intentionally not tracked in the repo. Treat them as live instance data.

## API key mode (preferred for workflow CRUD)
Local secret file (git-ignored):
- `.secrets/n8n-api.env`

Expected keys in file:
- `N8N_BASE_URL="https://n8n.joanmarcriera.es"`
- `N8N_API_KEY="<token>"`

Permissions:
```bash
chmod 700 .secrets
chmod 600 .secrets/n8n-api.env
```

API helper scripts:
```bash
scripts/n8n/list_workflows_api.sh
scripts/n8n/get_workflow_api.sh <workflow-id> | jq '.id,.name,.active'
```

SSH export helper:
```bash
scripts/n8n/export_workflows_ssh.sh .secrets/n8n-live-export/$(date +%F)
```

## Registered Community (free unlock)
Check current status:
```bash
ssh root@joanmarcriera.es 'docker exec n8n n8n license:info'
```

If license is not initialized/invalid, follow:
- `docs/n8n-registered-community-checklist.md`

## Deploy workflow from this repo
```bash
scripts/n8n/deploy_workflow.sh n8n/workflows/001-tls-expiry-guard.json <project-id> --publish
scripts/n8n/deploy_workflow.sh n8n/workflows/002-telegram-assistant.json <project-id> --publish
```

Import the full curated example set without activating anything:

```bash
scripts/n8n/import_example_workflows.sh <project-id>
```

## List workflows
```bash
scripts/n8n/list_workflows.sh
```

## Export live workflows exactly
```bash
scripts/n8n/export_workflows_ssh.sh .secrets/n8n-live-export/$(date +%F)
```

Recommended local-only snapshot location:
- `.secrets/n8n-live-export/`

## Workflow-as-code convention
- Keep workflow JSON in `n8n/workflows/`.
- JSON must include top-level `id` and `versionId`.
- Re-importing same `id` can deactivate that workflow; use `--publish` to reactivate.
- Exact host recovery should use a dated local export snapshot, not the curated examples alone.
- After a clean rebuild, refresh owner/project IDs before importing anything.

## Known pitfalls (and fixes)
- `import:workflow` fails with DB `id` null error:
  - Fix: ensure top-level `id` exists in JSON.
- Re-import deactivates workflow:
  - Fix: redeploy with `--publish`.
- `n8n execute --id=...` fails with task broker port conflict (`5679`):
  - Fix: do not use this in the running main container; validate using schedule + execution logs.
- TLS data source instability (`SSL Labs` 529):
  - Fix: use `crt.sh` JSON endpoint in workflow.

## API-key alternative
- Yes, API key flow works.
- If API key is available, use API for workflow CRUD; keep SSH path for host-level actions and recovery.
- Since the key was shared in chat, rotate it after bootstrap and update `.secrets/n8n-api.env`.
