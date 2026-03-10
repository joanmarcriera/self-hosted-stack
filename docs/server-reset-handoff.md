# Server Reset Handoff

## Goal

Prepare one local handoff package before you wipe the server so I can rebuild the stack without re-asking for usernames, roles, SMTP details, or app-specific choices.

## Files to create locally

Create these two local files in `.secrets/`:

- `.secrets/server-reset-handoff.env`
- `.secrets/server-reset-users.csv`

Do not commit them. `.secrets/` is already gitignored.

Use these committed examples as the starting point:

- `docs/examples/server-reset-handoff.env.example`
- `docs/examples/server-reset-users.csv.example`

If an env value contains spaces, quote it. Example: `OWNER_NAME="Joan Marc Riera"`.

If the current server is still available, start from the live export instead of hand-editing from scratch:

```bash
bash scripts/server/export_reset_handoff_from_live.sh
```

That writes:

- `.secrets/server-reset-handoff.env`
- `.secrets/server-reset-users.csv`

The exported CSV intentionally uses placeholder Authentik passwords. Replace them with real initial passwords before validation or rebuild.

## What I need before the wipe

### 1) Stack-wide inputs

These go in `.secrets/server-reset-handoff.env`:

- base domain
- founder name and email
- timezone
- SMTP settings for Authentik
- the email account that should own n8n after rebuild

Optional but useful if you want the rebuilt stack to keep the same local admin passwords or secrets:

- Grafana local admin username/password
- EspoCRM admin password
- Authentik bootstrap password/token
- n8n basic-auth password
- n8n encryption key
- OIDC client secrets
- OIDC client IDs

If you leave the optional secret fields blank, the rebuild scripts will rotate them.

### 2) User and role list

These go in `.secrets/server-reset-users.csv`.

Each row should contain:

- `username`
- `full_name`
- `email`
- `authentik_groups`
- `authentik_password`
- `n8n_access`

Current Authentik groups for this stack:

- `automation-founders`
- `automation-delivery`
- `automation-ops`

Current app-role intent:

- `automation-founders`: all apps
- `automation-delivery`: BookStack, Vikunja, EspoCRM, Grafana, selective n8n
- `automation-ops`: BookStack, Vikunja, EspoCRM, Grafana

`n8n_access` should be one of:

- `owner`
- `editor`
- `none`

## Important note about n8n

The stack treats `n8n` as the local-auth exception. Record the owner email in the env file and mark the owner row in the CSV, but expect one first-owner login or a later n8n-specific bootstrap step after the rebuild.

## Validate before wiping the server

Run:

```bash
bash scripts/server/validate_reset_handoff.sh
```

If your files live somewhere else:

```bash
bash scripts/server/validate_reset_handoff.sh /path/to/server-reset-handoff.env /path/to/server-reset-users.csv
```

To push the validated handoff pack onto the rebuilt host:

```bash
bash scripts/server/push_reset_handoff.sh
```

## Then the wipe order is

1. Fill the two `.secrets/` files.
2. Run `bash scripts/server/validate_reset_handoff.sh`.
3. Keep DNS pointed at the target hostnames.
4. Reinstall the server to fresh Debian 12.
5. Restore root SSH key access.
6. Run `scripts/server/push_repo_assets.sh`.
7. Run `bash scripts/server/push_reset_handoff.sh`.
8. On the host, run `bash /root/self-hosted-stack/scripts/server/rebuild_from_handoff.sh`.

The rebuild now waits for the Authentik API bootstrap token to become usable before it applies SSO and recovery configuration. That removes the transient fresh-boot race that could otherwise return `403` on a new server.

## Unknown / not handled by this handoff

- Workflow-specific credentials such as Telegram bot tokens, Google OAuth clients, and Sheets IDs are not required for the base stack rebuild.
- Those can be captured separately if you want a full post-rebuild workflow reactivation pack.
- `n8n` still keeps the first-owner bootstrap edge case. The handoff records the intended owner email, but the initial owner registration page may still need one browser step after a full wipe.
