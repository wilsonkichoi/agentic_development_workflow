---
name: review
description: "Use for reviewing completed work: code review, spec compliance, fix plan validation, and fix verification. Supports task-level and wave-level scope. Use when someone says 'review wave', 'review task', 'verify fixes', 'check fix plan', 'code review', 'validate fixes', or after execute phase completes."
argument-hint: "[wave N | task X.Y | fix-plan wave N | fix-plan task X.Y | verify-fixes wave N | verify-fixes task X.Y | full wave N | full task X.Y]"
---

## What This Skill Does

Reviews completed Phase 4 work for code quality, spec compliance, and correctness. Produces durable review files that any AI session — in any tool — can read and continue from. The review file is the connective tissue between sessions, not the user's clipboard.

## Review Modes

- **`review wave N`** / **`review task X.Y`** — Code review, spec compliance, acceptance criteria, severity-ranked issues
- **`fix-plan wave N`** / **`fix-plan task X.Y`** — Generate a fix plan from review issues, or validate an existing one (append-only — run multiple times with different AIs)
- **`verify-fixes wave N`** / **`verify-fixes task X.Y`** — Verify actual code changes after fixes were applied
- **`full wave N`** / **`full task X.Y`** — Single-session orchestration: review + generate fix plan + validate via subagent, then STOP

## State Flow

Each mode writes a known section heading. The next mode checks for it as a precondition.

```
review ──writes──> ## Issues Found + ## Summary
                        │
                        ▼ (precondition)
fix-plan ─┬─(no plan)──writes──> ### Fix Plan (under ## Review Discussion)
           └─(plan exists)──writes──> ### Fix Plan Analysis (under ## Review Discussion)
                        │
                        ▼ (human approves, /agentic-dev:execute applies fixes)
                        │  execute writes ──> ### Fix Results
                        │
                        ▼ (precondition)
verify-fixes ──writes──> ### Fix Verification (under ## Review Discussion)
```

## Prompt

**CONTEXT LOADING (all modes):**

Before doing anything, read these files to build context:
1. `workflow/plan/PLAN.md` — resolve "wave N" or "task X.Y" to specific tasks, acceptance criteria, and file lists. Determine the milestone number M from the task numbering (task X.Y belongs to Milestone X).
2. `workflow/spec/SPEC.md` — for spec compliance checking
3. `workflow/spec/HANDOFF.md` — for milestone-level acceptance criteria
4. `workflow/plan/PROGRESS.md` — for task status context
5. Relevant `workflow/plan/reviews/task-X.Y.md` files — for each task in scope. Each task review file has a `**Branch:**` field in Work Summary that records the task branch name and its parent (feature branch or main).
6. **Wave review file** — look for the existing wave review file. The naming convention may vary:
   - `workflow/plan/reviews/wave-mM-N.md` (milestone-qualified, e.g., `wave-m2-1.md` for milestone 2, wave 1) — **preferred format**
   - `workflow/plan/reviews/wave-N.md` (legacy format for single-milestone projects)
   - Check for both patterns. Use whichever exists. When creating a new wave review file, use the milestone-qualified format: `wave-mM-N.md`.
7. The actual source code files listed in each task's "Files created/modified"
8. **Branch and diffs:** Read the `**Branch:**` field from each task review file to identify the correct branches. Then:
   - If task branches still exist: `git diff <parent-branch>..task/X.Y-*`
   - If task branches were merged into a feature branch: check out the feature branch and review the code there
   - If reviewing fixes: the `### Fix Results` section has a `**Branch:**` field — use that branch

Read {{PROJECT_INSTRUCTION_FILE — e.g., CLAUDE.md}} for coding standards.

---

### Mode: `review wave N` / `review task X.Y`

**Role:** Activate `code-reviewer` agent.

**Precondition:** Task review files must exist for the tasks being reviewed (produced by the execute skill). If `workflow/plan/reviews/task-X.Y.md` does not exist for a task in scope, note "Task X.Y: not yet executed" and skip it.

**Pre-reviewed tasks:** If a task already has a `## Code Review` section in its `task-X.Y.md`, note "Task X.Y: reviewed separately — see task-X.Y.md" and focus on unreviewed tasks + cross-task interactions only.

**Instructions:**
1. For each task in scope, build an acceptance criteria checklist (PASS/FAIL table) from PLAN.md.
2. Cross-reference the implementation against SPEC.md. Build a spec alignment table.
3. Read the actual source files and git diffs. Look for: correctness issues, security vulnerabilities, spec deviations, workarounds, code that is hard to understand or maintain.
4. Produce severity-ranked issues. Use these severity levels:
   - **BLOCKER** — Security vulnerabilities, data corruption risks, breaking changes, spec violations that break functionality
   - **SUGGESTION** — Validation gaps, spec deviations that don't break functionality, unclear logic, missing error handling, performance concerns
   - **NIT** — Style inconsistencies, naming, minor improvements (low priority)
5. For each issue: cite the specific `file:line`, explain the problem, explain *why* it matters, and suggest a fix.
6. Include a "Things Done Well" callout — acknowledge strong implementations.
7. Write a summary table: `| # | Severity | Task | Issue | Action |`

**Output target:**
- **Wave review** → create/update `workflow/plan/reviews/wave-mM-N.md` (e.g., `wave-m2-1.md` for milestone 2, wave 1). For single-milestone projects, `wave-N.md` is acceptable.
- **Task review** → append `## Code Review` section to existing `workflow/plan/reviews/task-X.Y.md`

**Wave review format:**
```markdown
# Wave N Review: {{Task Titles}}

Reviewed: {{DATE}}
Reviewer: {{AI model/tool}}
Cross-referenced: SPEC.md §{{sections}}, HANDOFF.md

## Task X.Y: {{Title}}

### Acceptance Criteria Checklist

| Criteria | Status | Notes |
|----------|--------|-------|

### Issues Found

**Issue 1 — SEVERITY: {{title}}**

`{{file:line}}` — {{description}}

{{why it matters, suggested fix}}

## Cross-Reference: Spec Alignment

| Spec Requirement | Implementation | Verdict |
|-----------------|---------------|---------|

## Things Done Well

{{acknowledge strong implementations}}

## Summary

| # | Severity | Task | Issue | Action |
|---|----------|------|-------|--------|

**Overall verdict:** {{1-2 sentence assessment}}

## Review Discussion

```

**Task review format (appended to task-X.Y.md):**
```markdown
## Code Review

Reviewed: {{DATE}}
Reviewer: {{AI model/tool}}

### Acceptance Criteria Checklist

| Criteria | Status | Notes |
|----------|--------|-------|

### Spec Alignment

| Spec Requirement | Implementation | Verdict |
|-----------------|---------------|---------|

### Issues Found

**Issue 1 — SEVERITY: {{title}}**

`{{file:line}}` — {{description}}

### Summary

| # | Severity | Issue | Action |
|---|----------|-------|--------|

### Review Discussion

```

**If no issues found:** Produce the full review with checklists and spec alignment table. State "No issues found" in the Summary with a brief note on what was checked.

**If no issues found — post-review actions:**
- Update task status to `done` in `workflow/plan/PROGRESS.md` for each reviewed task.
- Tell the user: "Review complete — no issues found. Task(s) X.Y are marked `done`."
- Offer next steps based on context:
  - **During wave execution (feature branch exists):** "Feature branch `feature/mM-waveW-short-description` is ready to merge to `main`."
    - **Direct merge (solo):** `git checkout main && git merge feature/mM-waveW-short-description && git branch -d feature/mM-waveW-short-description`
    - **Create PR (team):** `gh pr create` from the feature branch to `main`
  - **Single task (no feature branch):** "Branch `task/X.Y-short-title` is ready to merge."
    - **Direct merge (solo):** `git checkout main && git merge task/X.Y-short-title && git branch -d task/X.Y-short-title`
    - **Create PR (team):** instruct the execute skill or run `gh pr create`

---

### Mode: `fix-plan wave N` / `fix-plan task X.Y`

**Role:** Activate `software-architect` agent.

**Precondition:** Identify the **primary review file** and check it for issues:
- **`fix-plan wave N`**: The primary source is the **wave review file** (`workflow/plan/reviews/wave-mM-N.md` or `wave-N.md` — see Context Loading step 6 for naming). Check it for `### Issues Found` sections (one per `## Task X.Y` heading in the wave review). If the wave review file does not exist or has no `### Issues Found` sections → STOP and tell the user: "No wave review found — run `/agentic-dev:review wave N` first."
- **`fix-plan task X.Y`**: The primary source is `workflow/plan/reviews/task-X.Y.md`. Check for `### Issues Found` (under `## Code Review`). If not found → STOP and tell the user: "No task review found — run `/agentic-dev:review task X.Y` first."

The wave review file is the authoritative source for wave-scoped issues. Task review files (`task-X.Y.md`) provide supplementary context — key decisions, obstacles, implementation details that the wave review may summarize. Read both, but look for `### Issues Found` in the wave review file, not in task files.

**Branch:** Check `## Review Discussion` in the primary review file for a `### Fix Plan` heading.

- **If `### Fix Plan` NOT found → Generate one:**

  **Phase A — Blind source read (form your own assessment BEFORE reading the review):**
  1. **Skim the review for locations only.** From the primary review file (wave review for wave scope, task review for task scope), extract ONLY: issue numbers, severity levels, and `file:line` references. **Do NOT read the full issue descriptions or suggested fixes yet.** Skip past them.
  2. **Read source code and assess independently.** For each flagged `file:line`, read the surrounding code (±30 lines of context). For each location, write a brief internal note: what the code does, what could go wrong here, and what you would change. **Do this BEFORE reading the review's analysis.**

  **Phase B — Compare and challenge:**
  3. **Now read the full review.** Read the complete issue descriptions and suggested fixes from the primary review file. Also read each `workflow/plan/reviews/task-X.Y.md` for supplementary context (bug tracking, obstacles, key decisions). The **issues to fix come from the primary review file**.
  4. **Compare your independent assessment with the review's.** For each issue: where do you agree? Where do you disagree? Did the review miss something you noticed? Did you miss something the review caught? If you agree with everything, explain specifically what in the source code led you to the same conclusion — "confirmed by reading X" is not sufficient.
  5. **Propose fixes with risk analysis.** For each issue, propose a concrete fix: approach, files to modify. For each fix, state **one risk** — a way it could fail, regress, or need follow-up. If you can't identify a risk after investigation, explain what you checked.
  6. Append under `## Review Discussion` in the review file:
     ```markdown
     ### Fix Plan ({{AI model/tool}} — {{DATE}})

     **Issue 1 ({{title}})**
     - Independent assessment: {{what you found reading the source BEFORE the review — your own characterization}}
     - Review comparison: {{agree/disagree with review's characterization and why}}
     - Fix: {{chosen approach}}
     - Risk: {{one way this fix could fail or introduce a problem}}
     - Files: {{list}}

     **Execution order:** {{ordered steps}}
     **Verification:** {{commands to run after fixes}}
     ```
  7. Tell the user: "Fix plan generated. Review it in {{review_file_path}}. To validate with an independent perspective, run `fix-plan` again (optionally with a different AI). To apply fixes: `/agentic-dev:execute fix the issues according to {{review_file_path}}`"

- **If `### Fix Plan` found → Validate it:**
  1. Read the review file. Find the issues and the proposed fix plan.
  2. For each proposed fix, evaluate:
     - Does it address the root cause, not just the symptom?
     - Does it introduce new issues (regressions, security gaps, spec violations)?
     - Does it violate coding standards or project conventions?
     - Does it conflict with other fixes in the plan?
     - Is the approach fundamentally sound? (Watch for wrong library choices, incorrect API usage, architectural violations.)
  3. Output a per-fix verdict: **approve** or **revise** with specific reasoning.
  4. If revising, propose an alternative approach.
  5. Append under `## Review Discussion` in the review file:
     ```markdown
     ### Fix Plan Analysis ({{AI model/tool}} — {{DATE}})

     **Issue 1 ({{title}}) — Approve**
     Fix approach is correct. {{brief reasoning}}

     **Issue 2 ({{title}}) — Revise**
     The proposed approach is flawed because {{reason}}.
     **Alternative:** {{revised approach}}
     ```

**Append-only:** Multiple AIs can run `fix-plan`. Each appends its own entry. Results accumulate. The user or execute AI synthesizes the feedback.

---

### Mode: `verify-fixes wave N` / `verify-fixes task X.Y`

**Role:** Activate `qa-engineer` agent.

**Precondition:** The review file must contain `### Fix Results` (written by the execute skill after applying fixes). If not → STOP and tell the user: "No fix results found — execute the fixes first using `/agentic-dev:execute`."

**Instructions:**
1. Read the review file. Find all issues from `### Issues Found` and the fix results from `### Fix Results`.
2. **Switch to the fix branch** listed in `### Fix Results` (the `**Branch:**` line). All verification must happen on that branch, not on `main`. If no branch is listed, check `git branch` for branches matching `fix/*` for the relevant task.
3. For each originally reported issue, verify the fix by reading the actual source code (not just the fix description).
4. Run `git diff` to see what changed. Check that the change matches the intended fix.
5. Look for regressions — did fixing one issue break something else?
6. Run verification commands if specified (lint, type check, tests).

**Output:** Append under `## Review Discussion` in the review file:
```markdown
### Fix Verification ({{AI model/tool}} — {{DATE}})

**Issue 1 ({{title}}) — Fixed** ✓
Verified: {{what was checked, evidence}}

**Issue 2 ({{title}}) — Not Fixed**
The fix was applied but {{problem description}}.

**Issue 3 ({{title}}) — Regression**
The fix for Issue 3 broke {{what was broken}}.

**Verification commands:**
- `{{command}}` — PASS/FAIL

**Verdict:** {{N}}/{{total}} issues resolved. {{action needed if any remain}}
```

7. **Post-verification (when all issues are resolved):**
   - Update task status to `done` in `workflow/plan/PROGRESS.md` for each verified task.
   - Tell the user: "All issues verified. Task(s) X.Y are marked `done`."
   - Offer next steps based on context:
     - **During wave execution (feature branch exists):** "Feature branch `feature/mM-waveW-short-description` is ready to merge to `main`."
       - **Direct merge (solo):** `git checkout main && git merge feature/mM-waveW-short-description && git branch -d feature/mM-waveW-short-description`
       - **Create PR (team):** `gh pr create` from the feature branch to `main`
     - **Single task (no feature branch):** "Branch `task/X.Y-short-title` is ready to merge."
       - **Direct merge (solo):** `git checkout main && git merge task/X.Y-short-title && git branch -d task/X.Y-short-title`
       - **Create PR (team):** instruct the execute skill or run `gh pr create`
   - If any issues remain unresolved, do NOT update status. Tell the user which issues need another fix cycle.

---

### Mode: `full wave N` / `full task X.Y`

**Role:** Start as `code-reviewer`, then use subagents for independent validation.

**Instructions:**
1. **Review:** Follow the `review` mode instructions above. Write the full review to the review file.
2. **Generate fix plan:** For each issue found, propose a fix plan. Append under `## Review Discussion`:
   ```markdown
   ### Fix Plan ({{AI model/tool}} — {{DATE}})

   **Issue 1 ({{title}})**
   - Fix: {{approach}}
   - Files: {{list}}

   **Execution order:** {{ordered steps}}
   **Verification:** {{commands to run after fixes}}
   ```
3. **Validate fix plan via subagent:** Spawn an independent agent (software-architect role) to validate the fix plan. The subagent should ONLY read the review file — not your reasoning chain. Pass it this prompt: "Read {{review_file_path}}. Validate the fix plan in `### Fix Plan`. For each proposed fix, evaluate whether it addresses the root cause, introduces new issues, or is fundamentally flawed. Append your analysis as `### Fix Plan Analysis` under `## Review Discussion`."
4. **STOP.** Tell the user:
   - "Review complete. Fix plan generated and independently validated."
   - "Review the fix plan and analyses in {{review_file_path}}."
   - "To apply fixes: `/agentic-dev:execute fix the issues according to {{review_file_path}}`"
   - "After fixes: `/agentic-dev:review verify-fixes wave N`"

Do NOT execute fixes. Do NOT proceed past this point.

---

## Constraints

- **Append-only** for `## Review Discussion` sections. Never overwrite previous entries.
- Every entry in Review Discussion must have a **header with reviewer identifier (model/tool) and date**.
- Reference **specific file:line** for every finding.
- Explain the **"why"** behind each concern — not just what's wrong, but why it matters.
- **Acknowledge strong implementations**, not just problems.
- The review file must be **self-contained** — include all context needed for a different AI session in any tool to continue the review loop.
- When reviewing, review against the **spec and project standards**, not personal preference.
- Do not nitpick code that was not part of the current task scope.
