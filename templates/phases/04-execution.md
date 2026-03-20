# Phase 4: Task Execution — Prompt Template

## When to Use

After Phase 3 task breakdown is reviewed and approved. Use this **once per task** — start each task with a fresh context.

## Recommended Model

Highest reasoning available. Best model produces best code.
- Claude Code: `claude -w task/X.Y-short-title --model opus`
- Copilot CLI: `copilot --model claude-opus-4.6 --autopilot --max-autopilot-continues 30`

## Important

- **Branch isolation is mandatory.** Every task MUST be on its own branch: `task/X.Y-short-title`. Do NOT work directly on `main`.
- One task per session. Do NOT batch multiple tasks.
- Start with a clean context (`/clear` or new session) before each task.
- Avoid `/compact` — lossy summarization risks hallucination.
- Match the role to the task type. See `templates/roles/README.md`.
- **Test tasks must NOT share context with the implementation task they're testing.** Start a completely separate session.

## Prompt

Copy everything below the line, fill in `{{placeholders}}`, and paste into your tool.

---

**ROLE:**

{{PASTE THE ROLE DEFINITION FROM templates/roles/ — e.g., backend-engineer.md, frontend-developer.md, qa-engineer.md. See templates/roles/README.md for which role matches which task type.}}

**CONTEXT:**

You are implementing one task from a development plan.
Read and follow the coding standards in {{PROJECT_INSTRUCTION_FILE — e.g., CLAUDE.md}}.

**TASK:**

{{PASTE THE SPECIFIC TASK BLOCK FROM PLAN.md — including title, role, spec reference, files, acceptance criteria, and test command}}

**SPEC REFERENCE:**

Read `workflow/spec/SPEC.md` section: {{RELEVANT_SECTION_NAME}}

**INSTRUCTIONS:**

1. **Branch isolation (mandatory).** Before writing any code, create a git branch for this task:
   ```
   git checkout -b task/{{X.Y}}-{{short-title}}
   ```
   All work for this task MUST happen on this branch. Do NOT work directly on `main`.
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

**README UPDATE:**

If this task adds user-facing functionality (CLI commands, API endpoints, UI features), update the **Usage** section of `README.md` with examples showing how to use what was just built. Skip this for internal/infrastructure tasks.

**WHEN DONE:**

Provide a brief summary:
1. Branch name (e.g., `task/1.1-implement-functions`)
2. What was implemented (1-2 sentences)
3. Files created/modified
4. All check results (pass/fail)
5. Any spec gaps or issues discovered
6. Confirm that `workflow/plan/reviews/task-{{X.Y}}.md` has been created
7. Confirm that `workflow/plan/PROGRESS.md` has been updated

**HUMAN REVIEW PROCESS:**

After you complete the task, the human will review the diff and `workflow/plan/reviews/task-{{X.Y}}.md`.

- If changes are needed, the human will add `*FEEDBACK:*` comments in the review file.
- You should respond with `*AI:*` comments explaining what was changed and why, then re-implement.
- Do not overwrite previous discussion — append new responses below existing conversation.
- When the human is satisfied, they will instruct you to create a PR.

**PR CREATION (on human instruction only):**

Create a pull request with:
- Title: `Task {{X.Y}}: {{Task Title}}`
- Body: what was implemented, which PLAN.md task this addresses, test results, spec gaps found, worktree/branch name
