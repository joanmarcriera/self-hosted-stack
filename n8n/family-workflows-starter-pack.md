# Family Starter Pack: 10 Time-Saving Workflows

Prepared as draft workflows (inactive), each with an in-workflow `TODO` sticky note.

## Files

1. `n8n/workflows/016-family-school-email-triage-telegram.json`
2. `n8n/workflows/017-family-school-reply-command-gmail.json`
3. `n8n/workflows/018-family-grocery-command-to-sheets.json`
4. `n8n/workflows/019-family-meal-plan-command-to-sheets.json`
5. `n8n/workflows/020-family-activities-webhook-sheet-telegram.json`
6. `n8n/workflows/021-family-homework-webhook-to-sheets.json`
7. `n8n/workflows/022-family-chore-command-sheet-telegram.json`
8. `n8n/workflows/023-family-expense-command-to-sheets.json`
9. `n8n/workflows/024-family-absence-note-command-gmail.json`
10. `n8n/workflows/025-family-weekly-update-command-gmail.json`

## Setup Guide

- Use `n8n/TOMORROW-CONFIG.md` and jump to the **Family Starter Pack (016-025)** section.

## Import

Discover the current project first:

```bash
scripts/n8n/discover_ids.sh
```

Import everything in one batch:

```bash
scripts/n8n/import_example_workflows.sh <project-id>
```

Or import only selected workflows:

```bash
scripts/n8n/deploy_workflow.sh n8n/workflows/016-family-school-email-triage-telegram.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/017-family-school-reply-command-gmail.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/018-family-grocery-command-to-sheets.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/019-family-meal-plan-command-to-sheets.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/020-family-activities-webhook-sheet-telegram.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/021-family-homework-webhook-to-sheets.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/022-family-chore-command-sheet-telegram.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/023-family-expense-command-to-sheets.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/024-family-absence-note-command-gmail.json <project-id>
scripts/n8n/deploy_workflow.sh n8n/workflows/025-family-weekly-update-command-gmail.json <project-id>
```
