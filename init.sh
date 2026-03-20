#!/usr/bin/env bash
set -euo pipefail

# init.sh — Initialize a new project with the AI-Assisted Development Workflow
# Usage: ./init.sh <target-directory> [options]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    cat <<EOF
Usage: $(basename "$0") <target-directory> [options]

Initialize a new project with the AI-Assisted Development Workflow.

Options:
  --update-templates    Only update templates/ in an existing project
  -h, --help            Show this help

For Claude Code users, install the plugin instead (recommended):
  /plugin marketplace add wilsonkichoi/agentic_development_workflow
  /plugin install agentic-dev@wilsonkichoi-agentic-dev

Examples:
  $(basename "$0") /path/to/my-project          # Full init
  $(basename "$0") /path/to/my-project --update-templates  # Refresh templates only
EOF
}

# Parse args
TARGET=""
UPDATE_ONLY=false
INSTALL_SKILL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --update-templates) UPDATE_ONLY=true; shift ;;
        --install-skill) echo "Deprecated: use the Claude Code plugin instead."; echo "  /plugin marketplace add wilsonkichoi/agentic_development_workflow"; exit 0 ;;
        -h|--help) usage; exit 0 ;;
        -*) echo "Error: unknown option $1"; usage; exit 1 ;;
        *) TARGET="$1"; shift ;;
    esac
done

# --- Install skill mode (deprecated) ---

# --- Validate target ---
if [ -z "$TARGET" ]; then
    echo "Error: target directory required"
    echo ""
    usage
    exit 1
fi

# Create target if it doesn't exist
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

# --- Update templates only ---
if [ "$UPDATE_ONLY" = true ]; then
    if [ ! -d "$TARGET/templates" ]; then
        echo "Error: $TARGET/templates not found. Is this an initialized project?"
        exit 1
    fi

    echo "Updating templates in $TARGET..."
    rm -rf "$TARGET/templates/phases" "$TARGET/templates/roles"
    cp -r "$SCRIPT_DIR/templates/phases" "$TARGET/templates/phases"
    cp -r "$SCRIPT_DIR/templates/roles" "$TARGET/templates/roles"
    echo "Done. Templates updated."
    exit 0
fi

# --- Full initialization ---
echo "Initializing project at $TARGET..."

# Create directory structure
mkdir -p "$TARGET/workflow/research/manual"
mkdir -p "$TARGET/workflow/research/final/references"
mkdir -p "$TARGET/workflow/spec"
mkdir -p "$TARGET/workflow/plan/reviews"
mkdir -p "$TARGET/workflow/decisions"
mkdir -p "$TARGET/workflow/retro"
mkdir -p "$TARGET/src"
mkdir -p "$TARGET/tests"
mkdir -p "$TARGET/templates"

# Copy templates
cp -r "$SCRIPT_DIR/templates/phases" "$TARGET/templates/phases"
cp -r "$SCRIPT_DIR/templates/roles" "$TARGET/templates/roles"

# Create .gitkeep files for empty dirs
touch "$TARGET/workflow/research/manual/.gitkeep"
touch "$TARGET/workflow/research/final/references/.gitkeep"
touch "$TARGET/workflow/spec/.gitkeep"
touch "$TARGET/workflow/plan/reviews/.gitkeep"
touch "$TARGET/workflow/retro/.gitkeep"
touch "$TARGET/src/.gitkeep"
touch "$TARGET/tests/.gitkeep"

# Create PROGRESS.md
cat > "$TARGET/workflow/plan/PROGRESS.md" << 'EOF'
# Implementation Progress

Last updated: —

## Milestone 1: TBD

| Task | Title | Role | Status | Review | Notes |
|------|-------|------|--------|--------|-------|

## Spec Gaps Discovered
(none yet)

## Blocked Items
(none yet)
EOF

# Create decisions index
cat > "$TARGET/workflow/decisions/README.md" << 'EOF'
# Decision Records

| ID | Title | Phase | Status |
|----|-------|-------|--------|
EOF

# Generate README.md
cat > "$TARGET/README.md" << 'EOF'
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
EOF

# Generate CLAUDE.md
cat > "$TARGET/CLAUDE.md" << 'EOF'
# Project Instructions

## Project
- Name: {{PROJECT_NAME}}
- Description: {{ONE_LINE_DESCRIPTION}}

## Workflow

This project follows the AI-Assisted Software Development Workflow.
See `templates/phases/` for phase-specific prompts and `templates/roles/` for role definitions.

If you have the `agentic-dev` plugin installed, use:
- `/agentic-dev:research` — Phase 1
- `/agentic-dev:spec` — Phase 2
- `/agentic-dev:plan` — Phase 3
- `/agentic-dev:execute` — Phase 4
- `/agentic-dev:verify` — Phase 5

### Quick Reference

| Phase | Template | Mode |
|-------|----------|------|
| 1. Research | `templates/phases/01-research.md` | Normal |
| 2. Specification | `templates/phases/02-specification.md` | Plan/read-only |
| 3. Task Breakdown | `templates/phases/03-task-breakdown.md` | Normal |
| 4. Execution | `templates/phases/04-execution.md` | Worktree |
| 5. Verification | `templates/phases/05-verification.md` | Normal |

### Key Documents
- Spec: `workflow/spec/SPEC.md`
- Plan: `workflow/plan/PLAN.md`
- Progress: `workflow/plan/PROGRESS.md`
- Decisions: `workflow/decisions/`

## Architecture

{{FILL_IN_AFTER_PHASE_2 — architecture summary, 5-10 lines}}

## Build & Test

{{FILL_IN — e.g., npm install, npm test, npm run lint}}

## Tooling Preferences

{{FILL_IN — e.g., Package manager: uv, Python version: >=3.12, Linter: ruff, Formatter: ruff format}}

## Coding Standards

{{FILL_IN_AFTER_PHASE_2 — or link to workflow/spec/SPEC.md}}
EOF

# Generate .gitignore if it doesn't exist
if [ ! -f "$TARGET/.gitignore" ]; then
    cat > "$TARGET/.gitignore" << 'EOF'
# OS
.DS_Store
Thumbs.db

# Editor
.vscode/
.idea/
*.swp
*.swo

# Environment
.env
.env.local
EOF
fi

echo ""
echo "Project initialized at $TARGET"
echo ""
echo "Structure:"
echo "  workflow/research/manual/     — Place human research materials here"
echo "  workflow/research/final/      — AI research output goes here"
echo "  workflow/spec/                — SPEC.md and HANDOFF.md (Phase 2)"
echo "  workflow/plan/                — PLAN.md and PROGRESS.md (Phase 3-4)"
echo "  workflow/plan/reviews/        — Per-task review files (Phase 4)"
echo "  workflow/decisions/           — Architecture Decision Records"
echo "  workflow/retro/               — Retrospectives (Phase 5)"
echo "  templates/phases/         — Phase prompt templates"
echo "  templates/roles/          — Role definitions"
echo "  src/                      — Source code"
echo "  tests/                    — Tests"
echo "  CLAUDE.md                 — Project instructions (edit this first)"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md — fill in project name and description"
echo "  2. Place research materials in workflow/research/manual/"
echo "  3. Start Phase 1:"
echo "     - Claude Code plugin: /agentic-dev:research"
echo "     - Other tools: read templates/phases/01-research.md"
