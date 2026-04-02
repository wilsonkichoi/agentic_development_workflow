# Development Instructions

This repo is an AI coding plugin distributed via Claude Code, Copilot CLI, and Gemini CLI.

## Core Principles

Changes to skills, agents, or workflow docs must preserve these invariants (from WORKFLOW.md):

1. **Human gates between phases.** Every phase produces reviewable artifacts. Nothing moves forward without human approval.
2. **One task per loop.** Tasks execute atomically with fresh context.
3. **Automated verification before human review.** Every task must pass checks before a human reviews the diff.
4. **Specs survive sessions.** Persistent documents bridge context between sessions.

## Version Bumping

When modifying skills, agents, or workflow behavior, bump the `version` field in **all three** manifest files. They must stay in sync. Use semver: patch for fixes, minor for features, major for breaking changes.

- `.claude-plugin/plugin.json` — Claude Code
- `plugin.json` (root) — Copilot CLI
- `gemini-extension.json` — Gemini CLI

## Multi-Tool Compatibility

Files must work across Claude Code, Copilot CLI, and Gemini CLI. Do not add tool-specific syntax to shared files (skills, agents). All three tools read:
- `agents/*.agent.md` — agent definitions
- `skills/*/SKILL.md` — skill definitions
- `CLAUDE.md` — project instructions

## Skill Authoring

- Skill descriptions must be "pushy" — include multiple trigger phrases (formal name, informal triggers, contextual triggers). AI tools undertrigger by default.

## Agent Authoring

- Agent `name` in frontmatter must match the filename (without `.agent.md`).
- Every agent must have a non-empty `description` in frontmatter.
- Keep agents 30-45 lines. If longer, you're over-specifying.

## Testing

Run `make test` before committing. It validates plugin structure, frontmatter, agent counts, and version consistency.
