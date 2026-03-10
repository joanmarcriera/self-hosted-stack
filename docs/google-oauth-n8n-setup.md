# Google OAuth Setup for n8n (Gmail, Drive, Sheets)

Last updated: 2026-03-09

## Goal
Use OAuth2 (not app passwords) for:
- Gmail
- Google Drive
- Google Sheets

## 1) Create Google Cloud project
1. Go to Google Cloud Console.
2. Create/select project (example: `n8n-automation`).
3. Configure OAuth consent screen:
   - User type: External (or Internal if Workspace-only)
   - Add test users (at least your Gmail/Workspace users)

## 2) Enable APIs
Enable these APIs in the same project:
- Gmail API
- Google Drive API
- Google Sheets API

## 3) Create OAuth client
1. APIs & Services -> Credentials -> Create Credentials -> OAuth client ID.
2. Application type: Web application.
3. Add Authorized redirect URI:
   - Use the exact callback URL shown by n8n in the credential UI.
   - Typical self-hosted format: `https://n8n.joanmarcriera.es/rest/oauth2-credential/callback`
4. Save and copy:
   - Client ID
   - Client Secret

## 4) Create credentials in n8n
Create one credential per Google service in n8n:
- Gmail OAuth2 credential
- Google Drive OAuth2 credential
- Google Sheets OAuth2 credential

For each credential:
1. Paste Client ID + Client Secret.
2. Select required scopes (least privilege).
3. Click `Connect my account` and authorize.
4. Save credential.

## 5) Recommended scopes (minimum useful)
- Gmail read (trigger):
  - `https://www.googleapis.com/auth/gmail.readonly`
- Gmail send:
  - `https://www.googleapis.com/auth/gmail.send`
- Drive:
  - `https://www.googleapis.com/auth/drive.file`
- Sheets:
  - `https://www.googleapis.com/auth/spreadsheets`

## 6) For your potato workflow
Use OAuth credentials instead of IMAP/SMTP:
- Replace `Email Trigger (IMAP)` with `Gmail Trigger` (OAuth).
- Replace `Send Email` (SMTP) with `Gmail` node -> `Send` (OAuth).
- Keep Telegram logic unchanged.

## 7) Common pitfalls
1. `redirect_uri_mismatch`
- Cause: URI in Google Cloud does not exactly match n8n callback.
- Fix: copy callback from n8n credential page exactly.

2. `access blocked` / unverified app
- Cause: consent screen/test users not configured.
- Fix: add your accounts as test users (or publish app if needed).

3. Missing API error
- Cause: Gmail/Drive/Sheets API not enabled.
- Fix: enable relevant API in same project.

4. Works in UI but fails in workflow
- Cause: insufficient scope.
- Fix: add required scope and reconnect credential.
