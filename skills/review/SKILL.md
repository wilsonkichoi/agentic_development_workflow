---
name: review
description: "Use for reviewing completed work: code review, spec compliance, fix plan validation, and fix verification. Supports task-level and wave-level scope. Use when someone says 'review wave', 'review task', 'verify fixes', 'check fix plan', 'code review', 'validate fixes', or after execute phase completes."
argument-hint: "[wave N | task X.Y | fix-plan wave N | fix-plan task X.Y | verify-fixes wave N | verify-fixes task X.Y | full wave N | full task X.Y]"
disable-model-invocation: true
---

## What This Skill Does

Reviews completed Phase 4 work for code quality, spec compliance, and correctness. Produces durable review files that any AI session — in any tool — can read and continue from. The review file is the connective tissue between sessions, not the user's clipboard.

## Review Modes

- **`review wave N`** / **`review task X.Y`** — Code review, spec compliance, acceptance criteria, severity-ranked issues
- **`fix-plan wave N`** / **`fix-plan task X.Y`** — Validate/challenge an existing fix plan (append-only — run multiple times with different AIs)
- **`verify-fixes wave N`** / **`verify-fixes task X.Y`** — Verify actual code changes after fixes were applied
- **`full wave N`** / **`full task X.Y`** — Single-session orchestration: review + generate fix plan + validate via subagent, then STOP

## State Flow

Each mode writes a known section heading. The next mode checks for it as a precondition.

```
review ──writes──> ## Issues Found + ## Summary
                        │
                        ▼ (precondition)
fix-plan ──writes──> ### Fix Plan Analysis (under ## Review Discussion)
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
1. `workflow/plan/PLAN.md` — resolve "wave N" or "task X.Y" to specific tasks, acceptance criteria, and file lists
2. `workflow/spec/SPEC.md` — for spec compliance checking
3. `workflow/spec/HANDOFF.md` — for milestone-level acceptance criteria
4. `workflow/plan/PROGRESS.md` — for task status context
5. Relevant `workflow/plan/reviews/task-X.Y.md` files — for each task in scope
6. Existing `workflow/plan/reviews/wave-N.md` — if continuing a previous review
7. The actual source code files listed in each task's "Files created/modified"
8. Git diffs: `git diff main..task/X.Y-*` for each task branch in scope

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
- **Wave review** → create/update `workflow/plan/reviews/wave-N.md`
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

---

### Mode: `fix-plan wave N` / `fix-plan task X.Y`

**Role:** Activate `software-architect` agent (different perspective from code-reviewer).

**Precondition:** The review file must contain `## Issues Found` (wave) or `### Issues Found` (task). If not → STOP and tell the user: "No review found — run `/agentic-dev:review wave N` or `/agentic-dev:review task X.Y` first."

**Also check:** A fix plan must exist in `## Review Discussion` (proposed by the execute AI or a previous `full` run). Look for a `### Fix Plan` heading. If not found → STOP and tell the user: "No fix plan found — have the execute AI propose a fix plan first, or run `/agentic-dev:review full` to generate one."

**Instructions:**
1. Read the review file. Find the issues and the proposed fix plan.
2. For each proposed fix, evaluate:
   - Does it address the root cause, not just the symptom?
   - Does it introduce new issues (regressions, security gaps, spec violations)?
   - Does it violate coding standards or project conventions?
   - Does it conflict with other fixes in the plan?
   - Is the approach fundamentally sound? (Watch for wrong library choices, incorrect API usage, architectural violations.)
3. Output a per-fix verdict: **approve** or **revise** with specific reasoning.
4. If revising, propose an alternative approach.

**Output:** Append under `## Review Discussion` in the review file:
```markdown
### Fix Plan Analysis ({{AI model/tool}} — {{DATE}})

**Issue 1 ({{title}}) — Approve**
Fix approach is correct. {{brief reasoning}}

**Issue 2 ({{title}}) — Revise**
The proposed approach is flawed because {{reason}}.
**Alternative:** {{revised approach}}
```

**Append-only:** Multiple AIs can run `fix-plan`. Each appends its own `### Fix Plan Analysis` entry. Results accumulate. The user or execute AI synthesizes the feedback.

---

### Mode: `verify-fixes wave N` / `verify-fixes task X.Y`

**Role:** Activate `qa-engineer` agent.

**Precondition:** The review file must contain `### Fix Results` (written by the execute skill after applying fixes). If not → STOP and tell the user: "No fix results found — execute the fixes first using `/agentic-dev:execute`."

**Instructions:**
1. Read the review file. Find all issues from `## Issues Found` and the fix results from `### Fix Results`.
2. For each originally reported issue, verify the fix by reading the actual source code (not just the fix description).
3. Run `git diff` to see what changed. Check that the change matches the intended fix.
4. Look for regressions — did fixing one issue break something else?
5. Run verification commands if specified (lint, type check, tests).

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
