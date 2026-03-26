# Contributing

Guide for working on the Agentic Development Workflow plugin.

## Repository Structure

```
.claude-plugin/          Plugin manifest + marketplace definition
  plugin.json            Name, version, description, keywords, component paths
  marketplace.json       Self-hosted marketplace for distribution

skills/                  Skills (6 total, each is a single SKILL.md)
  init-project/          /agentic-dev:init-project
  research/              /agentic-dev:research (Phase 1)
  spec/                  /agentic-dev:spec (Phase 2)
  plan/                  /agentic-dev:plan (Phase 3)
  execute/               /agentic-dev:execute (Phase 4)
  verify/                /agentic-dev:verify (Phase 5)

agents/                  Role-based agents (13 total, show in /agents)
  software-architect.agent.md
  backend-engineer.agent.md
  ...

init.sh                  Project scaffolding (standalone, without plugin)
WORKFLOW.md              Full workflow reference documentation
CI_CD.md                 CI/CD pipeline design notes
Makefile                 Build commands (test)
examples/                Example projects showing workflow output
tests/                   Automated test suite
```

## Development Setup

```bash
# Clone the repo
git clone git@github.com:wilsonkichoi/agentic_development_workflow.git
cd agentic_development_workflow

# Test the plugin locally (skills + agents load into Claude Code)
claude --plugin-dir .

# Verify skills loaded
/skills          # Should show agentic-dev:init-project, research, spec, etc.

# Verify agents loaded
/agents          # Should show agentic-dev:software-architect, backend-engineer, etc.
```

## Working on Skills

Each skill lives in `skills/<name>/SKILL.md` — a single file containing YAML frontmatter and the full phase prompt.

### Skill guidelines

- Keep SKILL.md focused. The frontmatter defines metadata; the body is the prompt Claude follows.
- The `description` field in YAML frontmatter is the primary trigger mechanism. Make it "pushy" — include multiple phrasings of when to use it. Claude tends to undertrigger rather than overtrigger.
- `disable-model-invocation: true` means the skill is user-only (invoked via `/agentic-dev:<name>`). All our phase skills use this since they have side effects.
- Test the skill by running `claude --plugin-dir .` and invoking it.

### Example SKILL.md structure

```markdown
---
name: research
description: "Use for Phase 1... Also trigger on 'start research', 'phase 1', etc."
disable-model-invocation: true
---

## What This Skill Does
Brief description.

## Prompt
The full phase prompt with placeholders, instructions, constraints, etc.
```

## Working on Agents

Agent files live in `agents/` as `*.agent.md` files (compatible with both Claude Code and Copilot CLI). They appear in `/agents` when the plugin is installed.

### Agent file format

```markdown
---
description: "One-line description of when to use this agent."
---

You are a [role description].

## Priorities (in order)
1. ...

## Methodology
- ...

## Do NOT
- ...
```

### Agent guidelines

- The `description` field in YAML frontmatter is required — it's how Claude decides which agent to use and how it appears in `/agents`.
- Write the body as a system prompt (direct "You are..." instructions), not as documentation about the role.
- Keep agents focused on priorities, methodology, and anti-patterns. No fluff.
- Each agent should be 25-35 lines. If it's longer, you're probably over-specifying.

### Copilot CLI compatibility

Both Claude Code and Copilot CLI use `<name>.agent.md` as the agent file format. The `.agent.md` files are the canonical source of truth and are tracked in git.

## Working on init.sh

`init.sh` is a standalone scaffolding tool. It:

1. Creates the `workflow/` directory structure
2. Generates starter CLAUDE.md, PROGRESS.md, decisions/README.md, .gitignore

Note: `init.sh` no longer copies templates into projects. Phase prompts live in the plugin's `skills/` directory.

### Testing init.sh

```bash
# Test full init
./init.sh /tmp/test-project
ls -R /tmp/test-project          # Verify structure
cat /tmp/test-project/CLAUDE.md  # Verify generated content

# Clean up
rm -rf /tmp/test-project
```

Any change to the project folder structure (new directories, new placeholder files) must be reflected in init.sh.

## What to Pay Attention To

### Skill descriptions

Claude undertriggers skills by default. When writing or editing skill descriptions, include multiple phrasings: the formal name ("Phase 1"), informal triggers ("start research", "research phase"), and contextual triggers ("after placing materials in workflow/research/manual/").

### Agent descriptions

Every agent file must have a `description` in its YAML frontmatter. Without it, the agent won't appear properly in `/agents`.

### Plugin version

Bump the `version` field in `.claude-plugin/plugin.json` for releases. Users with auto-update enabled get the new version when the version changes.

### Don't break init.sh

If you change the project directory structure, update init.sh to match.

## Testing Locally

Run the full automated test suite:

```bash
make test     # Runs tests/test.sh
```

The test suite (`tests/test.sh`) covers:
1. **plugin-validate** — `claude plugin validate .` (skipped if CLI not available)
2. **init-fresh** — `init.sh` creates correct directory structure (no legacy template dirs)
3. **update-templates-deprecated** — `--update-templates` prints deprecation notice
4. **skill-files** — each skill has SKILL.md, no template.md
5. **no-stale-references** — no legacy template path references remain in source
6. **example-structure** — `examples/temperature-converter/` has all expected files
7. **example-tests** — pytest passes on the example project

For a complete pre-PR checklist, also do the manual checks:

```bash
# 1. Automated tests
make test

# 2. Load plugin and verify components
claude --plugin-dir .
# Then in the session:
#   /skills   → confirm all 6 skills appear
#   /agents   → confirm all 13 agents appear

# 3. Test skill invocations (spot check at minimum)
#   /agentic-dev:init-project /tmp/test-init
#   Verify /tmp/test-init has correct structure
#   rm -rf /tmp/test-init
```

The `examples/temperature-converter/` directory serves as the canonical reference for what "good output" looks like at each phase. See its [README](examples/temperature-converter/README.md) for a walkthrough.

## PR Guidelines

### PR description

Include:
- **What** changed and **why**
- Which components are affected (skills, agents, init.sh, plugin manifest)
- How you tested the change

### Before submitting

1. Run `make test` — all tests must pass
2. Run `claude plugin validate .` — must pass
3. Test affected skills or init.sh locally
4. Keep commits focused — one concern per commit
5. If this is a release, bump `version` in `.claude-plugin/plugin.json`

### Review criteria

PRs are reviewed for:
- Skill descriptions are trigger-friendly
- Agent descriptions are present
- init.sh reflects any structural changes
- No breaking changes to existing project structures
