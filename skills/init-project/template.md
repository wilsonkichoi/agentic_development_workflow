# Project Instructions

## Project
- Name: {{PROJECT_NAME}}
- Description: {{ONE_LINE_DESCRIPTION}}

## Workflow

This project follows the AI-Assisted Software Development Workflow.
See `templates/phases/` for phase-specific prompts and `templates/roles/` for role definitions.

If you have the `agentic-dev` plugin installed, use:
- `/agentic-dev:research` — Phase 1
- `/agentic-dev:spec` — Phase 2
- `/agentic-dev:plan` — Phase 3
- `/agentic-dev:execute` — Phase 4
- `/agentic-dev:verify` — Phase 5

### Quick Reference

| Phase | Template | Mode |
|-------|----------|------|
| 1. Research | `templates/phases/01-research.md` | Normal |
| 2. Specification | `templates/phases/02-specification.md` | Plan/read-only |
| 3. Task Breakdown | `templates/phases/03-task-breakdown.md` | Normal |
| 4. Execution | `templates/phases/04-execution.md` | Worktree |
| 5. Verification | `templates/phases/05-verification.md` | Normal |

### Key Documents
- Spec: `workflow/spec/SPEC.md`
- Plan: `workflow/plan/PLAN.md`
- Progress: `workflow/plan/PROGRESS.md`
- Decisions: `workflow/decisions/`

## Architecture

{{FILL_IN_AFTER_PHASE_2 — architecture summary, 5-10 lines}}

## Build & Test

{{FILL_IN — e.g., npm install, npm test, npm run lint}}

## Tooling Preferences

{{FILL_IN — e.g., Package manager: uv, Python version: >=3.12, Linter: ruff, Formatter: ruff format}}

## Coding Standards

{{FILL_IN_AFTER_PHASE_2 — or link to workflow/spec/SPEC.md}}
