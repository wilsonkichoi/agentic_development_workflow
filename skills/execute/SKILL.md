---
name: execute
description: "Use for Phase 4 of the development workflow: task execution. Implements one task or an entire wave with role-matched expertise, branch isolation, task review files, and debugging framework. Use when someone says 'execute task', 'phase 4', 'implement next task', 'start execution', 'pick up next task', 'execute wave', or 'run wave N'."
argument-hint: "[task X.Y | wave N | next]"
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 4 (Execution) of the AI-Assisted Development Workflow. Implements tasks from PLAN.md with role-appropriate expertise, branch isolation, automated verification, and task review files for human feedback.

## Execution Modes

- **Single task:** `/agentic-dev:execute task 1.1` or `/agentic-dev:execute next`
- **Entire wave:** `/agentic-dev:execute wave 1`
- **Default (no argument):** Find and execute the next incomplete task.

When executing a **wave**, run each task in the wave sequentially. Each task gets its own branch (`task/X.Y-short-title`). Complete the full cycle (branch → implement → verify → review file → progress update) for each task before starting the next.

## Important

- **Branch isolation is mandatory.** Every task MUST be on its own branch: `task/X.Y-short-title`. Do NOT work on `main`.
- **One task per session.** Start fresh (`/clear`) before each task. For wave execution, `/clear` between tasks.
- **Test tasks must NOT share context** with the implementation they're testing.
- Use **worktree isolation** when available: `claude -w task/X.Y-short-title --model opus`
- Match the **agent role** to the task type (see `/agents`).

## Instructions

Read [template.md](template.md) for the detailed phase template.

Key points:
1. **Create a branch** before writing any code: `git checkout -b task/X.Y-short-title`
2. Read PLAN.md, find the target task (from `$ARGUMENTS`, or next incomplete)
3. Activate the appropriate role agent for the task type
4. Implement, then run all checks (lint, type check, tests, acceptance)
5. Create `workflow/plan/reviews/task-X.Y.md` with work summary
6. Mark task as `[x]` in PLAN.md, set status to `review` in PROGRESS.md
7. Wait for human review. If `*FEEDBACK:*` given, respond with `*AI:*` and re-implement
8. Create PR only when human instructs

## When stuck — 5-step debugging framework

1. **Pattern Recognition** — identify failure category, stop retrying same approach
2. **Expand Context** — read 50+ lines around error, search codebase for working patterns
3. **Verify Assumptions** — is the error pointing to root cause? right file? right env?
4. **Fundamentally Different Approach** — not a tweak, a different strategy
5. **Document and Escalate** — after 3 different approaches fail, document in review file

## Output

- Working code in feature branch (NOT merged)
- `workflow/plan/reviews/task-X.Y.md`
- Updated `workflow/plan/PROGRESS.md`
- PR (on human instruction only)
