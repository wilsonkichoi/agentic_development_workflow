# Handoff: Temperature Converter

## Document Index

| Document | Location | Purpose |
|----------|----------|---------|
| Spec | `workflow/spec/SPEC.md` | Architecture, API contracts, acceptance criteria |
| Handoff | `workflow/spec/HANDOFF.md` | This file — execution guidance for Phase 3 |
| Research | `workflow/research/final/research.md` | Research findings and tech stack rationale |
| Requirements | `workflow/research/manual/requirements.md` | Original human requirements |

## Milestone Ordering

Only one milestone: **Core Conversion**. No ordering constraints.

## Execution Sequence

1. Conversion functions (`celsius_to_fahrenheit`, `fahrenheit_to_celsius`) — no dependencies
2. Unit tests — can be written in parallel from spec (test separation)
3. CLI entry point — depends on conversion functions existing

## Acceptance Criteria

**Milestone 1 is complete when:**
- All 7 acceptance criteria from SPEC.md pass
- Unit tests pass via `uv run --with pytest pytest tests/ -q`
- CLI produces correct output for both conversion directions

## Known Risks

None — this is a trivial conversion with well-defined math and no external dependencies.
