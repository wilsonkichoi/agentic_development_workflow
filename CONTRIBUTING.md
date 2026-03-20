# Contributing

Guide for working on the Agentic Development Workflow plugin.

## Repository Structure

```
.claude-plugin/          Plugin manifest + marketplace definition
  plugin.json            Name, version, description, keywords
  marketplace.json       Self-hosted marketplace for distribution

skills/                  Claude Code skills (6 total)
  init-project/          /agentic-dev:init-project
  research/              /agentic-dev:research (Phase 1)
  spec/                  /agentic-dev:spec (Phase 2)
  plan/                  /agentic-dev:plan (Phase 3)
  execute/               /agentic-dev:execute (Phase 4)
  verify/                /agentic-dev:verify (Phase 5)
    SKILL.md             Skill definition (loaded when invoked)
    template.md          Phase template (supporting file, COPY of templates/phases/)

agents/                  Role-based agents (13 total, show in /agents)
  software-architect.md
  backend-engineer.md
  ...

templates/               Source of truth for phase templates + role definitions
  phases/                Phase prompt templates (copied to projects by init.sh)
  roles/                 Role definitions (copied to projects by init.sh)

init.sh                  Project scaffolding for non-Claude-Code tools
WORKFLOW.md              Full workflow reference documentation
CI_CD.md                 CI/CD pipeline design notes
Makefile                 Build commands (sync, check-sync, test, diff)
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

## Working on Templates

Phase templates have **two copies** that must stay in sync:

| Source of truth | Copy (bundled with plugin) |
|-----------------|---------------------------|
| `templates/phases/01-research.md` | `skills/research/template.md` |
| `templates/phases/02-specification.md` | `skills/spec/template.md` |
| `templates/phases/03-task-breakdown.md` | `skills/plan/template.md` |
| `templates/phases/04-execution.md` | `skills/execute/template.md` |
| `templates/phases/05-verification.md` | `skills/verify/template.md` |

**Always edit `templates/phases/` first**, then sync:

```bash
# After editing any file in templates/phases/
make sync         # Copies templates → skill bundles
make check-sync   # Verifies all copies match
```

Never edit `skills/*/template.md` directly — it will be overwritten by `make sync`.

## Working on Skills

Each skill lives in `skills/<name>/` with two files:

- **SKILL.md** — The skill definition. Loaded into Claude's context when the skill is invoked. Contains: YAML frontmatter (name, description, triggers), orchestration instructions, references to template.md.
- **template.md** — The phase template (supporting file). Referenced from SKILL.md via `[template.md](template.md)`. Claude reads it on demand.

### Skill guidelines

- Keep SKILL.md under 500 lines. If it's getting long, move detail into supporting files.
- The `description` field in YAML frontmatter is the primary trigger mechanism. Make it "pushy" — include multiple phrasings of when to use it. Claude tends to undertrigger rather than overtrigger.
- `disable-model-invocation: true` means the skill is user-only (invoked via `/agentic-dev:<name>`). All our phase skills use this since they have side effects.
- Test the skill by running `claude --plugin-dir .` and invoking it.

### Example SKILL.md structure

```yaml
---
name: research
description: "Use for Phase 1... Also trigger on 'start research', 'phase 1', etc."
disable-model-invocation: true
---
```

```markdown
## What This Skill Does
Brief description.

## Instructions
Read [template.md](template.md) for the detailed phase template.
Key points and Claude-Code-specific instructions here.

## Output
What gets produced.
```

## Working on Agents

Agent files live in `agents/` as standalone markdown files. They appear in `/agents` when the plugin is installed.

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

## Working on init.sh

`init.sh` is the fallback scaffolding tool for users who don't use Claude Code (Copilot CLI, Cursor, Windsurf, etc.). It:

1. Creates the `workflow/` directory structure
2. Copies `templates/phases/` and `templates/roles/` into the project
3. Generates starter CLAUDE.md, PROGRESS.md, decisions/README.md, .gitignore

### Testing init.sh

```bash
# Test full init
./init.sh /tmp/test-project
ls -R /tmp/test-project          # Verify structure
cat /tmp/test-project/CLAUDE.md  # Verify generated content

# Test template update
./init.sh /tmp/test-project --update-templates
diff templates/phases/01-research.md /tmp/test-project/templates/phases/01-research.md  # Should match

# Clean up
rm -rf /tmp/test-project
```

Any change to the project folder structure (new directories, new placeholder files) must be reflected in init.sh.

## What to Pay Attention To

### Template / skill drift

The most common mistake. If you edit a phase template but forget `make sync`, the plugin skill will serve stale content. Always run `make check-sync` before committing.

### Skill descriptions

Claude undertriggers skills by default. When writing or editing skill descriptions, include multiple phrasings: the formal name ("Phase 1"), informal triggers ("start research", "research phase"), and contextual triggers ("after placing materials in workflow/research/manual/").

### Agent descriptions

Every agent file must have a `description` in its YAML frontmatter. Without it, the agent won't appear properly in `/agents`.

### Plugin version

Bump the `version` field in `.claude-plugin/plugin.json` for releases. Users with auto-update enabled get the new version when the version changes.

### Don't break init.sh

Non-Claude-Code users depend on init.sh. If you add a new directory to the project structure, add it to init.sh too. If you add a new role, add it to `templates/roles/` (init.sh copies this whole directory).

### Two audiences

Every structural change potentially affects both:
1. **Plugin users** — skills in `skills/`, agents in `agents/`
2. **init.sh users** — templates in `templates/phases/`, roles in `templates/roles/`

## Testing Locally

Run the full automated test suite:

```bash
make test     # Runs tests/test.sh — check-sync, init.sh, example validation, pytest
```

The test suite (`tests/test.sh`) covers:
1. **check-sync** — template copies match source
2. **plugin-validate** — `claude plugin validate .` (skipped if CLI not available)
3. **init-fresh** — `init.sh` creates correct directory structure
4. **init-update** — `init.sh --update-templates` refreshes templates
5. **example-structure** — `examples/temperature-converter/` has all expected files
6. **example-tests** — pytest passes on the example project

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
- Which components are affected (skills, agents, templates, init.sh, plugin manifest)
- Whether `make sync` was run (if templates changed)
- How you tested the change

### Before submitting

1. Run `make test` — all tests must pass
2. Run `claude plugin validate .` — must pass
3. Test affected skills or init.sh locally
4. Keep commits focused — one concern per commit
5. If this is a release, bump `version` in `.claude-plugin/plugin.json`

### Review criteria

PRs are reviewed for:
- Template/skill sync (no drift)
- Both audiences served (plugin users AND init.sh users)
- Skill descriptions are trigger-friendly
- Agent descriptions are present
- init.sh reflects any structural changes
- No breaking changes to existing project structures
