# Project Instructions

## Project
- Name: Temperature Converter
- Description: CLI tool that converts between Celsius and Fahrenheit

## Workflow

This project follows the AI-Assisted Software Development Workflow.

### Key Documents
- Spec: `workflow/spec/SPEC.md`
- Plan: `workflow/plan/PLAN.md`
- Progress: `workflow/plan/PROGRESS.md`

## Architecture

Single-module Python CLI. `src/converter.py` provides:
- `celsius_to_fahrenheit(c)` — convert C to F
- `fahrenheit_to_celsius(f)` — convert F to C
- CLI entry point via `if __name__ == "__main__"`

No external dependencies. Python 3.12+.

## Build & Test

```bash
uv run pytest tests/ -q
uv run python src/converter.py 100 --to fahrenheit
uv run python src/converter.py 212 --to celsius
```

## Tooling Preferences

- Package manager: uv
- Python version: >=3.12
- Test runner: pytest (via `uv run --with pytest pytest`)

## Coding Standards

- Type hints on all public functions
- Docstrings on all public functions
- Round output to 2 decimal places
