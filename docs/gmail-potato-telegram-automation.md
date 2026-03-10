# Gmail "Potato" -> Telegram -> Manual Reply (n8n)

Last updated: 2026-03-09

## Goal
- Receive emails in `rb4family@gmail.com`.
- If subject/body contains `potato` (case-insensitive), ask in Telegram what to reply.
- Send reply from `marc@riera.co.uk` (Gmail/Google Workspace).
- Preferred auth mode: OAuth2 for Google services.

## 1) Accounts and Credentials You Need
1. Google OAuth app for n8n
   - Follow `docs/google-oauth-n8n-setup.md`.
2. Gmail receive account: `rb4family@gmail.com`
   - Authorized as OAuth test user if app is not published.
3. Gmail send account: `marc@riera.co.uk`
   - Authorized as OAuth test user if app is not published.
3. Telegram bot
   - Create bot via `@BotFather` -> get bot token.
   - Send `/start` to the bot from your Telegram account.
   - Obtain your `chat_id`.

## 2) n8n Credentials to Create
1. `gmail_rb4family_oauth` (Gmail OAuth2)
2. `gmail_marc_oauth` (Gmail OAuth2)
3. `telegram_bot_main`
   - Bot API token from BotFather

## 3) Workflow Design (Recommended: 2 workflows)

### Workflow A: Detect and ask on Telegram
1. `Gmail Trigger` using `gmail_rb4family_oauth`.
2. `Code` node: merge subject + text/html into one lowercase string.
3. `IF` node: contains `potato`.
4. `Code` node: generate `caseId` and prepare metadata (`from`, `replyTo`, `subject`, `snippet`).
5. `Data Store` node: save pending item by `caseId`.
6. `Telegram` node: send message to your `chat_id`:
   - Include sender, subject, snippet, and command template:
   - `/reply <caseId> your text`

### Workflow B: Receive Telegram reply and send email
1. `Telegram Trigger` using `telegram_bot_main`.
2. `Code` node: parse `/reply <caseId> <responseText>`.
3. `Data Store` node: load pending item by `caseId`.
4. `Gmail` node (`Send`) using `gmail_marc_oauth`:
   - To: original `replyTo` (or `from` fallback)
   - Subject: `Re: <original subject>`
   - Body: `<responseText>`
5. `Data Store` node: delete pending item.
6. `Telegram` node: confirm sent / error.

## 4) Safety Rules (important)
- For tests, only trigger when subject includes `[POTATO TEST]` OR sender is in allowlist.
- Ignore messages from `marc@riera.co.uk` to avoid loops.
- Start with plain text replies only.
- Keep family inbox tests isolated (label/filter recommended).

## 5) Telegram chat_id quick methods
- Method A: message `@userinfobot` and read your numeric ID.
- Method B:
  1. Send any message to your bot.
  2. Open: `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
  3. Read `message.chat.id`.

## 6) Test Plan
1. Send test email to `rb4family@gmail.com` with subject: `[POTATO TEST] hello potato`.
2. Confirm Telegram question is received.
3. Reply in Telegram: `/reply <caseId> Thanks, received.`
4. Confirm outbound email is sent from `marc@riera.co.uk`.
5. Confirm pending item is removed in Data Store and execution is green.

## 7) What this does NOT require
- No self-hosted SMTP/IMAP on `joanmarcriera.es`.
- No extra firewall ports beyond current 22/80/443 for this automation.
