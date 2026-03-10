---
name: compact-ops-report
description: Produce concise and repeatable operational reports for server inventory, hardening, deployment, and verification work. Use when a user asks what was done, current status, risks, or immediate next steps.
---

# Compact Ops Report

## Workflow
1. Define scope in one sentence.
2. Run only commands needed to prove the scope.
3. Store raw verbose output in `reports/*.txt`.
4. Write concise markdown report using the template in `references/report-template.md`.
5. Keep findings factual and directly tied to command evidence.

## Limits
- 5 fixed sections only.
- Findings section: maximum 8 bullets.
- Next steps: maximum 3 numbered actions.

## Rules
- Do not paste long logs into markdown.
- Do not restate unchanged background from earlier reports.
- Mark unverified points explicitly.

## Resources
- Use `references/report-template.md` as the default structure.
