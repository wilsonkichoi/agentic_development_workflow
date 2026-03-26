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
  -h, --help            Show this help

For Claude Code users, install the plugin instead (recommended):
  /plugin marketplace add wilsonkichoi/agentic_development_workflow
  /plugin install agentic-dev@wilsonkichoi-agentic-dev

For Copilot CLI users:
  copilot plugin install wilsonkichoi/agentic_development_workflow

Examples:
  $(basename "$0") /path/to/my-project          # Full init
EOF
}

# Parse args
TARGET=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --update-templates) echo "Deprecated: templates are no longer copied into projects."; echo "Phase prompts are now part of the plugin's skills. Install the plugin to get updates."; exit 0 ;;
        --install-skill) echo "Deprecated: use the Claude Code plugin instead."; echo "  /plugin marketplace add wilsonkichoi/agentic_development_workflow"; exit 0 ;;
        -h|--help) usage; exit 0 ;;
        -*) echo "Error: unknown option $1"; usage; exit 1 ;;
        *) TARGET="$1"; shift ;;
    esac
done

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

| Phase | Skill | Mode |
|-------|-------|------|
| 1. Research | `/agentic-dev:research` | Normal |
| 2. Specification | `/agentic-dev:spec` | Plan/read-only |
| 3. Task Breakdown | `/agentic-dev:plan` | Normal |
| 4. Execution | `/agentic-dev:execute` | Worktree |
| 5. Verification | `/agentic-dev:verify` | Normal |

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
echo "  src/                          — Source code"
echo "  tests/                        — Tests"
echo "  CLAUDE.md                     — Project instructions (edit this first)"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md — fill in project name and description"
echo "  2. Place research materials in workflow/research/manual/"
echo "  3. Start Phase 1:"
echo "     - Claude Code: /agentic-dev:research"
echo "     - Copilot CLI: /agentic-dev:research"
