#!/usr/bin/env bash
set -euo pipefail

stack_root="${1:-/opt/stacks}"
users_csv="${2:-${stack_root}/secrets/server-reset-users.csv}"
identity_env="${stack_root}/identity/.env"

[[ -f "$identity_env" ]] || {
  printf 'missing required file: %s\n' "$identity_env" >&2
  exit 1
}

[[ -f "$users_csv" ]] || {
  printf 'missing required file: %s\n' "$users_csv" >&2
  exit 1
}

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
handoff_env="${stack_root}/secrets/server-reset-handoff.env"

if [[ -x "${script_dir}/validate_reset_handoff.sh" && -f "$handoff_env" ]]; then
  bash "${script_dir}/validate_reset_handoff.sh" "$handoff_env" "$users_csv" >/dev/null
fi

users_json="$(python3 - "$users_csv" <<'PY'
import csv
import json
import sys

path = sys.argv[1]
rows = []

with open(path, newline="", encoding="utf-8") as handle:
    reader = csv.DictReader(handle)
    for row in reader:
        username = (row.get("username") or "").strip()
        if not username:
            continue
        rows.append(
            {
                "username": username,
                "full_name": (row.get("full_name") or "").strip(),
                "email": (row.get("email") or "").strip(),
                "authentik_groups": [
                    group.strip()
                    for group in (row.get("authentik_groups") or "").split(";")
                    if group.strip()
                ],
                "authentik_password": row.get("authentik_password") or "",
            }
        )

print(json.dumps(rows, separators=(",", ":")))
PY
)"

python_code="$(cat <<'PY'
import json
import os

from authentik.core.models import Group, User

users = json.loads(os.environ["RESET_USERS_JSON"])
summary = []

for record in users:
    username = record["username"]
    user, created = User.objects.get_or_create(username=username)
    user.name = record["full_name"]
    user.email = record["email"]
    user.is_active = True
    if hasattr(user, "type") and not getattr(user, "type", None):
        user.type = "internal"
    user.save()
    user.set_password(record["authentik_password"])
    user.save()

    preserved = list(
        user.groups.exclude(name__startswith="automation-").values_list("pk", flat=True)
    )
    target = list(preserved)
    group_names = []
    for group_name in record["authentik_groups"]:
        group, _ = Group.objects.get_or_create(name=group_name)
        target.append(group.pk)
        group_names.append(group.name)
    user.groups.set(sorted(set(target)))
    summary.append(
        f"{username}:{'created' if created else 'updated'}:{';'.join(group_names)}"
    )

print("authentik-users " + ",".join(summary))
PY
)"

docker exec \
  -e RESET_USERS_JSON="$users_json" \
  authentik-server \
  ak shell -c "$python_code"
