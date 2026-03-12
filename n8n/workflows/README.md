# Workflow Inventory

Canonical workflow examples for this repo.

## Core

- `001-tls-expiry-guard.json` - TLS expiry monitor for `n8n.joanmarcriera.es`.
- `002-telegram-assistant.json` - Telegram assistant starter.

## Demo (quick tests)

- `003-demo-gmail-potato-to-telegram.json` - Gmail keyword detection to Telegram alert.
- `004-demo-telegram-reply-to-gmail.json` - Telegram command to Gmail send.
- `005-demo-webhook-lead-to-sheets.json` - Webhook to Google Sheets.

## SME Starter Pack

- `006-sme-lead-intake-sheet-telegram.json` - Lead intake to sheet + Telegram.
- `007-sme-lead-autoreply-gmail.json` - Lead auto-reply by Gmail.
- `008-sme-support-triage-email-telegram.json` - Support inbox triage.
- `009-sme-support-reply-command-gmail.json` - Support reply via Telegram command.
- `010-sme-invoice-capture-to-sheets.json` - Invoice capture to sheet.
- `011-sme-payment-reminder-command-gmail.json` - Payment reminder command.
- `012-sme-new-client-onboarding-kickoff.json` - New client onboarding kickoff.
- `013-sme-kpi-capture-command-to-sheets.json` - KPI capture command.
- `014-sme-lead-status-update-command.json` - Lead status logging command.
- `015-sme-weekly-report-command-gmail.json` - Weekly report command.

## Family Starter Pack

- `016-family-school-email-triage-telegram.json` - School email triage to Telegram.
- `017-family-school-reply-command-gmail.json` - Reply to school by Telegram command.
- `018-family-grocery-command-to-sheets.json` - Grocery command to sheet.
- `019-family-meal-plan-command-to-sheets.json` - Meal plan command to sheet.
- `020-family-activities-webhook-sheet-telegram.json` - Activities webhook to sheet + Telegram.
- `021-family-homework-webhook-to-sheets.json` - Homework webhook to sheet.
- `022-family-chore-command-sheet-telegram.json` - Chore done command log.
- `023-family-expense-command-to-sheets.json` - Family expense capture command.
- `024-family-absence-note-command-gmail.json` - School absence note command.
- `025-family-weekly-update-command-gmail.json` - Weekly family update command.

## Important

- `026-lead-intake-funnel.json` - older broad website lead funnel example for `sme.riera.co.uk`.
- `027-automation-audit-intake.json` - paid Automation Audit intake for `riera.co.uk` into EspoCRM.
- Keep each workflow `id` unchanged to preserve update-in-place behavior when importing.
- Full setup checklist: `n8n/TOMORROW-CONFIG.md`.
