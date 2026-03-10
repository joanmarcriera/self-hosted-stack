# AGENTS.md

## Goal
Minimize token usage while keeping operations reproducible for this self-hosted stack repository.

## Default Mode
- Return the shortest useful answer first.
- Reuse prior reports instead of re-summarizing the full stack each turn.
- Load context incrementally.

## Context Scan Workflow (required)
1. Start with targeted grep, not full-file reads.
2. Read only matching windows first (40-120 lines total).
3. Open full files only if a decision-critical gap remains.
4. Prefer sources in this order:
   - `reports/server-hardening-and-n8n-setup-2026-03-09.md`
   - `reports/server-bootstrap-execution-report-2026-03-09.md`
   - `reports/server-logging-and-n8n-verification-2026-03-09.txt`
   - `minimax-summary.md`
   - Other model reports only when explicitly requested

## Output Constraints
- Keep summaries to 8 bullets maximum.
- Use one compact command/result table when useful.
- Avoid repeating unchanged background.
- Always include `Unknown / Not verified yet` when data is missing.

## Report Standard
Write new operational reports to `reports/YYYY-MM-DD-<topic>.md` using this structure:
1. Scope
2. Actions run
3. Findings
4. Risks / unknowns
5. Next 3 steps

## Repo Hygiene
- Keep markdown concise; put bulky command output in `reports/*.txt`.
- Do not commit generated dumps larger than needed.
