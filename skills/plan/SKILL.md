---
name: plan
description: "Use for Phase 3 of the development workflow: task breakdown. Decomposes milestones into atomic tasks grouped into parallel waves with role assignments. Use when someone says 'create plan', 'phase 3', 'task breakdown', 'decompose tasks', 'break down the spec', or after Phase 2 spec is approved."
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 3 (Task Breakdown) of the AI-Assisted Development Workflow. Decomposes each milestone from SPEC.md into atomic, independently executable tasks with acceptance criteria, role assignments, and parallel wave grouping.

## Instructions

Read [template.md](template.md) for the detailed phase template.

**If `workflow/plan/PLAN.md` already exists but `workflow/plan/rfc.md` does not**, the phase was run before the review process was added. Create the RFC file now and ask the human to review before proceeding.

Key points:
1. Read `workflow/spec/SPEC.md` and `workflow/spec/HANDOFF.md`
2. Structure as **Milestone → Wave → Task**
3. Each task: single concern, independently verifiable, clearly bounded
4. **Separate test tasks from implementation tasks** — different sessions, no shared context
5. Assign roles from available agents (see `/agents`)
6. A **wave** is a set of tasks with no unresolved inter-dependencies that can execute concurrently
7. Create `workflow/plan/rfc.md` with a summary of task decomposition rationale and low-confidence areas
8. **STOP and ask the human to review. Do NOT proceed to Phase 4 or suggest next steps until the human explicitly approves.** If `*FEEDBACK:*` is given in the RFC file, respond with `*AI:*`, revise PLAN.md/PROGRESS.md, and wait again.

## Parallel wave criteria

Tasks may share a wave ONLY if ALL hold:
- Different functional components
- Zero relation OR frozen API contract in SPEC.md
- No shared mutable state

## Output

- `workflow/plan/PLAN.md` (Milestone → Wave → Task)
- `workflow/plan/PROGRESS.md` (status tracker)
