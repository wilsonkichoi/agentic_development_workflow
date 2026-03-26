---
name: spec
description: "Use for Phase 2 of the development workflow: specification and architecture. Generates SPEC.md (milestones, architecture, schemas, API contracts, diagrams) and HANDOFF.md from research findings. Use when someone says 'create spec', 'phase 2', 'specification phase', 'architecture design', 'write the spec', or after Phase 1 research is approved."
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 2 (Specification & Architecture) of the AI-Assisted Development Workflow.

## Important

- Use **plan/read-only mode**. Do NOT generate implementation code.
- For Claude Code: start with `claude --permission-mode plan --model opus`
- **If `workflow/spec/SPEC.md` already exists but `workflow/spec/rfc.md` does not**, the phase was run before the review process was added. Create the RFC file now and ask the human to review before proceeding.

## Multi-role Review

Default: Software Architect role. For complex projects, run additional review passes in separate sessions using agents:

- `/agents` → `software-architect` (always, default)
- `/agents` → `security-reviewer` (auth, PII, compliance)
- `/agents` → `domain-specialist` (complex business rules)
- `/agents` → `product-reviewer` (user-facing features)

## Prompt

**ROLE:**

You are a software architect. You will generate specifications only — no implementation code.

{{OPTIONAL — For complex projects, additional roles review the spec in separate sessions after initial generation. Complexity triggers:
- Compliance/auth/PII → activate security-reviewer agent
- Complex business rules → activate domain-specialist agent
- User-facing features → activate product-reviewer agent}}

**INPUTS:**

Read the following files:
- `workflow/research/final/research.md`
- All files in `workflow/research/final/references/`
{{- LIST_ANY_ADDITIONAL_FILES}}

**INSTRUCTIONS:**

**Step 1 — Clarify first.**

Ask me clarifying questions until you fully understand the requirements. Cover:
- Ambiguities in the business requirements
- Trade-offs that need a decision (e.g., consistency vs availability, build vs buy)
- Missing information you need to make architecture decisions
- The appropriate level of system decomposition for the project's situation (POC vs enterprise-ready, team size, compliance needs)

Do not proceed to Step 2 until I explicitly confirm.

**Step 2 — Generate SPEC.md** containing:

- **Milestones** — Define coherent, deployable increments of the system. Each milestone delivers a meaningful capability. Order by dependency and business value. Example: "Milestone 1: User Authentication — signup, login, token refresh, password reset."
- **System Architecture** — Components, integration points, technology choices with justification. Justify the level of decomposition (monolith vs modular monolith vs microservices) based on the specific project constraints. Different functional components should be maintainable independently with clear API contracts.
- **Architecture Diagrams** — Use text-based formats (Mermaid or DOT) for: system architecture diagram, data flow diagram, sequence diagrams for critical flows.
- **Database Schema** — Tables, columns, types, relationships, constraints, indexes. Use SQL notation.
- **API Contracts** — Endpoints, methods, request/response shapes, authentication, error codes. Use OpenAPI-style notation. Contracts between functional components must be explicit and detailed enough for independent implementation.
- **Development Environment Setup** — How to bootstrap the project from scratch: package manager and config file (e.g., pyproject.toml, package.json, Cargo.toml), dependency installation command, module/import structure (how source files are resolved), test runner configuration, and any other scaffolding needed before code can be written and tested. This section should be complete enough that Phase 4 can set up and verify the environment as its first task.
- **Coding Standards** — Naming conventions, file/folder structure, patterns to follow, patterns to avoid, error handling approach.
- **Non-Functional Requirements** — Performance targets (latency, throughput), security requirements, accessibility, scalability approach.
- **Deployment Architecture** — Environments (dev/staging/prod), CI/CD pipeline, infrastructure, monitoring, alerting.
- **Negative Requirements** — What the system is NOT. Explicitly state out-of-scope features, non-goals, and constraints to prevent scope creep. Example: "This is a POC — no horizontal scaling, no multi-tenancy, no audit logging."

**Step 3 — Generate HANDOFF.md** containing:

- **Document Index** — Location and purpose of every spec document.
- **Milestone Ordering** — Which milestones must be completed first and why.
- **Execution Sequence** — What must be built first within each milestone. Dependency graph in text form.
- **Acceptance Criteria** — How we know each milestone (and the overall system) is complete and correct.
- **Known Risks** — Technical risks and mitigation strategies.

**Step 4 — Update the project instruction file** (CLAUDE.md or equivalent) with:
- Architecture summary (5-10 lines max)
- Build and test commands
- Links to `workflow/spec/SPEC.md` and `workflow/spec/HANDOFF.md`

**Step 5 — Update README.md** with:
- **Getting Started** — prerequisites and installation steps (from the Development Environment Setup section)
- **Architecture** — brief overview with a link to `workflow/spec/SPEC.md` for full details

**OUTPUT FORMAT:**

Two separate markdown documents:
1. `workflow/spec/SPEC.md`
2. `workflow/spec/HANDOFF.md`

Plus updates to the project instruction file and README.md.

**CONSTRAINTS:**

- No implementation code in either document.
- All schemas use standard notation (SQL for DB, OpenAPI-style for APIs).
- Diagrams use text-based formats only (Mermaid or DOT notation).
- Flag any requirement that is ambiguous or contradictory — do NOT resolve ambiguity by guessing.
- If research has gaps, list them explicitly rather than filling with assumptions.
- Keep SPEC.md focused. If a section grows beyond 200 lines, split it into a separate file in `workflow/spec/` and reference it from SPEC.md.
- Find the right balance between over-engineering (unnecessary microservices) and under-engineering (spaghetti monolith) for the specific project situation.

**DECISION RECORDS:**

When you make a significant architectural decision where 2+ viable options exist and the choice isn't obvious, create a decision record in `workflow/decisions/DR-NNN-title.md`. Use this structure:

```markdown
# DR-NNN: Title

**Phase:** 2 — Specification
**Date:** {date}
**Status:** proposed

## Context
{Why this decision is needed}

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| ...    | ...  | ...  |

## Decision
{What was decided and why}

## Consequences
{What changes as a result, including risks}
```

Update `workflow/decisions/README.md` index for each new record. Do NOT create records for trivial choices.

During the review loop, if the human pushes back on a decision via `*FEEDBACK:*`, add a `## Discussion` section to the relevant decision record with the `*FEEDBACK:*` / `*AI:*` exchange, and update the status as needed.

**HUMAN REVIEW PROCESS:**

After you produce SPEC.md and HANDOFF.md, create `workflow/spec/rfc.md` with a brief summary of key architectural decisions and any areas where you had low confidence.

Then **STOP and ask the human to review.** Do NOT proceed to the next phase or suggest next steps.

The human will review SPEC.md and HANDOFF.md and may add `*FEEDBACK:*` comments in the review file.

- Respond with `*AI:*` comments explaining what was changed and why, then update the relevant document(s) accordingly.
- Do not overwrite previous discussion — append new responses below existing conversation.
- The phase is complete only when the human explicitly approves. Do NOT move to Phase 3 until told.
