# Temperature Converter — Example Walkthrough

A step-by-step tutorial showing how to build a simple app using the workflow. The app is trivial on purpose — the focus is on the workflow structure, not the code complexity.

Each `workflow/` subdirectory contains the artifact produced at that phase. Follow the steps below to reproduce this from scratch, or read through to understand what each phase does.

## Step 0: Setup

Initialize the project and write your requirements.

**Claude Code plugin:**

```
# From parent directory
/agentic-dev:init-project ./temperature-converter

# Or if already inside the project directory
/agentic-dev:init-project .
```

**Other tools:**

```bash
./agentic_development_workflow/init.sh ./temperature-converter
```

Then write your requirements in `workflow/research/manual/requirements.md`. This is human input — what you want to build, in plain language. See [`workflow/research/manual/requirements.md`](workflow/research/manual/requirements.md) for what we wrote.

---

## Step 1: Research (Phase 1)

The AI reads your manual research and performs its own deep research to fill gaps.

**Claude Code plugin:**

```
/agentic-dev:research
```

**Other tools** — copy this prompt (from `templates/phases/01-research.md` with placeholders filled in):

```
CONTEXT:

- Project: Temperature Converter
- Description: CLI tool that converts between Celsius and Fahrenheit
- Business Objective: Provide a simple command-line temperature conversion utility
- Target Users: Developers who need quick temperature conversions
- Budget/Timeline Constraints: None — minimal scope, single session

RESEARCH INPUTS:

Read all files in workflow/research/manual/. These are materials gathered during
human manual research and may include business objectives, high-level design
intent, external references, API docs, competitor analysis, stakeholder
conversations, and constraints.

INSTRUCTIONS:

You are performing deep research to complement the human's manual research.
Do not merely summarize — add value by:

1. Cross-reference the manual research materials against each other. Identify
   contradictions, gaps, and unstated assumptions.
2. Expand coverage through web search, codebase analysis, and exploration of
   adjacent patterns. Look for:
   - Alternative architectures or approaches the human may not have considered
   - Edge cases, rate limits, scaling considerations for referenced APIs/services
   - Competing products and how they solve similar problems
   - Known pitfalls with the technologies or patterns mentioned
3. Synthesize everything (human findings + your findings) into a unified
   research document.

Produce the output with these sections:

1. Business Requirements — prioritized (must-have vs nice-to-have).
2. Technical Constraints
3. Reference Architectures
4. External Dependencies
5. AI Research Additions — clearly distinguish what is new.
6. Open Questions
7. Recommended Tech Stack — with brief justification.
8. Inaccessible Resources

OUTPUT FORMAT:

Save as workflow/research/final/research.md. Place any processed reference
materials in workflow/research/final/references/.
Use headings, bullet points, and tables. Keep it scannable.

CONSTRAINTS:

- Do NOT make architecture decisions. This is research, not design.
- If information is missing, list it under "Open Questions" rather than guessing.
- Cite sources where possible.
- If you cannot access a URL or resource, list it under "Inaccessible Resources".
  NEVER silently skip a resource.
```

**Review gate:** Read `workflow/research/final/research.md`. Confirm business requirements and constraints are captured correctly. Check that no resources were silently skipped.

**Expected output:** [`workflow/research/final/research.md`](workflow/research/final/research.md)

---

## Step 2: Specification (Phase 2)

The AI generates architecture specs. Use plan/read-only mode — no code should be generated.

**Claude Code plugin:**

```
/agentic-dev:spec
```

**Other tools** — copy this prompt (from `templates/phases/02-specification.md` with placeholders filled in):

```
ROLE:

You are a software architect. You will generate specifications only — no
implementation code.

See templates/roles/software-architect.md for detailed role definition.

(No additional review roles needed — this is a simple project.)

INPUTS:

Read the following files:
- workflow/research/final/research.md
- All files in workflow/research/final/references/

INSTRUCTIONS:

Step 1 — Clarify first.

Ask me clarifying questions until you fully understand the requirements. Cover:
- Ambiguities in the business requirements
- Trade-offs that need a decision (e.g., consistency vs availability, build vs buy)
- Missing information you need to make architecture decisions
- The appropriate level of system decomposition for the project's situation

Do not proceed to Step 2 until I explicitly confirm.

Step 2 — Generate SPEC.md containing:

- Milestones — coherent, deployable increments ordered by dependency and value.
- System Architecture — components, integration points, tech choices with justification.
- Architecture Diagrams — text-based (Mermaid or DOT).
- Database Schema — SQL notation (if applicable).
- API Contracts — OpenAPI-style (if applicable).
- Coding Standards — naming, structure, patterns, error handling.
- Non-Functional Requirements — performance, security, accessibility.
- Deployment Architecture — environments, CI/CD, infra (if applicable).
- Negative Requirements — what the system is NOT.

Step 3 — Generate HANDOFF.md containing:

- Document Index — location and purpose of every spec document.
- Milestone Ordering — which milestones first and why.
- Execution Sequence — dependency graph in text form.
- Acceptance Criteria — how we know each milestone is complete.
- Known Risks — technical risks and mitigations.

Step 4 — Update CLAUDE.md with:
- Architecture summary (5-10 lines max)
- Build and test commands
- Links to workflow/spec/SPEC.md and workflow/spec/HANDOFF.md

OUTPUT FORMAT:

Two separate markdown documents:
1. workflow/spec/SPEC.md
2. workflow/spec/HANDOFF.md

Plus a brief update to the project instruction file.

CONSTRAINTS:

- No implementation code in either document.
- All schemas use standard notation (SQL for DB, OpenAPI-style for APIs).
- Diagrams use text-based formats only (Mermaid or DOT).
- Flag ambiguities — do NOT resolve by guessing.
- If research has gaps, list them explicitly.
```

For this example, the AI's clarifying questions were straightforward (single file vs package, validation scope, etc.) and we confirmed the simplest approach.

**Review gate:** Read SPEC.md and HANDOFF.md line by line. This is the most critical gate — a bad spec cascades into everything downstream.

**Expected output:** [`workflow/spec/SPEC.md`](workflow/spec/SPEC.md), [`workflow/spec/HANDOFF.md`](workflow/spec/HANDOFF.md), [`CLAUDE.md`](CLAUDE.md)

---

## Step 3: Task Breakdown (Phase 3)

The AI decomposes the spec into atomic tasks grouped into parallel waves.

**Claude Code plugin:**

```
/agentic-dev:plan
```

**Other tools** — copy the prompt from `templates/phases/03-task-breakdown.md` and paste it. No placeholders to fill — the template reads SPEC.md and HANDOFF.md directly.

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

**Claude Code plugin:**

```
/agentic-dev:execute
```

**Other tools** — for each task, copy the prompt from `templates/phases/04-execution.md` and fill in the placeholders. Here's what Task 1.1 looks like filled in:

```
ROLE:

Read templates/roles/backend-engineer.md and adopt this role.

CONTEXT:

You are implementing one task from a development plan.
Read and follow the coding standards in CLAUDE.md.

TASK:

[x] Task 1.1: Implement conversion functions
- Role: Backend Engineer
- Depends on: none
- Spec reference: SPEC.md >> API Contracts
- Files: src/converter.py
- Acceptance criteria:
  - celsius_to_fahrenheit(0) returns 32.0
  - celsius_to_fahrenheit(100) returns 212.0
  - fahrenheit_to_celsius(32) returns 0.0
  - fahrenheit_to_celsius(212) returns 100.0
  - celsius_to_fahrenheit(-40) returns -40.0
- Test command: uv run --with pytest pytest tests/ -q

SPEC REFERENCE:

Read workflow/spec/SPEC.md section: API Contracts

INSTRUCTIONS:

1. Implement the task exactly as specified.
2. After implementation, run these checks:
   - Tests: uv run --with pytest pytest tests/ -q
   - Acceptance: verify functions return correct values
3. If any check fails, fix the issues and re-run.
4. Create a task review file at workflow/plan/reviews/task-1.1.md
5. Update progress tracking:
   - Mark the task checkbox as [x] in workflow/plan/PLAN.md
   - Set this task's status to "review" in workflow/plan/PROGRESS.md
```

(The full template also includes the debugging framework, constraints, and human review process — see `templates/phases/04-execution.md` for the complete version.)

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
