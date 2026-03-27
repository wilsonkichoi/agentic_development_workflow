# Agentic Development Workflow

A structured, 5-phase framework for building software with AI coding agents. Gives LLMs clear specifications, atomic tasks, and role-matched expertise — so you get predictable, high-quality output instead of hoping the AI figures it out.

> **Note:** I created this project to better understand agentic software development methodology. There may be a bunch of stupid stuff here. For real projects, check out [Superpowers](https://github.com/obra/superpowers), [GSD](https://github.com/gsd-build/get-shit-done), [Spec Kit](https://github.com/github/spec-kit), [EPCC](https://github.com/aws-solutions-library-samples/guidance-for-claude-code-with-amazon-bedrock/blob/main/assets/claude-code-plugins/README.md), [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) and incorporate whatever works for you.

## The Problem

Most people use AI coding tools by throwing a vague prompt at an LLM and hoping for the best. This works for small tasks but falls apart for anything real:

- The AI makes assumptions instead of asking
- Specifications live in your head, not in documents the AI can read
- Tasks are too big, so context degrades and quality drops
- No verification — you merge code you haven't meaningfully reviewed
- Knowledge is lost between sessions

## How This Helps

This workflow breaks AI-assisted development into 5 phases with human gates between each:

```
Phase 1        Phase 2          Phase 3           Phase 4         Phase 5
Research  -->  Specification  -->  Task Breakdown  -->  Execution  -->  Verification
          [GATE]             [GATE]               [GATE]          [GATE]
```

**Phase 1: Research** — Human gathers materials, AI performs deep research to fill gaps and cross-reference findings.

**Phase 2: Specification** — AI generates architecture specs (SPEC.md) with milestones, schemas, API contracts, and diagrams. No code. Optional multi-role review (security, domain, product).

**Phase 3: Task Breakdown** — Spec is decomposed into atomic tasks grouped into parallel waves, with role assignments and test separation.

**Phase 4: Execution** — One task per session, role-matched agents, automated verification, human review via task review files, PR on approval.

**Phase 5: Verification** — Per-milestone end-to-end testing and retrospective.

Each phase produces persistent documents (SPEC.md, PLAN.md, PROGRESS.md, decision records, task reviews) that survive across sessions and prevent context rot.

## What's Included

| Component | Count | Description |
|-----------|-------|-------------|
| **Skills** | 6 | `init-project`, `research`, `spec`, `plan`, `execute`, `verify` |
| **Agents** | 13 | Software Architect, Backend Engineer, QA Engineer, Security Reviewer, and more |

## Installation

### Claude Code Plugin (recommended)

```bash
# Add the marketplace
/plugin marketplace add wilsonkichoi/agentic_development_workflow

# Install the plugin — select "Install for you, in this repo only (local scope)"
/plugin install agentic-dev@wilsonkichoi-agentic-dev
```

When prompted for install scope, choose **"Install for you, in this repo only"** (local scope). This keeps the plugin scoped to your project rather than applying globally, which is recommended while the workflow is still evolving.

After installation:
- Skills are available as `/agentic-dev:research`, `/agentic-dev:spec`, etc.
- Agents appear in `/agents` (e.g., `agentic-dev:backend-engineer`)
- Auto-updates when the repo is updated

### Copilot CLI

```bash
copilot plugin install wilsonkichoi/agentic_development_workflow
```

### Gemini CLI

To avoid polluting the global context, install the extension globally but keep it disabled by default. Enable it strictly on a per-workspace basis:

```bash
# 1. Install the extension from GitHub
gemini extensions install https://github.com/wilsonkichoi/agentic_development_workflow

# 2. Disable the extension globally (user scope) so it doesn't pollute all your projects
gemini extensions disable agentic-development-workflow --scope user

# 3. Navigate into specific projects and enable it locally (workspace scope)
cd /path/to/your-project
gemini extensions enable agentic-development-workflow --scope workspace
```

After installation:
- Skills are available directly via the CLI (e.g., `gemini plan`).
- Subagents are available via the `@` mention or interactively (e.g., `gemini --agent=backend-engineer`).

### Local Plugin Testing

```bash
claude --plugin-dir /path/to/agentic_development_workflow
```

## Updating

### Claude Code Plugin

```bash
# Update marketplace listings
/plugin marketplace update wilsonkichoi-agentic-dev

# Or enable auto-updates in /plugin → Marketplaces → Enable auto-update
```

**Important:** After updating, start a new session (`/clear` or new terminal). Skill file paths are cached per session and `/reload-plugins` may not fully refresh them.

### Migrating from 1.x to 2.0.0

v2.0.0 removes the `templates/` directory. Phase prompts are now inline in each skill's `SKILL.md`, and role definitions live in `agents/` as the single source of truth.

**What changed:**

| 1.x | 2.0.0 |
|-----|-------|
| `templates/phases/*.md` | Merged into `skills/*/SKILL.md` |
| `templates/roles/*.md` | Replaced by `agents/*.agent.md` |
| `skills/*/template.md` | Merged into `skills/*/SKILL.md` |

**Step 1 — Update the plugin:**

```bash
# Claude Code
/plugin marketplace update wilsonkichoi-agentic-dev

# Copilot CLI
copilot plugin update wilsonkichoi/agentic_development_workflow

```

**Step 2 — Clean up existing projects:**

Remove the legacy `templates/` directory from any project that was initialized with 1.x:

```bash
# From your project root
rm -rf templates/
```

**Step 3 — Update your project instruction file:**

If your project's `CLAUDE.md` references `templates/`, update those references:

- Phase prompts: replace `templates/phases/01-research.md` → `/agentic-dev:research` (or read `skills/research/SKILL.md` directly)
- Role definitions: replace `templates/roles/backend-engineer.md` → `agents/backend-engineer.agent.md` (or use `/agents` in the plugin)

**Step 4 — Verify:**

```bash
# templates/ should not exist in your project
ls templates/ 2>&1  # Expected: "No such file or directory"

# No stale references in your project instruction file
grep "templates/" CLAUDE.md  # Expected: no output
```

After updating, start a new session (`/clear` or new terminal) to pick up the new skill files.

## Usage

### Starting a New Project

```bash
# From parent directory
/agentic-dev:init-project ./my-project

# Already inside the project directory
/agentic-dev:init-project .
```

This creates:

```
my-project/
├── CLAUDE.md                 # Project instructions (edit first)
├── workflow/
│   ├── research/manual/      # Place human research here
│   ├── research/final/       # AI research output
│   ├── spec/                 # SPEC.md, HANDOFF.md
│   ├── plan/                 # PLAN.md, PROGRESS.md
│   │   └── reviews/          # Per-task review files
│   ├── decisions/            # Architecture Decision Records
│   └── retro/                # Retrospectives
├── src/
└── tests/
```

### Running Phases

| Phase | Command | What It Does |
|-------|---------|-------------|
| 1. Research | `/agentic-dev:research` | AI deep research on materials in `workflow/research/manual/` |
| 2. Specification | `/agentic-dev:spec` | Generate SPEC.md with milestones, schemas, contracts |
| 3. Task Breakdown | `/agentic-dev:plan` | Decompose into atomic tasks with wave grouping |
| 4. Execution | `/agentic-dev:execute` | Implement one task with role-matched agent |
| 5. Verification | `/agentic-dev:verify` | End-to-end testing + retrospective |

### Using Agents (Phase 4)

During execution, tasks are matched to specialized agents:

| Task Type | Agent |
|-----------|-------|
| API endpoints, services | `agentic-dev:backend-engineer` |
| UI components | `agentic-dev:frontend-developer` |
| Database migrations | `agentic-dev:data-engineer` |
| Test implementation | `agentic-dev:qa-engineer` |
| Auth, encryption | `agentic-dev:security-engineer` |
| Infrastructure, CI/CD | `agentic-dev:devops-engineer` |

Test tasks run in **separate sessions** from implementation tasks — the QA agent sees only the spec and public interface, not the implementation. This prevents the AI from writing tests that match its code rather than testing the contract.

## Key Concepts

**Human gates** — Every phase produces reviewable artifacts. Nothing moves forward without human approval.

**One task per session** — Fresh context for each task. No context rot.

**Decision records** — Significant decisions are captured in `workflow/decisions/DR-NNN-*.md` with options, rationale, and threaded human/AI discussion.

**Task review files** — Every task gets `workflow/plan/reviews/task-X.Y.md` with a work summary and space for `*FEEDBACK:*` / `*AI:*` discussion before PR creation.

**Parallel waves** — Independent tasks run concurrently when they belong to different components, have frozen API contracts, and share no mutable state.

**Test separation** — Tests are written by a QA agent in a separate session from the implementation agent, testing the spec contract rather than the implementation.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup, testing checklist, and PR guidelines.

## Documentation

- [WORKFLOW.md](WORKFLOW.md) — Full workflow reference with all phases, principles, cost optimization, and tool-specific guides
- [CI_CD.md](CI_CD.md) — CI/CD pipeline design notes


## References

- [Superpowers](https://github.com/obra/superpowers) — composable skills, TDD-first, subagent-driven execution
- [GSD (Get Shit Done)](https://github.com/gsd-build/get-shit-done) — meta-prompting, wave-based parallel execution, context rot mitigation
- [Spec Kit](https://github.com/github/spec-kit) — spec-driven development, multi-agent support, extension ecosystem
- [EPCC Workflow](https://github.com/aws-solutions-library-samples/guidance-for-claude-code-with-amazon-bedrock/blob/main/assets/claude-code-plugins/README.md) — explore-plan-code-commit, session continuity, feature tracking
- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — reference for skill implementation and architecture
- [Anthropic Skills](https://github.com/anthropics/skills) — official skills reference
- [Agency Agents](https://github.com/msitarzewski/agency-agents) — role-based agent definitions (adapted into `agents/`)
- [PUA](https://github.com/tanweai/pua) — debugging persistence framework (adapted into Phase 4)

## License

MIT
