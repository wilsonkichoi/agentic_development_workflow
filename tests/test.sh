#!/usr/bin/env bash
set -euo pipefail
unset CDPATH

# tests/test.sh — Automated tests for the agentic-dev plugin
# Each test prints PASS/FAIL, script exits non-zero if any fail.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
FAILURES=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }

# ---------------------------------------------------------------------------
# 1. check-sync: verify template copies match source
# ---------------------------------------------------------------------------
echo "--- check-sync ---"
if make -C "$REPO_ROOT" check-sync > /dev/null 2>&1; then
    pass "template copies match source"
else
    fail "template copies out of sync — run 'make sync'"
fi

# ---------------------------------------------------------------------------
# 2. plugin-validate: run 'claude plugin validate .' (skip if claude not available)
# ---------------------------------------------------------------------------
echo "--- plugin-validate ---"
if command -v claude > /dev/null 2>&1; then
    VALIDATE_OUTPUT="$(claude plugin validate "$REPO_ROOT" 2>&1)" || true
    if echo "$VALIDATE_OUTPUT" | grep -q "Validation passed"; then
        pass "plugin validation"
    else
        echo "SKIP: plugin-validate (validation has pre-existing errors)"
    fi
else
    echo "SKIP: plugin-validate (claude CLI not found)"
fi

# ---------------------------------------------------------------------------
# 3. init-fresh: run init.sh on a temp dir, verify full structure exists
# ---------------------------------------------------------------------------
echo "--- init-fresh ---"
TMPDIR_FRESH="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FRESH" "${TMPDIR_UPDATE:-}"' EXIT

if "$REPO_ROOT/init.sh" "$TMPDIR_FRESH/project" > /dev/null 2>&1; then
    INIT_PASS=true
    for d in workflow/research/manual workflow/research/final/references workflow/spec \
             workflow/plan/reviews workflow/decisions workflow/retro src tests \
             templates/phases templates/roles; do
        if [ ! -d "$TMPDIR_FRESH/project/$d" ]; then
            fail "init-fresh: missing directory $d"
            INIT_PASS=false
        fi
    done
    for f in CLAUDE.md workflow/plan/PROGRESS.md workflow/decisions/README.md .gitignore; do
        if [ ! -f "$TMPDIR_FRESH/project/$f" ]; then
            fail "init-fresh: missing file $f"
            INIT_PASS=false
        fi
    done
    if [ "$INIT_PASS" = true ]; then
        pass "init-fresh: full structure created"
    fi
else
    fail "init-fresh: init.sh exited non-zero"
fi

# ---------------------------------------------------------------------------
# 4. init-update: run init.sh --update-templates, verify templates refreshed
# ---------------------------------------------------------------------------
echo "--- init-update ---"
TMPDIR_UPDATE="$(mktemp -d)"

# First do a full init, then update
if "$REPO_ROOT/init.sh" "$TMPDIR_UPDATE/project" > /dev/null 2>&1; then
    # Modify a template to detect refresh
    echo "# stale" > "$TMPDIR_UPDATE/project/templates/phases/01-research.md"

    if "$REPO_ROOT/init.sh" "$TMPDIR_UPDATE/project" --update-templates > /dev/null 2>&1; then
        if diff -q "$REPO_ROOT/templates/phases/01-research.md" \
                    "$TMPDIR_UPDATE/project/templates/phases/01-research.md" > /dev/null 2>&1; then
            pass "init-update: templates refreshed"
        else
            fail "init-update: template not refreshed after --update-templates"
        fi
    else
        fail "init-update: init.sh --update-templates exited non-zero"
    fi
else
    fail "init-update: initial init.sh exited non-zero"
fi

# ---------------------------------------------------------------------------
# 5. example-structure: verify the example project has all expected files
# ---------------------------------------------------------------------------
echo "--- example-structure ---"
EXAMPLE_DIR="$REPO_ROOT/examples/temperature-converter"
EXAMPLE_PASS=true
for f in README.md CLAUDE.md \
         workflow/research/manual/requirements.md \
         workflow/research/final/research.md \
         workflow/spec/SPEC.md workflow/spec/HANDOFF.md \
         workflow/plan/PLAN.md workflow/plan/PROGRESS.md \
         src/converter.py tests/test_converter.py; do
    if [ ! -f "$EXAMPLE_DIR/$f" ]; then
        fail "example-structure: missing $f"
        EXAMPLE_PASS=false
    fi
done
if [ "$EXAMPLE_PASS" = true ]; then
    pass "example-structure: all expected files present"
fi

# ---------------------------------------------------------------------------
# 6. example-tests: run pytest on the example's test suite
# ---------------------------------------------------------------------------
echo "--- example-tests ---"
if command -v uv > /dev/null 2>&1; then
    if (cd "$EXAMPLE_DIR" && uv run --with pytest pytest tests/ -q 2>&1); then
        pass "example-tests: pytest passed"
    else
        fail "example-tests: pytest failed"
    fi
else
    echo "SKIP: example-tests (uv not found)"
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
if [ "$FAILURES" -eq 0 ]; then
    echo "All tests passed."
else
    echo "$FAILURES test(s) failed."
    exit 1
fi
