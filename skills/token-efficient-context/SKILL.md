---
name: token-efficient-context
description: Minimize context usage in this repository when requests touch long research docs or many reports. Use for stack decisions, deployment status questions, and "what next" planning where only a small subset of files should be read.
---

# Token Efficient Context

## Workflow
1. Convert the request into 2-4 search keywords.
2. Run `scripts/context_skim.sh "<keywords>"`.
3. Open at most two files around the best matches first.
4. Expand to more files only if required to remove uncertainty.
5. Answer briefly and include unresolved unknowns.

## Hard Limits
- Initial read budget: 120 lines total.
- Initial source budget: 2 files.
- Response budget: 8 bullets plus optional 3-step next actions.

## Output Pattern
Use this structure:
1. `Answer`
2. `Evidence (file + line hint)`
3. `Unknown / needs check`
4. `Next actions` (only if needed)

## Resources
- Use `scripts/context_skim.sh` for first-pass retrieval.
- Use `references/source-priority.md` for canonical source order.
