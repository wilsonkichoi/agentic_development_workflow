# AI-Assisted Software Development Workflow

A practical, tool-agnostic framework for getting the best development outcomes from LLMs while keeping costs low.

## Quick Start

### Claude Code (recommended)

```bash
# Add the marketplace
/plugin marketplace add wilsonkichoi/agentic_development_workflow

# Install the plugin
/plugin install agentic-dev@wilsonkichoi-agentic-dev

# Initialize a new project
/agentic-dev:init-project ./my-project

# Run phases
/agentic-dev:research      # Phase 1
/agentic-dev:spec           # Phase 2
/agentic-dev:plan           # Phase 3
/agentic-dev:execute        # Phase 4
/agentic-dev:verify         # Phase 5
```

The plugin includes 6 skills (init + 5 phases) and 13 role-based agents. Agents appear in `/agents` — use them for role-matched execution in Phase 4.

### Other Tools (Copilot CLI, Cursor, Windsurf, Codex, Gemini)

```bash
# Clone the repo
git clone https://github.com/wilsonkichoi/agentic_development_workflow.git

# Initialize a new project
./agentic_development_workflow/init.sh /path/to/my-project

# Use templates manually — copy-paste from templates/phases/ into your tool
```

### Local plugin testing (development)

```bash
claude --plugin-dir ./agentic_development_workflow
```

---

## Core Principles

1. **Best model, every phase.** Use the highest-reasoning model (Opus 4.6) for ALL phases — research, specification, planning, execution, and verification. Better models produce better results at every step and reduce costly human corrections. Optimize cost by using request-based billing plans (e.g., Copilot CLI) instead of downgrading models. If request-based billing loses its advantage, use Claude Code directly.
2. **Specs survive sessions.** Persistent documents (SPEC.md, HANDOFF.md, PLAN.md) bridge context between sessions and prevent context rot.
3. **Human gates between phases.** Every phase produces reviewable artifacts. Nothing moves forward without human approval.
4. **One task per loop.** Execute tasks atomically with fresh context. Prevents context degradation and makes failures easy to isolate.
5. **Tool-agnostic core.** The workflow, specs, and prompts work with any agentic coding tool. Tool-specific optimizations are optional.
6. **Automated verification before human review.** Every task must pass automated checks (lint, type check, tests) before a human reviews the diff.
7. **Every merge deploys to a verifiable environment.** Merged code must be deployable and verifiable in a real (or realistic) environment — not just passing local tests. See [CI_CD.md](CI_CD.md) for pipeline design notes.

---

## The 5-Phase Pipeline

```
Phase 1        Phase 2          Phase 3           Phase 4         Phase 5
Research  -->  Specification  -->  Task Breakdown  -->  Execution  -->  Verification
          [GATE]             [GATE]               [GATE]          [GATE]        [DONE]
                                                     ^                |
                                                     '----------------'
                                                      (fix & retry)
```

### Phase 1: Research & Discovery

**Goal:** Assemble all external knowledge through human manual research, then have AI perform deep research to produce a comprehensive, refined output that covers what both human and AI found.

**Model:** Opus 4.6. Best model produces the best research synthesis and catches nuances that cheaper models miss.

**Inputs:** Business requirements, user stories, API docs, reference architectures.

**Process:**

**Stage 1 — Human Manual Research:**
1. Conduct manual research using any tools available (Gemini Pro Deep Research, NotebookLM, web search, stakeholder conversations, etc.).
2. Gather materials in any format: markdown, PDF, DOCX, URLs, images, conversations, git repos, etc.
3. Materials should cover: business objectives, high-level design intent (UI, UX, architecture), external references, constraints.
4. Store all materials in `workflow/research/manual/`.

**Stage 2 — AI Deep Research:**
1. AI ingests all materials from `workflow/research/manual/`.
2. AI performs its own research: web search, codebase analysis, cross-referencing sources, exploring adjacent patterns and competing approaches.
3. AI covers blind spots the human may have missed — alternative architectures, edge cases, rate limiting patterns, scaling considerations, etc.
4. **If the AI cannot access a URL or resource** (blocked by bot protection, auth-walled, paywalled, etc.), it must explicitly report what it couldn't access and why, so the human can manually provide the content. Never silently skip inaccessible resources.
5. AI produces the refined, combined output in `workflow/research/final/`.

**Outputs:**
- `workflow/research/manual/` — raw human research materials (any format)
- `workflow/research/final/research.md` — AI-refined synthesis combining human and AI findings
- `workflow/research/final/references/` — processed reference materials, diagrams

**Gate:** Human reviews `workflow/research/final/research.md`. Confirms all business logic and constraints are captured. Verifies no important resources were silently skipped. If changes are needed, use the `*FEEDBACK:*` / `*AI:*` discussion protocol in `workflow/research/final/rfc.md` to iterate until approved.

**Template:** [`templates/phases/01-research.md`](templates/phases/01-research.md)

---

### Phase 2: Specification & Architecture

**Goal:** Translate research into rigid, implementation-free specifications. Define milestones as coherent, deployable increments. This is where the expensive model earns its keep.

**Model:** Highest reasoning available (Opus). Use plan/read-only mode to prevent premature code generation.

**Inputs:** `workflow/research/final/research.md` and all reference materials in `workflow/research/final/`.

**Process:**
1. Open your tool in plan/read-only mode.
2. Point the model at the research directory. Instruct it to ask clarifying questions until it fully understands the requirements.
3. Generate SPEC.md including: milestones, architecture, schemas, contracts, development environment setup (package manager, module structure, test runner config), coding standards, non-functional requirements, deployment architecture, negative requirements (what the system is NOT), and diagrams in text-based formats (Mermaid, DOT).
4. Generate HANDOFF.md (index of all specs + milestone ordering + execution sequence).
5. Update the project instruction file (CLAUDE.md, etc.) with brief architecture summary linking to the spec.

**Multi-role review (optional):**

By default, the specification is generated from a Software Architect perspective. For complex projects, engage additional review passes in separate sessions:

| Trigger | Additional Roles |
|---------|-----------------|
| Auth, payments, PII, or compliance requirements | Security Reviewer |
| Complex business rules, industry-specific logic | Domain Specialist |
| User-facing features, multiple user personas | Product Reviewer |
| Multiple integration points (>3 external systems) | Security Reviewer + Domain Specialist |
| Team size > 3 | All roles |

See [`templates/roles/README.md`](templates/roles/README.md) for role definitions and usage instructions.

**Outputs:**
- `workflow/spec/SPEC.md` — milestones, architecture, DB schemas, API contracts, coding standards, NFRs, negative requirements, diagrams
- `workflow/spec/HANDOFF.md` — universal index, milestone ordering, execution sequence, acceptance criteria

**Gate:** Human reviews SPEC.md and HANDOFF.md line by line. **This is the most critical gate.** A bad spec cascades into everything downstream. If changes are needed, use the `*FEEDBACK:*` / `*AI:*` discussion protocol in `workflow/spec/rfc.md` to iterate until approved.

**Template:** [`templates/phases/02-specification.md`](templates/phases/02-specification.md)

---

### Phase 3: Task Breakdown

**Goal:** Decompose each milestone from the spec into atomic, independently executable tasks with clear acceptance criteria.

**Model:** Highest reasoning (Opus 4.6). Good task decomposition requires deep understanding of architecture and dependencies.

**Inputs:** `workflow/spec/SPEC.md`, `workflow/spec/HANDOFF.md`.

**Process:**
1. Feed the spec into your tool.
2. For each milestone defined in SPEC.md, decompose into atomic tasks.
3. Each task gets: description, spec reference, files to modify, acceptance criteria, dependencies, assigned role.
4. Group independent tasks into **waves**. A wave is a set of tasks with no unresolved inter-dependencies that can execute concurrently.
5. **Test tasks are separate from implementation tasks.** The session that writes tests must NOT share context with the session that implements the feature. This prevents the AI from writing tests that match its implementation rather than testing the contract. For trivially simple tasks, the human may approve inline testing.
6. Structure PLAN.md as Milestone → Wave → Task.

**Task scope rules:**
- Each task should be a **single concern** — one feature, one component, one integration.
- Each task should be **independently verifiable** — testable without mocking half the system.
- Each task should be **clearly bounded** — describable in 2-3 sentences.
- If a task produces >500 lines of net new code, verify it's truly a single concern. If it IS a single concern at 500+ lines, keep it as one task with clear internal milestones.

**Parallel wave grouping criteria:**
- Tasks must belong to **different functional components**.
- Tasks must have either **zero relation** OR a clear API/library contract that is **defined and frozen in SPEC.md** before parallel execution starts.
- Tasks must NOT **share mutable state** (same database table, same config file, same state store).

**Outputs:**
- `workflow/plan/PLAN.md` — ordered task checklist structured as Milestone → Wave → Task, with dependencies, roles, and acceptance criteria
- `workflow/plan/PROGRESS.md` — progress tracker (updated during Phase 4)

**Gate:** Human reviews PLAN.md. Checks tasks are atomic, acceptance criteria are testable, dependencies make sense, test tasks are separated from implementation tasks. If changes are needed, use the `*FEEDBACK:*` / `*AI:*` discussion protocol in `workflow/plan/rfc.md` to iterate until approved.

**Template:** [`templates/phases/03-task-breakdown.md`](templates/phases/03-task-breakdown.md)

---

### Phase 4: Execution

**Goal:** Implement tasks one at a time with role-appropriate expertise, test verification per task, and human review before merge.

**Model:** Highest reasoning (Opus 4.6). Best model produces best code. On request-based billing (Copilot CLI), a single request costs the same regardless of output volume — use the best model available. If request-based billing is unavailable, use Claude Code with Opus directly.

**Inputs:** `workflow/plan/PLAN.md`, `workflow/spec/SPEC.md`, the codebase, relevant role definition from `templates/roles/`.

**Process:**
1. **Isolate:** Create a git branch `task/X.Y-short-title` (e.g., `task/1.1-implement-functions`). Do NOT work on `main`. With Claude Code: `claude -w task/X.Y-short-title --model opus`.
2. **Pick next task:** Read PLAN.md, find the next incomplete task.
3. **Match role:** Use the appropriate role definition for the task type (frontend dev for UI, backend engineer for API, etc.). See [`templates/roles/README.md`](templates/roles/README.md).
4. **Execute one task.** Feed the model the role definition + task description + relevant spec section.
5. **Test separation:** If this is a feature implementation task, its corresponding test task must be executed in a separate session with NO shared context. The test author sees only the spec, public interface, and acceptance criteria — not the implementation.
6. **Verify:** Agent runs linting, type checks, tests, and acceptance criteria before marking done.
7. **Write task review:** Create `workflow/plan/reviews/task-X.Y.md` with a work summary: what was implemented, key decisions made, obstacles encountered and how they were solved.
8. **Update progress:** Mark the task checkbox as `[x]` in PLAN.md. Set task status to `review` in PROGRESS.md. Note any issues.
9. **Human review:** Human reviews the diff and the task review file.
   - If changes needed: human adds `*FEEDBACK:*` comments in the task review file. AI responds with `*AI:*` comments, re-implements, and updates the review file. Discussion is append-only — never overwrite previous entries.
   - If satisfactory: human instructs AI to create a PR.
10. **Create PR:** PR description includes: what was implemented, which PLAN.md task, test results, spec gaps found, branch name.
11. **Fresh context:** Start each new task with a clean context (`/clear` or new session). Avoid `/compact` — lossy summarization increases hallucination risk.
12. **Repeat** until all tasks in the current wave are done.

**When stuck (before asking the human for help):**

Use this 5-step framework. Attempt ALL steps before escalating.

1. **Pattern Recognition** — Look across failed attempts. What's the common thread? Are you retrying the same approach with minor variations? Identify the failure category (config, logic, dependency, environment).
2. **Expand Context** — Read 50+ lines around the error site. Search the codebase for similar working patterns. Check dependency versions. Read actual library source code, not just docs.
3. **Verify Assumptions** — Is the error message pointing to the root cause? Are you editing the right file? Is the environment what you think it is? (versions, configs, paths)
4. **Try a Fundamentally Different Approach** — Not a tweak. A different strategy entirely. If debugging a library integration, try a different library. If fixing a function, try rewriting from scratch.
5. **Document and Escalate** — After 3 genuinely different approaches have failed, document in the task review file: what you tried specifically, each attempt's failure mode, your best hypothesis for root cause, and what information you need from the human.

**Rules:**
- Act before asking. Include diagnostic output with any request for help.
- If you cannot access a URL or resource, explicitly report what you couldn't access and why.
- Never silently skip a step because it seems unlikely to help.

**Outputs:**
- Working code committed per task (in feature branch, NOT merged)
- Updated `workflow/plan/PROGRESS.md`
- `workflow/plan/reviews/task-X.Y.md` for every task
- Pull request per task (created on human instruction)

**Gate:** Human reviews the diff and task review file. Code is NOT merged until human approves and instructs PR creation.

**Template:** [`templates/phases/04-execution.md`](templates/phases/04-execution.md)

---

### Phase 5: Verification & Retrospective

**Goal:** End-to-end testing per milestone and capturing learnings for the next cycle.

**Model:** Opus 4.6. Accurate retrospectives require deep understanding of what went wrong and why — the best model produces the most actionable insights.

**Inputs:** Completed code, test results, PLAN.md, PROGRESS.md, `workflow/plan/reviews/`, `workflow/decisions/`.

**Process:**
1. Run full test suite for the milestone.
2. Deploy locally and manually test critical paths.
3. If issues found, feed specific failures back into Phase 4 (targeted fix, not full re-plan).
4. Generate a retrospective: what the AI got right, what needed correction, spec gaps discovered, which decisions (from `workflow/decisions/`) caused problems, effectiveness of test separation.
5. Human confirms merge. PRs for the milestone are merged.

**Outputs:**
- Passing test suite
- `workflow/retro/RETRO-{milestone}.md`
- Merged PRs

**Gate:** Human confirms merge. If changes are needed to the retrospective, use the `*FEEDBACK:*` / `*AI:*` discussion protocol in `workflow/retro/review.md` to iterate. Return to Phase 3 for the next milestone (or Phase 1/2 if the spec needs revision).

**Template:** [`templates/phases/05-verification.md`](templates/phases/05-verification.md)

---

## Project Folder Structure

When starting a new project, create this structure:

```
project-root/
├── README.md                          # User-facing project documentation
├── CLAUDE.md                          # AI tool instructions (see below)
├── workflow/
│   ├── research/
│   │   ├── manual/                    # Phase 1: human research materials (any format)
│   │   └── final/                     # Phase 1: AI-refined research output
│   │       ├── research.md
│   │       └── references/
│   ├── spec/
│   │   ├── SPEC.md                    # Phase 2: architecture, schemas, contracts, milestones
│   │   └── HANDOFF.md                 # Phase 2: index + execution sequence
│   ├── plan/
│   │   ├── PLAN.md                    # Phase 3: Milestone → Wave → Task breakdown
│   │   ├── PROGRESS.md                # Phase 4: live progress tracker
│   │   └── reviews/                   # Phase 4: per-task review discussions
│   │       └── task-X.Y.md            # Created for every task
│   ├── decisions/
│   │   ├── README.md                  # Decision index
│   │   └── DR-NNN-title.md            # Individual decision records
│   └── retro/
│       └── RETRO-{milestone}.md       # Phase 5: retrospective
├── src/                               # Source code
└── tests/                             # Test suite
```

### Project Instruction Files

Every tool has its own format. Keep it lean (<500 lines) and link to spec docs for details:

| Tool | File |
|------|------|
| Claude Code | `CLAUDE.md` |
| Copilot CLI | `.github/copilot-instructions.md` |
| Cursor | `.cursorrules` |
| Windsurf | `.windsurfrules` |
| Codex CLI | `AGENTS.md` |
| Gemini CLI | `GEMINI.md` |

---

## Roles

Role definitions live in `templates/roles/`. Each role is a prompt snippet composed with the phase template to provide domain-specific expertise and constraints.

See [`templates/roles/README.md`](templates/roles/README.md) for the full role registry, phase mapping, and usage instructions.

Roles are adapted from [agency-agents](https://github.com/msitarzewski/agency-agents) with modifications for this workflow's phase structure.

**Core roles:**

| Role | Primary Phase | Focus |
|------|--------------|-------|
| Software Architect | 2, 3 | System design, component boundaries, trade-off analysis |
| Security Reviewer | 2 | Threat modeling, auth flows, compliance |
| Domain Specialist | 2 | Business rule accuracy, domain modeling |
| Product Reviewer | 2 | User-centric acceptance criteria, UX completeness |
| Senior Engineer | 3 | Implementation feasibility, hidden complexity |
| Senior PM | 3 | Priority, risk, milestone sequencing |
| Frontend Developer | 4 | Component architecture, accessibility, responsive design |
| Backend Engineer | 4 | API implementation, data layer, service logic |
| Data Engineer | 4 | Schema implementation, migrations, data integrity |
| DevOps Engineer | 4 | Infrastructure, CI/CD, deployment |
| QA Engineer | 4, 5 | Spec-based testing, coverage analysis |
| Security Engineer | 4 | Secure implementation, auth, encryption |
| Code Reviewer | 5 | Code quality, patterns, maintainability |

---

## Decision Records

Use Architecture Decision Records (ADRs) to capture significant decisions throughout the workflow. Store in `workflow/decisions/`.

**When to create a decision record:**
- The human pushes back on an AI decision
- There are 2+ viable options and the choice isn't obvious
- A spec gap is discovered during execution that requires a design decision

Do NOT create decision records for trivial choices (variable naming, minor formatting).

**Structure:**

```markdown
# DR-NNN: Title

**Phase:** {phase number and name}
**Date:** {date}
**Status:** proposed | accepted | superseded by DR-NNN

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

## Discussion

*FEEDBACK:* {human feedback}

*AI:* {AI response}
```

The `workflow/decisions/README.md` maintains an index:

```markdown
# Decision Records

| ID | Title | Phase | Status |
|----|-------|-------|--------|
| DR-001 | PostgreSQL over DynamoDB | 2 | accepted |
| DR-002 | JWT with refresh tokens | 2 | accepted |
| DR-003 | Split task 2.3 | 3 | accepted |
```

---

## Task Review Files

Every task in Phase 4 produces a review file at `workflow/plan/reviews/task-X.Y.md`. This file serves as:
- A work summary (what was done and why)
- A discussion space for human-AI feedback loops
- Input for Phase 5 retrospectives

**Structure:**

```markdown
# Task X.Y: {Title}

## Work Summary
- **What was implemented:** {1-2 sentences}
- **Key decisions:** {any non-trivial choices made during implementation}
- **Files created/modified:** {list}
- **Test results:** {pass/fail summary}
- **Spec gaps found:** {any, or "none"}
- **Obstacles encountered:** {any, with how they were resolved}

## Review Discussion

{Human adds *FEEDBACK:* comments, AI responds with *AI:* comments.
This section grows only if the human has feedback; otherwise left empty.
Append-only — never overwrite previous entries.}
```

---

## Cost Optimization

### GitHub Copilot Billing (as of March 2026)

| Plan | Monthly Cost | Premium Requests | Overage |
|------|-------------|-----------------|---------|
| Free | $0 | 50 | N/A |
| Pro | $10 | 300 | $0.04/req |
| Pro+ | $39 | 1,500 | $0.04/req |
| Business | $19/seat | 300/user | $0.04/req |
| Enterprise | $39/seat | 1,000/user | $0.04/req |

### Model Multipliers (Premium Request Cost)

| Model | Multiplier | Eff. Calls on Pro (300) | Eff. Calls on Pro+ (1,500) |
|-------|-----------|------------------------|---------------------------|
| GPT-4.1, GPT-4o, GPT-5 mini | 0x (free) | Unlimited | Unlimited |
| Claude Haiku 4.5, Gemini 3 Flash | 0.33x | ~909 | ~4,545 |
| Claude Sonnet 4/4.5/4.6 | 1x | 300 | 1,500 |
| Claude Opus 4.6 | 3x | 100 | 500 |
| Claude Opus 4.6 (fast mode) | 30x | 10 | 50 |

### Model Selection by Phase

| Phase | Recommended | Copilot Model | Rationale |
|-------|------------|--------------|-----------|
| 1. Research | Opus 4.6 | Opus 4.6 (3x) | Best model catches nuances and produces higher-quality synthesis |
| 2. Specification | Opus 4.6 | Opus 4.6 (3x) | Architecture decisions have max leverage |
| 3. Task Breakdown | Opus 4.6 | Opus 4.6 (3x) | Better decomposition from deep architectural understanding |
| 4. Execution | Opus 4.6 | Opus 4.6 (3x) | Best model produces best code; request-based billing absorbs the cost |
| 5. Verification | Opus 4.6 | Opus 4.6 (3x) | Accurate retrospectives require deep analysis to produce actionable insights |

### Copilot CLI Cost Optimization

The key insight: Copilot charges per request regardless of output token volume. A request generating 1,000 lines costs the same as one generating 10 lines. This means you can use Opus 4.6 (3x) for code generation and get the best possible output without paying per-token.

**Strategy:**
- Use Copilot CLI with Opus 4.6 (3x) for ALL phases — best model at flat per-request cost. The quality improvement across every phase reduces human correction time, which more than offsets any cost difference.
- At overage ($0.04/req x 3x = $0.12/req for Opus), each interaction is still cheap vs. token-based billing for large code generation.
- **Fallback:** If Copilot changes pricing to eliminate this advantage, switch to Claude Code with Opus directly.

**What to be cautious about:**
- **`/fleet` costs MORE, not less.** Official docs: "Using /fleet may cause more premium requests to be consumed." Each subagent consumes additional requests independently.
- **Opus 4.6 fast mode at 30x** is extremely expensive — avoid unless necessary.
- **Pricing can change at any time.** If this cost advantage disappears, use Claude Code directly with Opus 4.6.

### Context Management

- **Prefer `/clear` or new sessions** between tasks. Fresh context prevents stale/incorrect information from accumulating.
- **Avoid `/compact`** for critical work — lossy summarization increases hallucination risk. Use it only for long exploratory sessions where approximate context is acceptable.
- **Keep instruction files lean** — under 500 lines. Link to `workflow/spec/` for details.
- **Use `@` file inclusion** to load only the specific spec sections needed per task.

---

## Tool-Specific Guide

### Claude Code (Primary)

| Feature | Command | Use For |
|---------|---------|---------|
| Plan mode | `claude --permission-mode plan` | Phase 2: read-only spec generation |
| Model switching | `--model sonnet` or `--model opus` | Tiering between phases |
| Clear context | `/clear` | Fresh context between tasks |
| Worktree isolation | `claude -w <branch-name>` | Phase 4: isolated execution |
| Subagents | Agent tool within session | Parallel exploration/research |

```bash
# Phase 2: Specification (Opus, plan mode)
claude --permission-mode plan --model opus

# Phase 4: Execution (Opus, worktree)
claude -w feature-branch --model opus
```

### Copilot CLI (Cost Optimization)

| Feature | Command | Use For |
|---------|---------|---------|
| Autopilot | `--autopilot` | Autonomous task execution |
| Allow all permissions | `--yolo` or `--allow-all` | Skip permission prompts |
| Limit autonomous steps | `--max-autopilot-continues N` | Safety cap on autopilot |
| Plan mode | `/plan` or `Shift+Tab` | Structured planning |
| Fleet (parallel agents) | `/fleet` | Parallel subtasks (costs more requests) |
| Delegate to cloud | `/delegate` or prefix with `&` | Async PR creation |
| Model selection | `/model <model-name>` | Switch models mid-session |
| File inclusion | `@ FILENAME` | Load specific files into context |
| Clear context | `/clear` or `/new` | Fresh context between tasks |
| Context visualization | `/context` | Monitor token usage |
| Mode cycling | `Shift+Tab` | Cycle: normal -> plan -> autopilot |

```bash
# Phase 3: Plan with Opus
copilot
> /model claude-opus-4.6
> /plan Read @workflow/spec/HANDOFF.md and generate an implementation plan

# Phase 4: Execute with Opus (best model, request-based billing)
copilot --model claude-opus-4.6 --autopilot --max-autopilot-continues 30 \
  -p "Read @workflow/plan/PLAN.md. Execute the next incomplete task. Run tests after."
```

**Context limit:** ~128K tokens for Opus 4.6 (as of March 2026 — this is a moving target that changes frequently). Auto-compaction triggers at 95%.

### Cursor / Windsurf / Gemini CLI / Codex CLI

Template prompts work as-is via copy-paste. Use each tool's native project instruction file with the same content you'd put in CLAUDE.md.

---

## Document Lifecycle

| Document | Created In | Updated | Consumed By |
|----------|-----------|---------|-------------|
| `workflow/research/manual/*` | Phase 1 (human) | Append-only | Phase 1 (AI) |
| `workflow/research/final/research.md` | Phase 1 (AI) | Updated during review loop | Phase 2 |
| `workflow/research/final/rfc.md` | Phase 1 | Updated during review loop | Phase 1 |
| `workflow/spec/SPEC.md` | Phase 2 | Updated during review loop | Phase 3, 4 |
| `workflow/spec/HANDOFF.md` | Phase 2 | Updated during review loop | Phase 3 |
| `workflow/spec/rfc.md` | Phase 2 | Updated during review loop | Phase 2 |
| `workflow/plan/PLAN.md` | Phase 3 | Updated during review loop | Phase 4, 5 |
| `workflow/plan/rfc.md` | Phase 3 | Updated during review loop | Phase 3 |
| `workflow/plan/PROGRESS.md` | Phase 3 | Live-updated in Phase 4 | Phase 4, 5 |
| `workflow/plan/reviews/task-X.Y.md` | Phase 4 | Updated during review loop | Phase 4, 5 |
| `workflow/decisions/DR-NNN-*.md` | Any phase | Updated during review loops | All phases, especially Phase 5 |
| `RETRO-*.md` | Phase 5 | Updated during review loop, accumulates | Next Phase 1 |
| `workflow/retro/review.md` | Phase 5 | Updated during review loop | Phase 5 |
| `CLAUDE.md` | Phase 2 | Living document, kept lean | All phases |
| `README.md` | Init | Updated in Phase 1 (Overview), Phase 2 (Getting Started, Architecture), Phase 4 (Usage), Phase 5 (polish) | End users |

**Key rules:**
- **Spec docs are authoritative.** If a gap is found during execution, note it in PROGRESS.md and the task review file, and address it next cycle — don't patch mid-execution unless critical.
- **Retrospectives accumulate.** Each milestone adds a new file. These inform the next planning cycle.
- **Research docs are append-only.** New research creates new files; don't overwrite old findings.
- **Task review files preserve history.** AI should not overwrite previous entries. Append new `*AI:*` responses below existing discussion.
- **Decision records are append-only** for their discussion section. Status can change (proposed → accepted → superseded).

---

## Using the Prompt Templates

Templates live in `templates/phases/`. Role definitions live in `templates/roles/`. Each is self-contained and copy-paste ready.

**To use a template:**
1. Open the template file for your current phase.
2. If the task requires a specific role, also open the role file from `templates/roles/`.
3. Copy the role definition (if applicable), then the phase prompt.
4. Replace the `{{placeholders}}` with your project details.
5. Paste into your tool (Claude Code, Copilot CLI, Cursor, etc.).

**To compose templates:** You can combine multiple templates in one prompt:
```
Read templates/roles/backend-engineer.md and adopt this role.
Read templates/phases/04-execution.md and follow its instructions.
```

**To add specialized templates:** Create a `templates/research/` directory for domain-specific research prompts (UI design, system architecture, business analysis, etc.). These compose freely with the phase templates.

---

## References

### AI Coding Frameworks
- [Ralph Wiggum / Loop](https://ghuntley.com/loop/) — iterative loop, test-driven, one story at a time
- [GSD (Get Shit Done)](https://github.com/gsd-build/get-shit-done) — plan -> execute in waves -> verify, persistent docs
- [Craftsman](https://github.com/gsemet/Craftsman) — plan mode + execution mode, model tiering
- [GSD + VS Code Copilot Guide](https://github.com/KickdriveOliver/get-shit-done/blob/feature/vscode-copilot-win-no-git/GSD-VSCODE-GUIDE.md)
- [PUA](https://github.com/tanweai/pua) — debugging persistence framework, 5-step debugging methodology (adapted into Phase 4)
- [Agency Agents](https://github.com/msitarzewski/agency-agents) — role-based agent definitions (adapted into `templates/roles/`)

### Claude Code
- [Agent Teams](https://code.claude.com/docs/en/agent-teams)
- [Skills](https://code.claude.com/docs/en/skills)
- [Anthropic Skills Repo](https://github.com/anthropics/skills)
- [Skills Guide (PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)
- [Claude Code Tips](https://github.com/ykdojo/claude-code-tips)

### GitHub Copilot CLI
- [Autopilot Mode](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/autopilot)
- [Fleet (Parallel Agents)](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/fleet)
- [CLI Command Reference](https://docs.github.com/en/copilot/reference/cli-command-reference)
- [CLI Best Practices](https://docs.github.com/en/copilot/how-tos/copilot-cli/cli-best-practices)
- [Plan Mode](https://docs.github.com/en/copilot/how-tos/copilot-cli/cli-best-practices#plan-mode)
- [Delegate Tasks](https://docs.github.com/en/copilot/how-tos/copilot-cli/use-copilot-cli-agents/delegate-tasks-to-cca)
- [Context Management](https://docs.github.com/en/copilot/concepts/agents/copilot-cli/about-copilot-cli#automatic-context-management)
- [Copilot Plans & Pricing](https://docs.github.com/en/copilot/about-github-copilot/plans-for-github-copilot)

### Cost Analysis
- [Claude Limits Tracker](https://she-llac.com/claude-limits)
- [You Don't Need $100/mo on Claude](https://www.aiforswes.com/p/you-dont-need-to-spend-100-mo-on-claude)
- [HN: Copilot Billing Discussion](https://news.ycombinator.com/item?id=46936105)
- [Premium Requests Strategy](https://www.reddit.com/r/GithubCopilot/comments/1okwhw5/whats_your_premium_request_strategy/)

### Community Discussion
- [Combining Claude + Copilot](https://www.reddit.com/r/ClaudeCode/comments/1p7jefr/how_should_i_combine_github_copilot_and_claude/)
- [Multi-Agent Orchestration](https://www.reddit.com/r/GithubCopilot/comments/1rfw6y9/multi_agent_orchestration/)
- [Premium Requests for Subagents](https://www.reddit.com/r/GithubCopilot/comments/1qxfgue/premium_requests_for_sub_agents_vs_parallel_agents/)
- [Copilot Squad](https://github.com/kevinkwee/github-copilot-squad)

### MCP Tools
- [AWS Diagram MCP Server](https://awslabs.github.io/mcp/servers/aws-diagram-mcp-server)
- [Agent Skills Registry](https://agentskills.io/home)
