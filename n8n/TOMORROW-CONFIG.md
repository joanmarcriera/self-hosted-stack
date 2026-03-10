# n8n Tomorrow Configuration Guide

This is the one-page setup guide for the prepared workflow examples.

## Keep These Files Stable

- Workflow JSON files live in `n8n/workflows/`.
- Keep top-level `id` values unchanged. Re-importing with same IDs updates drafts safely.
- All workflows include a sticky note named `TODO` inside n8n with node-specific reminders.

## Prerequisites (once)

1. Gmail OAuth credentials in n8n (one or more accounts):
   - `gmail_marc_oauth`
   - `gmail_support_oauth`
   - `gmail_finance_oauth`
   - `gmail_rb4family_oauth`
2. Telegram credential in n8n:
   - `telegram_bot_main`
3. Google Sheets OAuth credential in n8n:
   - `gsheets_oauth`
4. Values to replace in nodes:
   - `REPLACE_CHAT_ID`
   - `REPLACE_SPREADSHEET_ID`
   - fallback emails such as `REPLACE_TARGET_EMAIL@example.com`

## What To Configure Per Workflow

### Demo Workflows (003-005)

1. `003-demo-gmail-potato-to-telegram.json`
   - Configure: Gmail Trigger credential, Telegram credential, `REPLACE_CHAT_ID` in `Detect Potato`.
   - Test: send email containing `potato` and confirm Telegram alert.
2. `004-demo-telegram-reply-to-gmail.json`
   - Configure: Telegram Trigger/Ack credential, Gmail Send credential, fallback target email.
   - Test command: `/reply case-001 Thanks, we will get back to you tomorrow`.
3. `005-demo-webhook-lead-to-sheets.json`
   - Configure: Google Sheets credential, spreadsheet ID, sheet name, webhook path.
   - Test payload:
```json
{"name":"Test Lead","email":"lead@example.com","company":"ACME","message":"Need automation"}
```

### SME Starter Pack (006-015)

1. `006-sme-lead-intake-sheet-telegram.json`
   - Configure: Sheets credential + ID, Telegram credential, `REPLACE_CHAT_ID`, webhook path.
   - Test payload:
```json
{"name":"Ana","email":"ana@example.com","company":"SME Ltd","source":"website"}
```
2. `007-sme-lead-autoreply-gmail.json`
   - Configure: Gmail Send credential, optional Telegram internal ping credential and `REPLACE_CHAT_ID`.
   - Test payload:
```json
{"name":"Ben","email":"ben@example.com","company":"BlueCo"}
```
3. `008-sme-support-triage-email-telegram.json`
   - Configure: Gmail Trigger credential for support inbox, Telegram credential, `REPLACE_CHAT_ID`.
   - Test: send support email with `urgent` in subject and check P1 telegram text.
4. `009-sme-support-reply-command-gmail.json`
   - Configure: Telegram + Gmail credentials, optional fallback `support@example.com`.
   - Test command: `/supportreply user@example.com We fixed this. Please retry.`
5. `010-sme-invoice-capture-to-sheets.json`
   - Configure: finance Gmail trigger credential, Sheets credential + ID (`Invoices` sheet).
   - Test: send invoice-like email and confirm extracted columns append.
6. `011-sme-payment-reminder-command-gmail.json`
   - Configure: Telegram + Gmail credentials, adjust reminder template.
   - Test command: `/remind client@example.com 1200EUR 2026-03-20`.
7. `012-sme-new-client-onboarding-kickoff.json`
   - Configure: Gmail + Sheets + Telegram credentials, `REPLACE_CHAT_ID`, sheet ID.
   - Test payload:
```json
{"clientName":"Delta Ltd","email":"ops@delta.example","plan":"Starter","owner":"Marc"}
```
8. `013-sme-kpi-capture-command-to-sheets.json`
   - Configure: Telegram + Sheets credentials, sheet ID (`KPI_Log`).
   - Test command: `/kpi 5000 12 8`.
9. `014-sme-lead-status-update-command.json`
   - Configure: Telegram + Sheets credentials, sheet ID (`Lead_Status_Log`).
   - Test command: `/leadstatus alice@example.com contacted sent proposal`.
10. `015-sme-weekly-report-command-gmail.json`
   - Configure: Telegram + Gmail credentials, weekly email template content.
   - Test command: `/weekly founder@example.com W11-2026`.

### Family Starter Pack (016-025)

1. `016-family-school-email-triage-telegram.json`
   - Configure: family Gmail trigger credential, Telegram credential, `REPLACE_CHAT_ID`.
   - Test: forward one school email and confirm Telegram classification.
2. `017-family-school-reply-command-gmail.json`
   - Configure: Telegram + family Gmail credentials.
   - Test command: `/schoolreply yourmail@example.com Thanks, received.`
3. `018-family-grocery-command-to-sheets.json`
   - Configure: Telegram + Sheets credentials, sheet ID (`Groceries`).
   - Test command: `/buy milk 2`.
4. `019-family-meal-plan-command-to-sheets.json`
   - Configure: Telegram + Sheets credentials, sheet ID (`Meal_Plan`).
   - Test command: `/meal monday pasta with veggies`.
5. `020-family-activities-webhook-sheet-telegram.json`
   - Configure: Sheets + Telegram credentials, `REPLACE_CHAT_ID`, webhook path.
   - Test payload:
```json
{"kid":"Alex","activity":"Swimming","when":"2026-03-12 18:00","location":"Local pool"}
```
6. `021-family-homework-webhook-to-sheets.json`
   - Configure: Sheets credential, sheet ID (`Homework`), webhook path.
   - Test payload:
```json
{"kid":"Alex","subject":"Math","task":"Page 34 exercises","dueDate":"2026-03-11"}
```
7. `022-family-chore-command-sheet-telegram.json`
   - Configure: Telegram + Sheets credentials, sheet ID (`Chores`).
   - Test command: `/chore mia tidy bedroom`.
8. `023-family-expense-command-to-sheets.json`
   - Configure: Telegram + Sheets credentials, sheet ID (`Family_Expenses`).
   - Test command: `/expense 24.90 school_supplies notebooks`.
9. `024-family-absence-note-command-gmail.json`
   - Configure: Telegram + family Gmail credentials, replace `REPLACE_SCHOOL_EMAIL@example.com`.
   - Test command: `/absence mia 2026-03-12 fever`.
10. `025-family-weekly-update-command-gmail.json`
   - Configure: Telegram + family Gmail credentials, update email template text.
   - Test command: `/familyweekly founder@example.com W11-2026`.

## Activation Order (recommended)

1. Activate Telegram command workflows first: `009`, `011`, `013`, `014`, `015`.
2. Activate webhook workflows: `005`, `006`, `007`, `012`.
3. Activate Gmail trigger workflows last: `003`, `008`, `010`.
4. For family pack, activate in this order: `018`, `019`, `022`, `023`, `017`, `024`, `025`, `020`, `021`, `016`.

## Safety Rule

- Keep new workflows inactive until each one passes a manual test.
- Only then activate one-by-one to avoid noisy or accidental outbound messages.
