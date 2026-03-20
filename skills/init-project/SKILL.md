---
name: init-project
description: "Use when someone asks to initialize a new project, scaffold a project, set up the development workflow, or create project structure. Also trigger on 'start new project', 'workflow setup', 'project scaffold', or 'init from template'. Even if they just say 'set up a new project', this skill is likely what they want."
argument-hint: [target-directory]
disable-model-invocation: true
---

## What This Skill Does

Scaffolds a new project with the AI-Assisted Development Workflow: directories for all 5 phases, role-based templates, placeholder files (PROGRESS.md, decisions index), and a starter CLAUDE.md.

## Steps

### Step 1: Determine the target directory

Target is `$ARGUMENTS`. If not provided, ask the user. Resolve relative paths against the current working directory.

### Step 2: Check if already initialized

If the target has `templates/phases/` and `workflow/plan/`, ask: update templates only, full re-init, or cancel.

### Step 3: Create directory structure

```bash
mkdir -p "$TARGET"/{workflow/{research/{manual,final/references},spec,plan/reviews,decisions,retro},src,tests,templates}
```

### Step 4: Copy templates from plugin

Copy the phase templates and role definitions into the project. The source templates are in this plugin's `templates/` directory.

```bash
cp -r "${CLAUDE_PLUGIN_ROOT}/templates/phases" "$TARGET/templates/phases"
cp -r "${CLAUDE_PLUGIN_ROOT}/templates/roles" "$TARGET/templates/roles"
```

If `${CLAUDE_PLUGIN_ROOT}` is not available, search for the templates:

```bash
PLUGIN_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-dev/*/templates/phases" -type d 2>/dev/null | head -1 | sed 's|/templates/phases$||')
```

If templates still can't be found, create the directories empty and tell the user to populate them manually.

### Step 5: Create placeholder files

Create `.gitkeep` in empty directories.

Create `workflow/plan/PROGRESS.md`:
```markdown
# Implementation Progress

Last updated: —

## Milestone 1: TBD

| Task | Title | Role | Status | Review | Notes |
|------|-------|------|--------|--------|-------|

## Spec Gaps Discovered
(none yet)

## Blocked Items
(none yet)
```

Create `workflow/decisions/README.md`:
```markdown
# Decision Records

| ID | Title | Phase | Status |
|----|-------|-------|--------|
```

### Step 6: Generate README.md

Create README.md with placeholder sections that phases will fill in:

```markdown
# {{PROJECT_NAME}}

{{ONE_LINE_DESCRIPTION}}

## Overview

{{FILL_IN_AFTER_PHASE_1 — problem statement, background, what this project does and why}}

## Getting Started

### Prerequisites

{{FILL_IN_AFTER_PHASE_2 — runtime version, system dependencies}}

### Installation

{{FILL_IN_AFTER_PHASE_2 — package manager setup, dependency installation}}

## Usage

{{FILL_IN_AFTER_PHASE_4 — examples, CLI reference, API quickstart}}

## Architecture

{{FILL_IN_AFTER_PHASE_2 — brief architecture overview with link to workflow/spec/SPEC.md}}

## Contributing

{{FILL_IN — contribution guidelines, or link to CONTRIBUTING.md}}

## License

{{FILL_IN — e.g., MIT}}
```

### Step 7: Generate CLAUDE.md

Create CLAUDE.md with project name placeholders, phase quick reference table, and key document links. Use the same template as in [template.md](template.md).

### Step 8: Create .gitignore if missing

Standard entries: .DS_Store, .env, editor directories.

### Step 9: Report next steps

1. Edit README.md and CLAUDE.md — fill in project name, description, and tooling preferences
2. Place research materials in `workflow/research/manual/`
3. Start Phase 1: `/agentic-dev:research`

## Important

- Do NOT overwrite existing project files without asking
- The `{{placeholders}}` in CLAUDE.md are for the human to fill in — do not resolve them
- Prefer using `${CLAUDE_PLUGIN_ROOT}` for template paths when available
