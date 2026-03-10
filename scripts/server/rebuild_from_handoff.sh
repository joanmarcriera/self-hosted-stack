#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
stack_root="${1:-/opt/stacks}"
handoff_env="${2:-${stack_root}/secrets/server-reset-handoff.env}"
users_csv="${3:-${stack_root}/secrets/server-reset-users.csv}"

bash "${script_dir}/validate_reset_handoff.sh" "$handoff_env" "$users_csv"

set -a
source "$handoff_env"
set +a

bash "${script_dir}/bootstrap_host.sh"
bash "${script_dir}/render_stack_envs.sh" "${BASE_DOMAIN:-example.com}" "${OWNER_EMAIL:-founder@example.com}" "$handoff_env"
bash "${script_dir}/deploy_stack.sh"
bash "${script_dir}/configure_sso.sh" "$stack_root" "${OWNER_NAME:-Joan Marc Riera}"
bash "${script_dir}/configure_authentik_recovery.sh" "$stack_root"
bash "${script_dir}/import_authentik_reset_users.sh" "$stack_root" "$users_csv"
bash "${script_dir}/configure_grafana_monitoring.sh" "$stack_root"
bash "${script_dir}/seed_demo_content.sh" "$stack_root"
bash "${script_dir}/verify_stack.sh"
