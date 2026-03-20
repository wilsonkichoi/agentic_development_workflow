---
name: verify
description: "Use for Phase 5 of the development workflow: verification and retrospective. Runs end-to-end testing for a milestone and generates a retrospective document. Use when someone says 'verify milestone', 'phase 5', 'retrospective', 'run verification', or after all tasks in a milestone are complete."
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 5 (Verification & Retrospective) of the AI-Assisted Development Workflow. Runs the full test suite for a completed milestone, generates a retrospective capturing what worked, what didn't, and actionable improvements.

## Instructions

Read [template.md](template.md) for the detailed phase template.

Key points:
1. Read PLAN.md, PROGRESS.md, all task review files in `workflow/plan/reviews/`, and decision records in `workflow/decisions/`
2. Run the full test suite for the milestone
3. If issues found, feed specific failures back to Phase 4 (targeted fix)
4. Generate retrospective covering: summary, what went well, what needed intervention, spec gaps, test separation effectiveness, cost & efficiency, recommendations
5. Create `workflow/retro/review.md` with a summary of the retrospective and low-confidence areas
6. **STOP and ask the human to review. Do NOT suggest merging or next steps until the human explicitly approves.** If `*FEEDBACK:*` is given in the review file, respond with `*AI:*`, revise the retrospective, and wait again.
7. Human confirms merge — PRs for the milestone are merged

## Output

- `workflow/retro/RETRO-{milestone}.md`
- Passing test suite
- Merged PRs (on human instruction)
