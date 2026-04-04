# Changelog

All notable changes to this project are documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versioned with [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.7] — 2026-04-04

### Fixed
- Documentation review: corrected skill counts (7→8) in WORKFLOW.md and CONTRIBUTING.md, fixed non-existent `fix-plan` review mode references in WORKFLOW.md to match actual `fix-plan-analysis` mode, added missing `init-project` and `auto` to Copilot CLI skill list in README.md.
- Removed stale 1.x→2.0.0 migration guide from README.md.

### Added
- CHANGELOG.md.

### Changed
- Reset versioning to 0.x (pre-1.0, not yet stable).
- Version bumps are now manual only (no longer auto-bumped on every change).

## Git History (pre-changelog)

Changes below predate the changelog. See `git log` for full details.

- `7058bda` — Review mode spawns independent subagent for fix plan; `fix-plan` renamed to `fix-plan-analysis`
- `b692cd5` — Version bump to 2.5.1
- `8c0089c` — Worktree concurrency warning in execute skill
- `a3608ba` — Add `/agentic-dev:auto` skill for full pipeline automation
- `a350142` — Align full review mode with blind-first fix-plan workflow
- `d6f3a12` — Blind-first structure for fix-plan validation mode
- `6b6927c` — Restructure fix-plan mode to prevent echo-chamber verification
- `97cccdd` — Remove `disable-model-invocation` from all skills
- `2fcc651` — Feature branch isolation for waves, fix-plan wave file resolution
- `bf2d2d4` — Version bump to 2.3.1
- `359245d` — Fix-plan mode now generates plans, not just validates
- `7cc7ea8` — Propagate Gemini CLI across all documentation
- `eb5f2e6` — Sync gemini-extension.json version, add to test checks
- `6f037f2` — Add CLAUDE.md for AI contributor instructions
- `da9dd02` — Version bump to 2.3.0
- `f117769` — Wave execution, branch lifecycle, merge workflow improvements
- `176ad53` — Add review skill; decouple agents from phases
- `9f2e22d` — Remove init.sh and example app
- `8b489b1` — Version bump to 2.1.2
- `fe634bf` — Add Gemini CLI extension support
- `02b49be` — Add explicit agent lists to phase skills
- `3b792f4` — Add Behavioral Contracts to agents
- `a2b4498` — Fix plugin manifest
- `5d70625` — Fix plugin manifest
- `7666718` — Skills-first architecture, Copilot CLI support, .agent.md format
- `3d0c400` — Update EPCC link in README
- `9516f5c` — Initial commit
