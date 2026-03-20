# Specification: Temperature Converter

## Milestones

### Milestone 1: Core Conversion (only milestone)

Deliver a working CLI tool that converts between Celsius and Fahrenheit.

## System Architecture

Single-module Python CLI application. No services, no networking, no persistence.

```
CLI (argparse) --> converter functions --> stdout
```

**Technology choices:**
- Python 3.12+ (requirement)
- `argparse` for CLI (stdlib, zero dependencies)

**Justification for single-file approach:** The scope is two pure functions and a CLI entry point. A package structure would be over-engineering.

## API Contracts

**Module: `src/converter.py` — Public API:**

```python
def celsius_to_fahrenheit(celsius: float) -> float:
    """Convert Celsius to Fahrenheit. Result rounded to 2 decimal places."""

def fahrenheit_to_celsius(fahrenheit: float) -> float:
    """Convert Fahrenheit to Celsius. Result rounded to 2 decimal places."""
```

**CLI interface:**

```
python src/converter.py <value> --to celsius|fahrenheit
```

- `<value>` — numeric temperature (int or float)
- `--to` — target unit, required, one of `celsius` or `fahrenheit`
- Output format: `<value> <unit>` (e.g., `212.00 F`)
- Exit code: 0 on success, non-zero on invalid input (handled by argparse)

## Coding Standards

- Type hints on all public functions
- Docstrings on all public functions
- Round output to 2 decimal places
- No global state

## Non-Functional Requirements

- No performance targets needed (instant computation)
- No security requirements (no user data, no networking)

## Negative Requirements

- No Kelvin support
- No interactive mode
- No absolute zero validation
- No configuration files
- No external dependencies

## Acceptance Criteria

1. `celsius_to_fahrenheit(0)` returns `32.0`
2. `celsius_to_fahrenheit(100)` returns `212.0`
3. `fahrenheit_to_celsius(32)` returns `0.0`
4. `fahrenheit_to_celsius(212)` returns `100.0`
5. `celsius_to_fahrenheit(-40)` returns `-40.0`
6. CLI: `python src/converter.py 100 --to fahrenheit` prints `212.00 F`
7. CLI: `python src/converter.py 32 --to celsius` prints `0.00 C`
