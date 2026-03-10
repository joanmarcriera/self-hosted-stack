#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $(basename "$0") <search terms>"
  exit 1
fi

query="$*"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

files=(
  "$repo_root/README.md"
  "$repo_root/AGENTS.md"
  "$repo_root/minimax-summary.md"
  "$repo_root/reports/server-hardening-and-n8n-setup-2026-03-09.md"
  "$repo_root/reports/server-bootstrap-execution-report-2026-03-09.md"
  "$repo_root/reports/server-logging-and-n8n-verification-2026-03-09.txt"
)

echo "Query: $query"
echo "---"
rg -n -S --no-heading "$query" "${files[@]}" | head -n 40 || true
