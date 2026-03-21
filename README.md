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
| **Templates** | 5 | Phase prompt templates (copy-paste ready for any AI tool) |
| **Role Definitions** | 13 | Role prompts for non-Claude-Code tools |

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

### Other AI Tools (Copilot CLI, Cursor, Windsurf, Codex, Gemini)

```bash
# Clone the repo
git clone https://github.com/wilsonkichoi/agentic_development_workflow.git

# Initialize a new project
./agentic_development_workflow/init.sh /path/to/my-project
```

This copies phase templates and role definitions into your project. Use them by copy-pasting into your tool.

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

### init.sh Projects

```bash
# Refresh templates in an existing project (preserves all project docs)
./agentic_development_workflow/init.sh /path/to/my-project --update-templates
```

## Usage

### Starting a New Project

```bash
# Claude Code (from parent directory)
/agentic-dev:init-project ./my-project

# Claude Code (already inside the project directory)
/agentic-dev:init-project .

# Other tools
./agentic_development_workflow/init.sh ./my-project
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
├── templates/                # Phase templates + role definitions
├── src/
└── tests/
```

### Running Phases

**Claude Code plugin:**

| Phase | Command | What It Does |
|-------|---------|-------------|
| 1. Research | `/agentic-dev:research` | AI deep research on materials in `workflow/research/manual/` |
| 2. Specification | `/agentic-dev:spec` | Generate SPEC.md with milestones, schemas, contracts |
| 3. Task Breakdown | `/agentic-dev:plan` | Decompose into atomic tasks with wave grouping |
| 4. Execution | `/agentic-dev:execute` | Implement one task with role-matched agent |
| 5. Verification | `/agentic-dev:verify` | End-to-end testing + retrospective |

**Other tools:** Open the corresponding template from `templates/phases/`, fill in the placeholders, paste into your tool.

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
- [templates/roles/README.md](templates/roles/README.md) — Role registry with phase-to-role mapping
- [examples/temperature-converter/](examples/temperature-converter/) — End-to-end example showing expected output of each workflow phase

## References

- [Superpowers](https://github.com/obra/superpowers) — composable skills, TDD-first, subagent-driven execution
- [GSD (Get Shit Done)](https://github.com/gsd-build/get-shit-done) — meta-prompting, wave-based parallel execution, context rot mitigation
- [Spec Kit](https://github.com/github/spec-kit) — spec-driven development, multi-agent support, extension ecosystem
- [EPCC Workflow](https://github.com/aws-solutions-library-samples/guidance-for-claude-code-with-amazon-bedrock/blob/main/assets/claude-code-plugins/README.md) — explore-plan-code-commit, session continuity, feature tracking
- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) — reference for skill implementation and architecture
- [Anthropic Skills](https://github.com/anthropics/skills) — official skills reference
- [Agency Agents](https://github.com/msitarzewski/agency-agents) — role-based agent definitions (adapted into `templates/roles/`)
- [PUA](https://github.com/tanweai/pua) — debugging persistence framework (adapted into Phase 4)

## License

MIT
