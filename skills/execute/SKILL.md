---
name: execute
description: "Use for Phase 4 of the development workflow: task execution. Implements one task or an entire wave with role-matched expertise, branch isolation, task review files, and debugging framework. Use when someone says 'execute task', 'phase 4', 'implement next task', 'start execution', 'pick up next task', 'execute wave', or 'run wave N'."
argument-hint: "[task X.Y | wave N | next]"
---

## What This Skill Does

Executes Phase 4 (Execution) of the AI-Assisted Development Workflow.

## Execution Modes

- **Single task:** `/agentic-dev:execute task 1.1` or `/agentic-dev:execute next`
- **Entire wave:** `/agentic-dev:execute wave 1`
- **Default (no argument):** Find and execute the next incomplete task.

When executing a **wave**, first create a **feature branch** from `main` to contain all wave work:

```
git checkout main && git checkout -b feature/m{{M}}-wave{{W}}-{{short-description}}
```

Branch naming: `feature/m{{M}}-wave{{W}}-{{short-description}}` (e.g., `feature/m2-wave1-backend-models-upload-ui`). The feature branch is the integration point for all task branches in this wave. It merges to `main` only after the review-fix loop completes with all issues resolved.

Check task dependencies within the wave (each task block has a `Depends on:` field). Run independent tasks (no intra-wave dependencies) in parallel using worktree isolation (`isolation: "worktree"`). Tasks that depend on other tasks in the same wave must wait for their dependency to finish. Each task gets its own branch (`task/X.Y-short-title`) **created from the feature branch**. Complete the full cycle (branch → implement → verify → review file → progress update) for each task.

**Parallel task launch:** Git locks `.git/config` briefly during `git worktree add`. Launching all worktree agents in a single message causes lock contention — most will fail. Instead, launch each independent task agent as a **background agent in a separate sequential message** (one agent per message, each with `isolation: "worktree"` and `run_in_background: true`). The natural processing delay between messages (~2-5s) is enough for git to release the lock. All agents run concurrently once launched — only the launch is serialized. Do NOT wait for each agent to fully complete before launching the next — that eliminates parallelism.

**Wave branch lifecycle (sequential tasks in the same session):**

1. After completing a task, **commit all changes** on the task branch before moving on.
2. **Merge the task branch into the feature branch:**
   ```
   git checkout feature/m{{M}}-wave{{W}}-{{short-description}}
   git merge task/X.Y-short-title
   git branch -d task/X.Y-short-title
   ```
3. Create the next task's branch **from the feature branch** (not from `main`):
   ```
   git checkout -b task/X.Y-next-title
   ```
4. If the next task depends on a completed task in the same wave, that dependency is already merged into the feature branch — no extra merge needed.

Worktree-isolated parallel tasks branch from the feature branch — each agent gets its own worktree with the feature branch as base.

**Note:** If executing individual tasks sequentially (not as a wave), each task follows the single-task flow — branch from `main`, review individually, merge to `main`. Use `execute wave N` when you want batch review with feature branch isolation.

## Important

- **Branch isolation is mandatory.** Every task MUST be on its own branch: `task/X.Y-short-title`. Do NOT work on `main`.
- **One task per session.** Start fresh (`/clear`) before each task. Parallel wave tasks each run as separate agents with worktree isolation, so they inherently start with clean context.
- **Test tasks must NOT share context** with the implementation they're testing.
- Use **worktree isolation** when available: `claude -w task/X.Y-short-title --model opus`
- Match the **agent role** to the task type (see `/agents` for available roles).

## Prompt

**ROLE:**

Activate the appropriate agent role for the task type. The orchestrating agent (auto skill or human) should set the agent type at launch time based on the task's `Role:` field in PLAN.md. If no agent type was set externally, read the task's `Role:` field and activate that role yourself. Available roles:
- `backend-engineer` — API endpoints, service logic, database operations
- `frontend-developer` — UI components, styling, client-side logic
- `data-engineer` — data pipelines, ETL, schema migrations
- `devops-engineer` — CI/CD, infrastructure, deployment
- `security-engineer` — auth, encryption, security hardening
- `qa-engineer` — test tasks
- `senior-engineer` — complex cross-cutting tasks

**CONTEXT:**

You are implementing one task from a development plan.
Read and follow the coding standards in {{PROJECT_INSTRUCTION_FILE — e.g., CLAUDE.md}}.

**TASK:**

{{PASTE THE SPECIFIC TASK BLOCK FROM PLAN.md — including title, role, spec reference, files, acceptance criteria, and test command}}

**SPEC REFERENCE:**

Read `workflow/spec/SPEC.md` section: {{RELEVANT_SECTION_NAME}}

**INSTRUCTIONS:**

1. **Branch isolation (mandatory).** Before writing any code, create a git branch for this task:
   - **During wave execution** (feature branch exists): branch from the feature branch:
     ```
     git checkout feature/m{{M}}-wave{{W}}-{{short-description}}
     git checkout -b task/{{X.Y}}-{{short-title}}
     ```
   - **Single task execution** (no feature branch): branch from `main`:
     ```
     git checkout main
     git checkout -b task/{{X.Y}}-{{short-title}}
     ```
   All work for this task MUST happen on this branch. Do NOT work directly on `main` or the feature branch.
   If using Claude Code worktrees, this is handled by `claude -w task/{{X.Y}}-{{short-title}}`.
2. Implement the task exactly as specified. Follow the coding standards and your role's priorities.
3. After implementation, run these checks:
   - Linting: `{{LINT_COMMAND — e.g., ruff check .}}`
   - Type check: `{{TYPE_CHECK_COMMAND — e.g., mypy src/}}`
   - Tests: `{{TEST_COMMAND — e.g., pytest tests/}}`
   - Acceptance: `{{ACCEPTANCE_COMMAND_FROM_PLAN.md}}`
4. If any check fails, fix the issues and re-run. Do not move on until all pass.
5. Create a task review file at `workflow/plan/reviews/task-{{X.Y}}.md` with this structure:

   ```markdown
   # Task {{X.Y}}: {{Title}}

   ## Work Summary
   - **Branch:** `{{task branch name}}` (based on `{{feature branch or main}}`)
   - **What was implemented:** {1-2 sentences}
   - **Key decisions:** {any non-trivial choices made during implementation}
   - **Files created/modified:** {list}
   - **Test results:** {pass/fail summary}
   - **Spec gaps found:** {any, or "none"}
   - **Obstacles encountered:** {any, with how they were resolved}

   ## Review Discussion

   {Left empty unless the human adds *FEEDBACK:* comments.
   Append-only — never overwrite previous entries.}
   ```
6. Update progress tracking:
   - Mark the task checkbox as `[x]` in `workflow/plan/PLAN.md`
   - Set this task's status to `review` in `workflow/plan/PROGRESS.md`
   - Add the current date
   - Link to the review file in the Review column

**WHEN STUCK (before asking the human for help):**

Use this 5-step framework. Attempt ALL steps before escalating.

1. **Pattern Recognition** — Look across failed attempts. What's the common thread? Are you retrying the same approach with minor variations? Identify the failure category (config, logic, dependency, environment).
2. **Expand Context** — Read 50+ lines around the error site. Search the codebase for similar working patterns. Check dependency versions. Read actual library source code, not just docs.
3. **Verify Assumptions** — Is the error message pointing to the root cause? Are you editing the right file? Is the environment what you think it is? (versions, configs, paths)
4. **Try a Fundamentally Different Approach** — Not a tweak. A different strategy entirely. If debugging a library integration, try a different library. If fixing a function, try rewriting from scratch.
5. **Document and Escalate** — After 3 genuinely different approaches have failed, document in the task review file: what you tried specifically, each attempt's failure mode, your best hypothesis for root cause, and what information you need from the human.

**Rules:**
- Act before asking. Include diagnostic output with any request for help.
- If you cannot access a URL or resource, explicitly report what you couldn't access and why, so the human can provide it manually.
- Never silently skip a step because it seems unlikely to help.

**CONSTRAINTS:**

- Only implement this one task. Do not touch other tasks.
- Do not modify files outside the scope of this task.
- Do not refactor unrelated code.
- Do not add features, error handling, or tests beyond what the acceptance criteria specify.
- Do not add comments, docstrings, or type annotations to code you didn't change.
- If you discover a spec gap (something needed but not defined in SPEC.md), note it in the task review file and PROGRESS.md. Do NOT guess — flag it for human review. If the gap requires a design decision between 2+ viable options, create a decision record in `workflow/decisions/DR-NNN-title.md` and update `workflow/decisions/README.md`.

**FIX MODE (when fixing issues from a review file):**

If the user directs you to fix issues from a review file (e.g., `wave-mM-N.md` or `task-X.Y.md`):

1. Read the review file. Find `### Issues Found` sections (under each `## Task X.Y` heading in wave reviews, or under `## Code Review` in task reviews).
2. Read any fix plan discussion in `## Review Discussion` — look for `### Fix Plan` and any `### Fix Plan Analysis` entries. If multiple AIs analyzed the plan, synthesize their feedback. If a fix was flagged as "revise", follow the revised approach.
3. **Branch from the feature branch** if one exists for this wave. Fix branches should be created from the feature branch, not from `main`:
   ```
   git checkout feature/m{{M}}-wave{{W}}-{{short-description}}
   git checkout -b fix/{{X.Y}}-{{issue-title}}
   ```
   If running multiple fix tasks in parallel, use worktree isolation branching from the feature branch (use parallel launch — see note above). If no feature branch exists (single-task fix), branch from `main`.
4. Implement all approved fixes. Run verification commands (lint, type check, tests, acceptance criteria).
5. Append `### Fix Results` under `## Review Discussion` in the review file:

   ```
   ### Fix Results ({{AI model/tool}} — {{DATE}})

   **Branch:** `{{fix branch name}}` (based on `{{parent branch — feature branch or main}}`)
   **Status: {{N_fixed}}/{{N_total}} fixed, {{N_deferred}} deferred**

   **[B1] ({{title}}) — Fixed**
   - What was changed: {{1-2 sentences}}
   - Files modified: {{list}}

   **[S1] ({{title}}) — Deferred**
   - Reason: {{why it cannot be applied now}}

   **Verification:**
   - {{lint command}} — PASS/FAIL
   - {{test command}} — PASS/FAIL
   ```

6. **STOP.** Do NOT merge, do NOT create a PR. Report what was fixed and the verification results. Tell the user:
   - "Fixes applied on branch `fix/X.Y-issue-title`. Verification: {{results}}."
   - "To verify independently: `/agentic-dev:review verify-fixes wave N`"
   - "To merge after verification: instruct me to merge."

**README UPDATE:**

If this task adds user-facing functionality (CLI commands, API endpoints, UI features), update the **Usage** section of `README.md` with examples showing how to use what was just built. Skip this for internal/infrastructure tasks.

**WHEN DONE (task execution only — does not apply to fix mode):**

Provide a brief summary:
1. Branch name (e.g., `task/1.1-implement-functions`)
2. What was implemented (1-2 sentences)
3. Files created/modified
4. All check results (pass/fail)
5. Any spec gaps or issues discovered
6. Confirm that `workflow/plan/reviews/task-{{X.Y}}.md` has been created
7. Confirm that `workflow/plan/PROGRESS.md` has been updated
8. Next step: Use `/agentic-dev:review wave N` or `/agentic-dev:review task X.Y` for independent code review and spec compliance checking. The review skill will mark the task `done` in PROGRESS.md when validation passes and signal merge readiness.
   - **During wave execution:** Task branches merge into the feature branch (not `main`). The feature branch merges to `main` only after the full review-fix loop completes.
   - **Single task execution:** Task branch merges to `main` after review.

**HUMAN REVIEW PROCESS:**

After you complete the task, the human will review the diff and `workflow/plan/reviews/task-{{X.Y}}.md`.

- If changes are needed, the human will add `*FEEDBACK:*` comments in the review file.
- You should respond with `*AI:*` comments explaining what was changed and why, then re-implement.
- Do not overwrite previous discussion — append new responses below existing conversation.
- When the human is satisfied, they will instruct you to create a PR.

**MERGE / PR CREATION (task execution only, on human instruction only — fix mode has its own stop point above):**

1. Verify the task status is `done` in `workflow/plan/PROGRESS.md`. If still `review`, warn: "Task X.Y has not been validated by the review skill. Run `/agentic-dev:review` first, or confirm you want to proceed."

**Task branch → feature branch (during wave execution):**

2. After each task completes within a wave, merge its task branch into the feature branch:
   - `git checkout feature/m{{M}}-wave{{W}}-{{short-description}} && git merge task/{{X.Y}}-{{short-title}} && git branch -d task/{{X.Y}}-{{short-title}}`
   - This happens as part of the wave lifecycle (see "Wave branch lifecycle" above), typically before the review-fix loop.

**Feature branch → main (after review-fix loop completes):**

3. After the review-fix loop fully completes (all issues resolved, all tasks marked `done`), merge the feature branch to `main`:
   - **Direct merge (solo projects):**
     - `git checkout main && git merge feature/m{{M}}-wave{{W}}-{{short-description}} && git branch -d feature/m{{M}}-wave{{W}}-{{short-description}}`
   - **Create PR (team projects):**
     - Title: `Wave {{W}} (M{{M}}): {{Wave Title}}`
     - Body: tasks included, what was implemented, test results, spec gaps found, review file reference
     - Add the PR link to `workflow/plan/PROGRESS.md`.

**Single task → main (no wave context):**

4. If executing a single task outside wave context (no feature branch):
   - **Direct merge (solo projects):**
     - `git checkout main && git merge task/{{X.Y}}-{{short-title}} && git branch -d task/{{X.Y}}-{{short-title}}`
   - **Create PR (team projects):**
     - Title: `Task {{X.Y}}: {{Task Title}}`
     - Body: what was implemented, which PLAN.md task this addresses, test results, spec gaps found, branch name
     - Add the PR link to `workflow/plan/PROGRESS.md`.
