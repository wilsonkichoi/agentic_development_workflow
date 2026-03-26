# Temperature Converter — Example Walkthrough

A step-by-step tutorial showing how to build a simple app using the workflow. The app is trivial on purpose — the focus is on the workflow structure, not the code complexity.

Each `workflow/` subdirectory contains the artifact produced at that phase. Follow the steps below to reproduce this from scratch, or read through to understand what each phase does.

## Step 0: Setup

Initialize the project and write your requirements.

```
# From parent directory
/agentic-dev:init-project ./temperature-converter

# Or if already inside the project directory
/agentic-dev:init-project .
```

Then write your requirements in `workflow/research/manual/requirements.md`. This is human input — what you want to build, in plain language. See [`workflow/research/manual/requirements.md`](workflow/research/manual/requirements.md) for what we wrote.

---

## Step 1: Research (Phase 1)

The AI reads your manual research and performs its own deep research to fill gaps.

```
/agentic-dev:research
```

The skill reads materials from `workflow/research/manual/`, performs web search and cross-referencing, and produces a unified research synthesis. See [`skills/research/SKILL.md`](../../skills/research/SKILL.md) for the full prompt.

**Review gate:** Read `workflow/research/final/research.md`. Confirm business requirements and constraints are captured correctly. Check that no resources were silently skipped.

**Expected output:** [`workflow/research/final/research.md`](workflow/research/final/research.md)

---

## Step 2: Specification (Phase 2)

The AI generates architecture specs. Use plan/read-only mode — no code should be generated.

```
/agentic-dev:spec
```

The skill asks clarifying questions, then generates SPEC.md (milestones, architecture, schemas, API contracts) and HANDOFF.md (index, execution sequence, acceptance criteria). See [`skills/spec/SKILL.md`](../../skills/spec/SKILL.md) for the full prompt.

For this example, the AI's clarifying questions were straightforward (single file vs package, validation scope, etc.) and we confirmed the simplest approach.

**Review gate:** Read SPEC.md and HANDOFF.md line by line. This is the most critical gate — a bad spec cascades into everything downstream.

**Expected output:** [`workflow/spec/SPEC.md`](workflow/spec/SPEC.md), [`workflow/spec/HANDOFF.md`](workflow/spec/HANDOFF.md), [`CLAUDE.md`](CLAUDE.md)

---

## Step 3: Task Breakdown (Phase 3)

The AI decomposes the spec into atomic tasks grouped into parallel waves.

```
/agentic-dev:plan
```

The AI produces two files:
- **PLAN.md** — tasks structured as Milestone > Wave > Task, each with `[ ]` checkbox, role, dependencies, acceptance criteria, and test command
- **PROGRESS.md** — summary table for tracking status during execution

For this example, the AI created 3 tasks in 2 waves:
- Wave 1: Task 1.1 (implement functions) + Task 1.2 (write tests, in separate session)
- Wave 2: Task 1.3 (CLI entry point, depends on 1.1)

**Review gate:** Check that tasks are atomic, acceptance criteria are testable, dependencies make sense, and test tasks are separated from implementation tasks.

**Expected output:** [`workflow/plan/PLAN.md`](workflow/plan/PLAN.md), [`workflow/plan/PROGRESS.md`](workflow/plan/PROGRESS.md)

---

## Step 4: Execution (Phase 4)

Implement one task per session with a fresh context. Start a new session for each task.

```
/agentic-dev:execute
```

The skill finds the next incomplete task, matches it to the appropriate agent role, creates a feature branch, implements the task, runs verification, and produces a task review file. See [`skills/execute/SKILL.md`](../../skills/execute/SKILL.md) for the full prompt.

### Execution order for this example

| Session | Task | Role | Notes |
|---------|------|------|-------|
| 1 | Task 1.1: Implement conversion functions | Backend Engineer | |
| 2 | Task 1.2: Write unit tests | QA Engineer | **Separate session** — must not see implementation |
| 3 | Task 1.3: Implement CLI entry point | Backend Engineer | Depends on 1.1 |

Task 1.2 (tests) runs in a **completely separate session** from Task 1.1 (implementation). The QA agent sees only the spec and public interface, not the implementation code. This prevents tests that match the code rather than testing the contract.

**Review gate (per task):** Review the diff and `workflow/plan/reviews/task-X.Y.md`. Add `*FEEDBACK:*` comments if changes needed. When satisfied, instruct the AI to create a PR.

**Expected output:** [`src/converter.py`](src/converter.py), [`tests/test_converter.py`](tests/test_converter.py), [`workflow/plan/PROGRESS.md`](workflow/plan/PROGRESS.md)

---

## Running the Tests

```bash
cd examples/temperature-converter
uv run --with pytest pytest tests/ -q
```

Expected: 9 tests pass.
