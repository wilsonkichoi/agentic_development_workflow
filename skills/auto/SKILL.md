---
name: auto
description: "Use to run the full execute-review-fix-verify pipeline automatically with clean context between steps. Orchestrates sequential subagents for unattended execution. Use when someone says 'auto wave', 'auto milestone', 'run full pipeline', 'automated execution', 'hands-free', 'run everything', 'unattended wave', or 'auto run'."
argument-hint: "[wave N | milestone N]"
---

## What This Skill Does

Orchestrates the full execute-review-fix-verify pipeline using sequential subagents with clean context. Each step runs as an independent agent that only knows what's in its prompt and what it reads from disk — preventing bias from prior work. The pipeline is fully unattended and resumes from where it left off if interrupted.

## Modes

- **`auto wave N`** — Runs the full pipeline for a single wave: execute all tasks, review, generate fix plan, apply fixes, verify fixes, then merge the feature branch to main and clean up branches.
- **`auto milestone N`** — Loops over all waves in milestone N (in order). For each wave: runs the full wave pipeline, merges, cleans up, then advances to the next wave. Stops if a wave fails.

## Prompt

### Context Loading

Before spawning any subagent, the orchestrator (you) must build context:

1. Read `workflow/plan/PLAN.md` — find all waves under the target milestone. Determine milestone number M from task numbering (task X.Y belongs to Milestone X). For `auto wave N`, identify all tasks in wave N. For `auto milestone N`, identify all waves and their tasks.
2. Read `workflow/plan/PROGRESS.md` — check current task statuses.
3. Check for existing review artifacts in `workflow/plan/reviews/`:
   - Task review files: `task-X.Y.md`
   - Wave review file: `wave-mM-N.md` (preferred) or `wave-N.md` (legacy)
4. Check git branch state: `git branch` to see which feature/task/fix branches exist.

### Artifact-Based Resume

Check existing artifacts to determine where to start. Check in this order:

**1. Is the wave already merged?**
All tasks in PROGRESS.md are `done` AND no `feature/mM-waveW-*` branch exists → wave is complete. Skip it (milestone mode) or report "already done" (wave mode).

**2. Does a wave review file exist?**
No → start at Step 1 (execute) if task review files are also missing, or Step 2 (review) if task review files exist for all tasks in the wave.

**3. Does the wave review have issues?**
Read the wave review file. Check each `## Task X.Y` section for `### Issues Found`. Count BLOCKER and SUGGESTION entries (ignore NITs).
- Zero BLOCKERs and SUGGESTIONs → skip fix cycle, go to Step 6 (merge).
- Issues exist → continue checking.

**4. Does `### Fix Plan` exist in the wave review?**
No → start at Step 3 (fix-plan).

**5. Does `### Fix Results` exist in the wave review?**
No → start at Step 4 (execute fixes).

**6. Does `### Fix Verification` exist in the wave review?**
No → start at Step 5 (verify-fixes).
Yes → read it. If all issues are marked "Fixed" → go to Step 6 (merge). If any are "Not Fixed" or "Regression" → **STOP and report** (see Failure Handling).

### Pipeline Steps

Run steps sequentially. After each step, verify the expected artifact exists before proceeding.

---

**Step 1 — Execute Wave**

Spawn an independent agent with this prompt:

> You are running the execute step of an automated pipeline for milestone M, wave W.
> Invoke `/agentic-dev:execute wave W`.
> Follow the skill's instructions completely. Execute all tasks in the wave.
> OVERRIDE: Do not stop for human review or approval. Complete all tasks and their task review files.
> When done, confirm which tasks were executed and their status.

**Post-check:** Verify `workflow/plan/reviews/task-X.Y.md` exists for each task in the wave. Verify PROGRESS.md shows those tasks at status `review`. If any task review is missing, **STOP and report**.

---

**Step 2 — Review Wave**

Spawn an independent agent with this prompt:

> You are running the review step of an automated pipeline for milestone M, wave W.
> Invoke `/agentic-dev:review wave W`.
> Follow the skill's instructions completely. Write the review to `workflow/plan/reviews/wave-mM-N.md`.
> OVERRIDE: Do not stop for human review or approval. Complete the full review.
> When done, summarize the issues found (or confirm no issues).

**Post-check:** Read the wave review file. If it exists and has `### Issues Found` sections:
- Count BLOCKERs and SUGGESTIONs across all tasks. If zero → **short-circuit to Step 6**.
- If issues exist → continue to Step 3.

---

**Step 3 — Fix Plan**

Spawn an independent agent with this prompt:

> You are running the fix-plan step of an automated pipeline for milestone M, wave W.
> Invoke `/agentic-dev:review fix-plan wave W`.
> Follow the skill's instructions completely. Generate a fix plan for issues in `workflow/plan/reviews/wave-mM-N.md`.
> OVERRIDE: Do not stop for human review or approval. Complete the fix plan.
> When done, confirm the fix plan was written.

**Post-check:** Read the wave review file. Verify `### Fix Plan` exists under `## Review Discussion`. If missing, **STOP and report**.

---

**Step 4 — Execute Fixes**

Spawn an independent agent with this prompt:

> You are running the fix execution step of an automated pipeline for milestone M, wave W.
> Invoke `/agentic-dev:execute fix the issues according to workflow/plan/reviews/wave-mM-N.md`.
> Follow the skill's instructions completely. Apply all fixes from the fix plan.
> OVERRIDE: Do not stop for human review or approval. Apply all fixes and report results.
> When done, confirm which fixes were applied.

**Post-check:** Read the wave review file. Verify `### Fix Results` exists under `## Review Discussion`. If missing, **STOP and report**.

---

**Step 5 — Verify Fixes**

Spawn an independent agent with this prompt:

> You are running the verification step of an automated pipeline for milestone M, wave W.
> Invoke `/agentic-dev:review verify-fixes wave W`.
> Follow the skill's instructions completely. Verify all fixes in `workflow/plan/reviews/wave-mM-N.md`.
> OVERRIDE: Do not stop for human review or approval. Complete the full verification.
> When done, state clearly how many issues were resolved vs unresolved.

**Post-check:** Read the wave review file. Find `### Fix Verification`. Check each issue's status:
- All marked "Fixed" → proceed to Step 6.
- Any marked "Not Fixed" or "Regression" → **STOP and report** (see Failure Handling).

---

**Step 6 — Merge and Cleanup**

The orchestrator performs this step directly (no subagent needed):

1. **Merge fix branches into feature branch** (if any exist):
   ```
   git checkout feature/mM-waveW-*
   git merge fix/*       # merge each fix branch
   git branch -d fix/*   # delete fix branches
   ```

2. **Merge feature branch to main:**
   ```
   git checkout main
   git merge feature/mM-waveW-short-description
   ```

3. **Clean up branches:**
   ```
   git branch -d feature/mM-waveW-short-description
   ```
   Delete any remaining task branches for this wave.

4. **Verify:** Confirm you are on `main` and the feature branch no longer exists.

If a **merge conflict** occurs at any point, **STOP and report** the conflict. The user must resolve it manually.

**Report:** "Wave W complete. Feature branch merged to main. All branches cleaned up."

---

### Milestone Mode: Wave Loop

For `auto milestone N`:

1. Parse PLAN.md for all `### Wave W:` headings under `## Milestone N`.
2. For each wave (in order):
   a. **Check completion:** All tasks in the wave are `done` in PROGRESS.md AND no `feature/mM-waveW-*` branch exists. If complete, log "Wave W: already complete" and skip.
   b. **Run the full wave pipeline** (Steps 1-6) using artifact-based resume.
   c. **If the wave fails** (unresolved issues, merge conflict, missing artifact) → **STOP the milestone**. Report which wave failed and what went wrong.
   d. **If the wave succeeds** → log "Wave W complete" and advance to next wave.
3. After all waves complete: "Milestone N complete. All waves executed, reviewed, and merged to main."

---

### Failure Handling

When the pipeline stops, report clearly:

```
PIPELINE STOPPED — Wave W, Step N (step-name)

Reason: {{what went wrong}}
Artifact: {{which file to check}}
Next action: {{what the user should do to resolve}}

To resume after resolution, run the same command:
  /agentic-dev:auto wave W
  /agentic-dev:auto milestone N
```

Specific failure cases:
- **Missing artifact after subagent:** The subagent completed but didn't produce the expected file/section. Report which artifact is missing.
- **Unresolved issues after verify-fixes:** List the unresolved issues. The user should fix manually or investigate, then re-run.
- **Merge conflict:** Report the conflict. The user resolves it, then re-runs.
- **Subagent error:** Report the error. The user investigates and re-runs.

**No automatic retries.** The user resolves the issue and re-runs the same command. Artifact-based resume picks up from the right step.

---

## Constraints

- **Fully unattended** — no human gates between steps within a wave pipeline.
- **Clean context per step** — each step is an independent agent. No reasoning leaks between steps.
- **Orchestrator reads, agents write** — the orchestrator checks artifacts between steps but never modifies review files directly.
- **NITs do not block** — only BLOCKERs and SUGGESTIONs trigger the fix cycle.
- **Sequential waves** — milestone mode runs waves in order. No cross-wave parallelism.
- **Direct merge** — uses `git merge` (solo project default). For team PR workflows, run wave mode and handle PRs manually.
- **Append-only** — same constraint as the review skill for `## Review Discussion` sections.
