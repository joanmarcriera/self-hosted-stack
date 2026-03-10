# n8n Registered Community Checklist

Last updated: 2026-03-09

## Why do this
For self-hosted n8n Community Edition, optional registration unlocks extra free features (currently documented by n8n as Folders, Debug in editor, and Custom execution data).

## Current status on this server
- Verified on `2026-03-09` after activation:
  - `isValid: true`
  - `entitlements: 1`
  - `planName: Registered Community`
  - `issuedAt: 2026-03-09 23:13:58 UTC`
  - `expiresAt: 2026-03-19 23:13:58 UTC` (auto-renew enabled)

## Where to register
In n8n UI as owner/admin:
1. Open `Settings`.
2. Open `Usage and plan`.
3. Select `Unlock`.
4. Enter email and request free license key.
5. Open license email and activate key (or paste key in `Enter activation key`).

## Verify after activation
From server:
```bash
ssh root@joanmarcriera.es 'docker exec n8n n8n license:info'
```

Success indicators:
- `isValid: true`
- `entitlements` greater than 0

## If activation fails
1. Confirm server can reach n8n license service (outbound DNS/HTTPS).
2. Confirm key is pasted exactly once and for this instance.
3. If needed, clear and re-activate:
```bash
ssh root@joanmarcriera.es 'docker exec n8n n8n license:clear && docker restart n8n'
```
Then re-enter activation key in UI.

## Notes
- Registration is optional but recommended for free extras.
- n8n states unlocked features can change over time for new registrations.
- Keep a periodic check in ops review:
  - `ssh root@joanmarcriera.es 'docker exec n8n n8n license:info'`
