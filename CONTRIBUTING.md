# Contributing

Guide for working on the Agentic Development Workflow plugin.

## Repository Structure

```
.claude-plugin/          Claude Code plugin manifest + marketplace
  plugin.json            Name, version, description, keywords, component paths
  marketplace.json       Self-hosted marketplace for distribution
plugin.json              Copilot CLI plugin manifest
gemini-extension.json    Gemini CLI extension manifest

skills/                  Skills (8 total, each is a single SKILL.md)
  init-project/          /agentic-dev:init-project
  research/              /agentic-dev:research (Phase 1)
  spec/                  /agentic-dev:spec (Phase 2)
  plan/                  /agentic-dev:plan (Phase 3)
  execute/               /agentic-dev:execute (Phase 4)
  review/                /agentic-dev:review (Review loop)
  verify/                /agentic-dev:verify (Phase 5)
  auto/                  /agentic-dev:auto (Automated pipeline)

agents/                  Role-based agents (13 total, show in /agents)
  software-architect.agent.md
  backend-engineer.agent.md
  ...


WORKFLOW.md              Full workflow reference documentation
CI_CD.md                 CI/CD pipeline design notes
Makefile                 Build commands (test)

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
- Test the skill by running `claude --plugin-dir .` and invoking it.

### Example SKILL.md structure

```markdown
---
name: research
description: "Use for Phase 1... Also trigger on 'start research', 'phase 1', etc."
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
name: agent-name
description: "One-line description of when to use this agent."
---

You are a [role description].

## Priorities (in order)
1. ...

## Methodology
- ...

## Behavioral Contract

### ALWAYS:
- [positive instructions — what the agent must do]

### NEVER:
- [anti-patterns — what the agent must avoid]

## Output Format
[Optional — only for agents that produce structured deliverables]
```

### Agent guidelines

- The `name` field must match the filename (without `.agent.md`).
- The `description` field in YAML frontmatter is required — it's how Claude decides which agent to use and how it appears in `/agents`.
- Write the body as a system prompt (direct "You are..." instructions), not as documentation about the role.
- Keep agents focused on priorities, methodology, and behavioral contract. No fluff.
- Each agent should be 30-45 lines. If it's longer, you're probably over-specifying.
- Add an `## Output Format` section only for agents that produce structured deliverables (reviewers, QA).

### Multi-tool compatibility

Claude Code, Copilot CLI, and Gemini CLI all use `<name>.agent.md` as the agent file format and `skills/<name>/SKILL.md` for skills. The `.agent.md` and `SKILL.md` files are the canonical source of truth and are tracked in git. Do not add tool-specific syntax to these shared files.

## What to Pay Attention To

### Skill descriptions

Claude undertriggers skills by default. When writing or editing skill descriptions, include multiple phrasings: the formal name ("Phase 1"), informal triggers ("start research", "research phase"), and contextual triggers ("after placing materials in workflow/research/manual/").

### Agent descriptions

Every agent file must have a `description` in its YAML frontmatter. Without it, the agent won't appear properly in `/agents`.

### Plugin version

Bump the `version` field in all three manifests for releases: `.claude-plugin/plugin.json`, `plugin.json` (root), and `gemini-extension.json`. They must stay in sync. Users with auto-update enabled get the new version when the version changes.

## Testing Locally

Run the full automated test suite:

```bash
make test     # Runs tests/test.sh
```

The test suite (`tests/test.sh`) covers:
1. **plugin-validate** — `claude plugin validate .` (skipped if CLI not available)
2. **skill-files** — each skill has SKILL.md
3. **skill-frontmatter** — each SKILL.md has valid YAML frontmatter with `name:` matching directory and non-empty `description:`
4. **agent-frontmatter** — each `.agent.md` has YAML frontmatter with non-empty `description:`
5. **agent-count** — number of agents matches what README.md claims
6. **version-consistency** — `version` matches across all three manifests (`.claude-plugin/plugin.json`, `plugin.json`, `gemini-extension.json`)


For a complete pre-PR checklist, also do the manual checks:

```bash
# 1. Automated tests
make test

# 2. Load plugin and verify components
claude --plugin-dir .
# Then in the session:
#   /skills   → confirm all 8 skills appear
#   /agents   → confirm all 13 agents appear

# 3. Test skill invocations (spot check at minimum)
#   /agentic-dev:init-project /tmp/test-init
#   Verify /tmp/test-init has correct structure
#   rm -rf /tmp/test-init
```



## PR Guidelines

### PR description

Include:
- **What** changed and **why**
- Which components are affected (skills, agents, plugin manifest)
- How you tested the change

### Before submitting

1. Run `make test` — all tests must pass
2. Run `claude plugin validate .` — must pass
3. Test affected skills locally
4. Keep commits focused — one concern per commit
5. If this is a release, bump `version` in all three manifests (`.claude-plugin/plugin.json`, `plugin.json`, `gemini-extension.json`)

### Review criteria

PRs are reviewed for:
- Skill descriptions are trigger-friendly
- Agent descriptions are present

- No breaking changes to existing project structures
