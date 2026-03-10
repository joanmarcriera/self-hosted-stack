# Server config snapshot

These files mirror the Debian host config fragments captured from `root@joanmarcriera.es` on 2026-03-10.

Paths under this directory map directly to server paths under `/etc/`.

Package baseline expected by these files:
- `ufw`
- `fail2ban`
- `unattended-upgrades`
- `auditd`
- `audispd-plugins`
- `tlog`
- `python3-systemd`
- Docker Engine + Compose plugin

Apply order:
1. Install the package baseline.
2. Copy `server-config/etc/` into `/etc/`.
3. Validate and reload SSH: `sshd -t && systemctl reload ssh`.
4. Apply kernel tuning: `sysctl --system`.
5. Load audit rules: `augenrules --load && systemctl restart auditd`.
6. Restart journald and fail2ban: `systemctl restart systemd-journald fail2ban`.
7. Reconnect over SSH once to confirm `tlog` recording starts on interactive sessions.
