---
name: plan
description: "Use for Phase 3 of the development workflow: task breakdown. Decomposes milestones into atomic tasks grouped into parallel waves with role assignments. Use when someone says 'create plan', 'phase 3', 'task breakdown', 'decompose tasks', 'break down the spec', or after Phase 2 spec is approved."
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 3 (Task Breakdown) of the AI-Assisted Development Workflow.

## Important

**If `workflow/plan/PLAN.md` already exists but `workflow/plan/rfc.md` does not**, the phase was run before the review process was added. Create the RFC file now and ask the human to review before proceeding.

## Prompt

**INPUTS:**

Read the following files:
- `workflow/spec/SPEC.md`
- `workflow/spec/HANDOFF.md`

**INSTRUCTIONS:**

Decompose each milestone from SPEC.md into atomic tasks. Structure the plan as Milestone → Wave → Task.

**Task requirements:**

Each task must:

1. Be a **single concern** — one feature, one component, one integration.
2. Be **independently verifiable** — testable without mocking half the system.
3. Be **clearly bounded** — describable in 2-3 sentences.
4. Reference a specific section of SPEC.md.
5. List the files to create or modify.
6. Have testable acceptance criteria (specific commands or assertions, not subjective assessments).
7. Declare dependencies on other tasks (or "none").
8. Specify the recommended **agent role** for execution. Choose from:
   - `backend-engineer` — API endpoints, service logic, database operations
   - `frontend-developer` — UI components, styling, client-side logic
   - `data-engineer` — data pipelines, ETL, schema migrations
   - `devops-engineer` — CI/CD, infrastructure, deployment
   - `security-engineer` — auth, encryption, security hardening
   - `qa-engineer` — test tasks
   - `senior-engineer` — complex cross-cutting tasks
   - `senior-pm` — project management, risk analysis, task reprioritization

**Task scope guidance:**

- If a task produces >500 lines of net new code, verify it's truly a single concern. If it IS a single concern, keep it as one task with clear internal milestones.
- If a task touches more than 3-4 files, consider breaking it down further.

**Test task separation:**

For each feature implementation task, create a **separate test task** to be executed in a different session. The test author sees only: the spec, the public interface (function signatures / API endpoints), and the acceptance criteria — NOT the implementation code. This prevents the AI from writing tests that match its implementation rather than testing the contract.

For trivially simple tasks (e.g., health check endpoint, static config), the human may approve combining implementation and tests in one task. Mark these with `**Test: inline**` instead of a separate test task.

**Wave grouping:**

Group tasks into **waves**. A wave is a set of tasks with no unresolved inter-dependencies that can execute concurrently.

- **Wave 1:** Tasks with no dependencies.
- **Wave 2:** Tasks that depend only on Wave 1 completions.
- **Wave N+1:** Tasks that depend only on Wave N (or earlier) completions.

**Parallel execution criteria** — tasks may be in the same wave ONLY if ALL of these hold:

- They belong to **different functional components**.
- They have either **zero relation** OR a clear API/library contract that is **defined and frozen in SPEC.md**.
- They do NOT **share mutable state** (same database table, same config file, same state store).

**OUTPUT FORMAT:**

Generate two files:

**`workflow/plan/PLAN.md`** with this structure:

```markdown
# Implementation Plan

## Milestone 1: {{Milestone Title}}

### Wave 1: {{Wave Title}}

#### [ ] Task 1.1: {{Title}}
- **Role:** {{agent role — e.g., backend-engineer, frontend-developer, qa-engineer}}
- **Depends on:** none
- **Spec reference:** SPEC.md >> {{Section Name}}
- **Files:** {{list of files to create/modify}}
- **Acceptance criteria:**
  - {{criterion 1 — must be verifiable by running a command}}
  - {{criterion 2}}
- **Test command:** `{{command to verify}}`

#### [ ] Task 1.2: {{Title}} [TEST]
- **Role:** qa-engineer
- **Depends on:** 1.1
- **Spec reference:** SPEC.md >> {{Section Name}}
- **Files:** {{test files}}
- **Test scope:** Tests spec contract for Task 1.1. Do NOT read implementation.
- **Acceptance criteria:**
  - {{criterion 1}}
- **Test command:** `{{command to verify}}`

### Wave 2: {{Wave Title}}

#### [ ] Task 2.1: {{Title}}
- **Role:** {{agent role}}
- **Depends on:** 1.1, 1.3
...

## Milestone 2: {{Milestone Title}}
...
```

**`workflow/plan/PROGRESS.md`** with this structure:

```markdown
# Implementation Progress

Last updated: {{DATE}}

## Milestone 1: {{Milestone Title}}

| Task | Title | Role | Status | Review | Notes |
|------|-------|------|--------|--------|-------|
| 1.1  | ...   | backend-engineer | pending | | |
| 1.2  | ...   | qa-engineer | pending | | |
| 2.1  | ...   | frontend-developer | pending | | |

## Spec Gaps Discovered
(none yet)

## Blocked Items
(none yet)
```

**CONSTRAINTS:**

- Tasks must be atomic (single concern, independently verifiable, clearly bounded).
- Acceptance criteria must be machine-verifiable (test commands, linter passes — not "code looks clean").
- Do not include deployment or documentation tasks unless the spec explicitly requires them.
- Order waves by dependency, not by difficulty or perceived importance.
- Every feature implementation task must have a corresponding test task in a later or same wave (unless marked inline by human approval).
- Target 5-15 tasks per milestone. If you have more than 20, the milestone may need to be split.
- If a decomposition decision involves 2+ viable approaches (e.g., wave grouping, task boundaries), create a decision record in `workflow/decisions/DR-NNN-title.md` and update `workflow/decisions/README.md`. Structure the record with: Phase, Date, Status, Context, Options Considered, Decision, and Consequences.

**HUMAN REVIEW PROCESS:**

After you produce PLAN.md and PROGRESS.md, create `workflow/plan/rfc.md` with a brief summary of task decomposition rationale, wave grouping decisions, and any areas where you had low confidence.

Then **STOP and ask the human to review.** Do NOT proceed to the next phase or suggest next steps.

The human will review PLAN.md and may add `*FEEDBACK:*` comments in the review file.

- Respond with `*AI:*` comments explaining what was changed and why, then update the relevant document(s) accordingly.
- Do not overwrite previous discussion — append new responses below existing conversation.
- The phase is complete only when the human explicitly approves. Do NOT move to Phase 4 until told.
