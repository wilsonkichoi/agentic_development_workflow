---
name: spec
description: "Use for Phase 2 of the development workflow: specification and architecture. Generates SPEC.md (milestones, architecture, schemas, API contracts, diagrams) and HANDOFF.md from research findings. Use when someone says 'create spec', 'phase 2', 'specification phase', 'architecture design', 'write the spec', or after Phase 1 research is approved."
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 2 (Specification & Architecture) of the AI-Assisted Development Workflow. Translates research into implementation-free specifications with milestones, architecture diagrams, database schemas, and API contracts.

## Important

Use **plan/read-only mode**. Do NOT generate implementation code.

For Claude Code: start with `claude --permission-mode plan --model opus`

## Instructions

Read [template.md](template.md) for the detailed phase template.

**If `workflow/spec/SPEC.md` already exists but `workflow/spec/rfc.md` does not**, the phase was run before the review process was added. Create the RFC file now and ask the human to review before proceeding.

Key points:
1. Read `workflow/research/final/research.md` and all references
2. **Ask clarifying questions first** — do not proceed until the human confirms
3. Define **milestones** as coherent, deployable increments
4. Include **architecture diagrams** in Mermaid or DOT format
5. Include **negative requirements** (what the system is NOT)
6. API contracts must be detailed enough for independent implementation
7. Create `workflow/spec/rfc.md` with a summary of key architectural decisions and low-confidence areas
8. **STOP and ask the human to review. Do NOT proceed to Phase 3 or suggest next steps until the human explicitly approves.** If `*FEEDBACK:*` is given in the RFC file, respond with `*AI:*`, revise SPEC.md/HANDOFF.md, and wait again.

## Multi-role review

Default: Software Architect role. For complex projects, run additional review passes in separate sessions. Available agents:

- `/agents` → `agentic-dev:security-reviewer` (auth, PII, compliance)
- `/agents` → `agentic-dev:domain-specialist` (complex business rules)
- `/agents` → `agentic-dev:product-reviewer` (user-facing features)

## Output

- `workflow/spec/SPEC.md`
- `workflow/spec/HANDOFF.md`
- Updated CLAUDE.md with architecture summary
