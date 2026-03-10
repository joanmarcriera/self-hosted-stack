# Telegram Assistant (Starter)

## Workflow
- Name: `Telegram Assistant - Starter`
- File: `n8n/workflows/002-telegram-assistant.json`

## Commands
- `/start` or `/help` -> show help
- `/ping` -> `pong`
- `/id` -> show Telegram chat id

## Deploy
```bash
scripts/n8n/discover_ids.sh
scripts/n8n/deploy_workflow.sh n8n/workflows/002-telegram-assistant.json <project-id> --publish
```

## Next step (tomorrow)
- Attach Gmail OAuth flow:
  - inbound message detection for `potato`
  - Telegram ask-for-reply
  - outbound Gmail send
