# Implementation Plan

## Milestone 1: Core Conversion

### Wave 1: Conversion Logic and Tests

#### [x] Task 1.1: Implement conversion functions
- **Role:** Backend Engineer
- **Depends on:** none
- **Spec reference:** SPEC.md >> Components >> Module: `src/converter.py`
- **Files:** `src/converter.py`
- **Acceptance criteria:**
  - `celsius_to_fahrenheit(0)` returns `32.0`
  - `celsius_to_fahrenheit(100)` returns `212.0`
  - `fahrenheit_to_celsius(32)` returns `0.0`
  - `fahrenheit_to_celsius(212)` returns `100.0`
  - `celsius_to_fahrenheit(-40)` returns `-40.0`
- **Test command:** `uv run --with pytest pytest tests/ -q`

#### [x] Task 1.2: Write unit tests [TEST]
- **Role:** QA Engineer
- **Depends on:** 1.1
- **Spec reference:** SPEC.md >> Acceptance Criteria
- **Files:** `tests/test_converter.py`
- **Test scope:** Tests spec contract for Task 1.1. Do NOT read implementation.
- **Acceptance criteria:**
  - Tests cover all 5 conversion acceptance criteria from SPEC.md
  - Tests cover negative input and round-trip conversion
- **Test command:** `uv run --with pytest pytest tests/ -q`

### Wave 2: CLI Entry Point

#### [x] Task 1.3: Implement CLI entry point
- **Role:** Backend Engineer
- **Depends on:** 1.1
- **Spec reference:** SPEC.md >> Components >> CLI interface
- **Files:** `src/converter.py`
- **Acceptance criteria:**
  - `uv run python src/converter.py 100 --to fahrenheit` prints `212.00 F`
  - `uv run python src/converter.py 32 --to celsius` prints `0.00 C`
- **Test command:** `uv run python src/converter.py 100 --to fahrenheit`
