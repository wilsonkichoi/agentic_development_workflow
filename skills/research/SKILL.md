---
name: research
description: "Use for Phase 1 of the development workflow: AI deep research. Ingests human research materials from workflow/research/manual/ and performs web search, codebase analysis, and cross-referencing to produce a comprehensive research synthesis. Use when someone says 'start research', 'phase 1', 'research phase', 'deep research', or has placed materials in workflow/research/manual/."
disable-model-invocation: true
---

## What This Skill Does

Executes Phase 1 (Research & Discovery) of the AI-Assisted Development Workflow. Takes human-gathered research materials and performs independent AI research to fill gaps, cross-reference findings, and produce a unified research document.

## Prerequisites

Human has placed research materials in `workflow/research/manual/`. Materials can be any format: markdown, PDF, URLs, images, conversations, etc.

## Instructions

Read [template.md](template.md) for the detailed phase template with all sections and constraints.

**If `workflow/research/final/research.md` already exists but `workflow/research/final/rfc.md` does not**, the phase was run before the review process was added. Create the RFC file now and ask the human to review before proceeding.

Key points:
1. Read ALL materials in `workflow/research/manual/`
2. Check the project instruction file (CLAUDE.md or equivalent) for existing tooling preferences and constraints
3. Cross-reference materials against each other — find contradictions and gaps
4. Perform your own research: web search, explore adjacent patterns, competing approaches
5. **If you cannot access a URL or resource**, report it explicitly under "Inaccessible Resources" — never silently skip
6. Always recommend **current stable or LTS versions** — never EOL
7. Produce output combining human + AI findings at `workflow/research/final/research.md`
8. Place processed references in `workflow/research/final/references/`
9. Create `workflow/research/final/rfc.md` with a summary of key findings and low-confidence areas
10. **STOP and ask the human to review. Do NOT proceed to Phase 2 or suggest next steps until the human explicitly approves.** If `*FEEDBACK:*` is given in the RFC file, respond with `*AI:*`, revise research.md, and wait again.

## Output

- `workflow/research/final/research.md`
- `workflow/research/final/references/`
