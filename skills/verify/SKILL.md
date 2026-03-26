---
name: verify
description: "Use for Phase 5 of the development workflow: verification and retrospective. Runs end-to-end testing for a milestone and generates a retrospective document. Use when someone says 'verify milestone', 'phase 5', 'retrospective', 'run verification', or after all tasks in a milestone are complete."
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 5 (Verification & Retrospective) of the AI-Assisted Development Workflow.

## Important

**If a retrospective already exists but `workflow/retro/review.md` does not**, the phase was run before the review process was added. Create the review file now and ask the human to review before proceeding.

## Prompt

**INPUTS:**

Read the following files:
- `workflow/plan/PLAN.md`
- `workflow/plan/PROGRESS.md`
- `workflow/spec/SPEC.md` (for reference)
- All files in `workflow/plan/reviews/` (task review files for this milestone)
- All files in `workflow/decisions/` (decision records)

Additional context:
- Git diff or changelog: {{PASTE_OR_REFERENCE — e.g., `git log --oneline main..feature-branch`}}
- Test results: {{PASTE_OR_REFERENCE — e.g., output of pytest}}
- Any manual testing notes: {{YOUR_OBSERVATIONS}}

**ROLE:**

If executing a standard milestone verification, use `qa-engineer` to test and `code-reviewer` to analyze quality.
If generating the final retrospective, use `senior-pm` or `software-architect` to capture process and architecture learnings, or use the default role if not specified.

**INSTRUCTIONS:**

**Step 1 — Verify the milestone:**

1. Run the full test suite for the milestone.
2. If the project has a local deployment target, deploy locally and manually test critical user paths. Note any issues.
3. If issues are found, feed specific failures back to Phase 4 as targeted fixes — do not re-plan.

**Step 2 — Review README.md:**

Check that README.md is complete and accurate for the current milestone. Ensure the Overview, Getting Started, Usage, and Architecture sections reflect what was actually built. Fix any placeholders that should have been filled in during earlier phases.

**Step 3 — Generate the retrospective** with these sections:

1. **Summary**
   - What was built (1-2 sentences)
   - Milestone: {{MILESTONE_NAME}}
   - Tasks completed: {{N}} / {{TOTAL}}
   - Waves completed: {{N}}

2. **What Went Well**
   - Tasks that completed cleanly on first attempt
   - Spec sections that were clear and complete
   - Patterns or approaches that worked effectively
   - Decisions (from `workflow/decisions/`) that proved correct

3. **What Needed Human Intervention**
   - Tasks that failed or required multiple review cycles (reference specific task review files)
   - Ambiguous or incomplete spec sections
   - Tool/context issues encountered
   - Decisions that had to be revised

4. **Spec Gaps Discovered**
   - Requirements missing from SPEC.md
   - Edge cases not covered
   - Integration points that were underspecified
   - (Pull from PROGRESS.md "Spec Gaps Discovered" section and individual task review files)

5. **Test Separation Effectiveness**
   - Did separately-authored tests catch issues the implementation session missed?
   - Were test tasks appropriately scoped?
   - Any cases where inline testing would have been sufficient?

6. **Cost & Efficiency**
   - Models used per phase
   - Phases that felt over/under-invested
   - Context issues (did any task hit context limits?)
   - Role assignments — were the right roles used for each task?

7. **Recommendations for Next Milestone**
   - Specific changes to prompts or role definitions
   - Changes to spec detail level
   - Changes to task granularity (too big? too small?)
   - Workflow improvements
   - Decision records that should inform the next milestone's spec

**OUTPUT FORMAT:**

Markdown file for saving as `workflow/retro/RETRO-{{MILESTONE_NAME}}.md`

**CONSTRAINTS:**

- Be specific. Bad: "Some tasks had issues." Good: "Task 2.3 failed because the API contract didn't specify error response format for 404s."
- Focus on actionable improvements, not general observations.
- Reference specific task review files and decision records by name.
- Keep it under 500 words. This should be a quick reference, not an essay.

**HUMAN REVIEW PROCESS:**

After you produce the retrospective, create `workflow/retro/review.md` with a brief summary of the retrospective and any areas where you had low confidence.

Then **STOP and ask the human to review.** Do NOT proceed or suggest next steps.

The human will review the retrospective and may add `*FEEDBACK:*` comments in the review file.

- Respond with `*AI:*` comments explaining what was changed and why, then update the retrospective accordingly.
- Do not overwrite previous discussion — append new responses below existing conversation.
- The phase is complete only when the human explicitly approves. Milestone PRs may then be merged. Do NOT merge until told.
