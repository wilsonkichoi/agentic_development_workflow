# Phase 1: Research & Discovery — Prompt Template

## When to Use

At the start of a new project or feature. Before any architecture or design decisions.

## Prerequisites

Human has completed manual research and stored materials in `workflow/research/manual/`. Materials may include: markdown files, PDFs, DOCX, URLs, images, conversations, git repos, API specs, stakeholder notes, competitor examples, screenshots, etc.

## Recommended Model

Opus 4.6. Best model produces the best research synthesis and catches nuances that cheaper models miss.
- Claude Code: `--model opus`
- Copilot CLI: Opus 4.6 (3x)

## Prompt

Copy everything below the line, fill in `{{placeholders}}`, and paste into your tool.

---

**CONTEXT:**

- Project: {{PROJECT_NAME}}
- Description: {{ONE_LINE_DESCRIPTION}}
- Business Objective: {{WHAT_PROBLEM_ARE_WE_SOLVING}}
- Target Users: {{WHO_WILL_USE_THIS}}
- Budget/Timeline Constraints: {{ANY_KNOWN_CONSTRAINTS}}

**RESEARCH INPUTS:**

Read all files in `workflow/research/manual/`. These are materials gathered during human manual research and may include business objectives, high-level design intent (UI, UX, architecture), external references, API docs, competitor analysis, stakeholder conversations, and constraints.

{{LIST_ANY_ADDITIONAL_URLS_OR_RESOURCES_TO_RESEARCH}}

If a project instruction file exists (CLAUDE.md, .github/copilot-instructions.md, .cursorrules, .windsurfrules, AGENTS.md, GEMINI.md), read it for existing tooling preferences, version constraints, or coding standards. Treat these as project constraints.

**INSTRUCTIONS:**

You are performing deep research to complement the human's manual research. Do not merely summarize — add value by:

1. **Cross-reference** the manual research materials against each other. Identify contradictions, gaps, and unstated assumptions.
2. **Expand coverage** through web search, codebase analysis, and exploration of adjacent patterns. Look for:
   - Alternative architectures or approaches the human may not have considered
   - Edge cases, rate limits, scaling considerations for referenced APIs/services
   - Competing products and how they solve similar problems
   - Known pitfalls with the technologies or patterns mentioned in the manual research
3. **Synthesize** everything (human findings + your findings) into a unified research document.

Produce the output with these sections:

1. **Business Requirements** — What the system must do, prioritized (must-have vs nice-to-have).
2. **Technical Constraints** — Budget, timeline, tech stack requirements, compliance, deployment targets, team skills.
3. **Reference Architectures** — Similar systems that exist, patterns they use, lessons learned.
4. **External Dependencies** — Third-party APIs, services, or data sources to integrate with. Include auth methods, rate limits, and pricing where known.
5. **AI Research Additions** — Findings from your own research that were not present in the manual materials. Clearly distinguish what is new.
6. **Open Questions** — Things we still need to resolve before designing. Flag anything ambiguous or contradictory.
7. **Recommended Tech Stack** — With brief justification for each choice.
8. **Inaccessible Resources** — Any URLs or resources you could not access (blocked by bot protection, auth-walled, paywalled, etc.). For each, state what the resource was and why you couldn't access it, so the human can manually provide the content.

**OUTPUT FORMAT:**

Save as `workflow/research/final/research.md`. Place any processed reference materials in `workflow/research/final/references/`.
Use headings, bullet points, and tables. Keep it scannable — no prose paragraphs.

Also update the **Overview** section of `README.md` with a concise problem statement and project description based on the research findings.

**CONSTRAINTS:**

- Do NOT make architecture decisions. This is research, not design.
- If information is missing, list it under "Open Questions" rather than guessing.
- Cite sources where possible.
- If you cannot access a URL or resource, list it under "Inaccessible Resources" with an explanation. NEVER silently skip a resource.
- Link to detailed references rather than inlining large content.
- When recommending technologies, libraries, or runtimes, always recommend the **current stable or LTS version** — never an EOL or near-EOL version. If the manual research specifies a version, note whether it is still supported and flag if it is outdated.
- If your tech stack recommendation involves a non-obvious choice between 2+ viable options, create a decision record in `workflow/decisions/DR-NNN-title.md` and update `workflow/decisions/README.md`. See WORKFLOW.md § Decision Records for the template. Do NOT create records for trivial choices.

**HUMAN REVIEW PROCESS:**

After you produce `workflow/research/final/research.md`, create `workflow/research/final/rfc.md` with a brief summary of key findings and any areas where you had low confidence.

Then **STOP and ask the human to review.** Do NOT proceed to the next phase or suggest next steps.

The human will review `research.md` and may add `*FEEDBACK:*` comments in the review file.

- Respond with `*AI:*` comments explaining what was changed and why, then update `research.md` accordingly.
- Do not overwrite previous discussion — append new responses below existing conversation.
- The phase is complete only when the human explicitly approves. Do NOT move to Phase 2 until told.
