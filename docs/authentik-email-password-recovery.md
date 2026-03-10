# Authentik Email Password Recovery

## Goal

Enable Authentik password-reset emails so users can set or recover their own passwords without manual `ak changepassword` work.

## What exists now

- `scripts/server/configure_authentik_recovery.sh` imports Authentik's built-in `default-recovery-flow` blueprint if it is missing.
- The script binds that flow to the default Authentik brand.
- The identity compose stack now accepts SMTP settings from `/opt/stacks/identity/.env`.

## Required SMTP settings

Set these in `/opt/stacks/identity/.env` on the host:

```env
AUTHENTIK_EMAIL_HOST=smtp.gmail.com
AUTHENTIK_EMAIL_PORT=587
AUTHENTIK_EMAIL_USERNAME=founder@example.com
AUTHENTIK_EMAIL_PASSWORD=replace-with-app-password
AUTHENTIK_EMAIL_USE_TLS=true
AUTHENTIK_EMAIL_USE_SSL=false
AUTHENTIK_EMAIL_TIMEOUT=10
AUTHENTIK_EMAIL_FROM=founder@example.com
```

For Gmail, use an app password, not the normal account password.

## Get the Gmail app password

Use the Google account that will send the recovery emails, for example `founder@example.com`.

1. Turn on Google 2-Step Verification for that account.
2. Open `https://myaccount.google.com/apppasswords` while signed in.
3. Create a new app password for this server.
4. Give it a clear name such as `Authentik SMTP example.com`.
5. Copy the 16-character password Google shows. Google only shows it once.
6. Put that value into `AUTHENTIK_EMAIL_PASSWORD` in `/opt/stacks/identity/.env`.

Use these values with it:

```env
AUTHENTIK_EMAIL_HOST=smtp.gmail.com
AUTHENTIK_EMAIL_PORT=587
AUTHENTIK_EMAIL_USERNAME=founder@example.com
AUTHENTIK_EMAIL_PASSWORD=<16-character-app-password>
AUTHENTIK_EMAIL_USE_TLS=true
AUTHENTIK_EMAIL_USE_SSL=false
AUTHENTIK_EMAIL_FROM=founder@example.com
```

Do not include spaces if Google displays the password grouped.

Official Google references:

- `https://support.google.com/accounts/answer/185833`
- `https://myaccount.google.com/apppasswords`

## If Google does not show "App passwords"

According to Google's current help, the option can be missing when:

- 2-Step Verification is not enabled yet.
- The account is a work or school account controlled by an organization.
- The account uses Advanced Protection.
- 2-Step Verification is configured only with security keys.

If that happens, either switch to a consumer Gmail account with 2-Step Verification enabled, or use another SMTP relay instead of Gmail.

## Apply on the server

```bash
ssh root@joanmarcriera.es
cd /opt/stacks/identity
docker compose --env-file .env up -d
sleep 20
bash /opt/stacks/scripts/configure_authentik_recovery.sh /opt/stacks
docker exec authentik-server ak test_email founder@example.com
```

## Verify

- `https://auth.joanmarcriera.es` should expose the recovery path from the login flow.
- `docker exec authentik-server ak test_email founder@example.com` should succeed.
- A recovery email should arrive and open the `default-recovery-flow`.
- If you later change the Google account password, create a new app password and update `AUTHENTIK_EMAIL_PASSWORD`.

## Common failure modes

- `ResultTimeout` right after `docker compose up -d` often means the worker was still starting. Wait about `20` seconds and rerun `docker exec authentik-server ak test_email founder@example.com`.
- Gmail on port `587` requires `AUTHENTIK_EMAIL_USE_TLS=true`.
- Remove spaces and quotes from the Gmail app password before saving it in `.env`.

## Current limitation

- If SMTP stays on the default `localhost:25` placeholder, the recovery flow can exist but email delivery will fail.
