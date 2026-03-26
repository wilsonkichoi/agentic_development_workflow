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
# 1. plugin-validate: run 'claude plugin validate .' (skip if claude not available)
# ---------------------------------------------------------------------------
echo "--- plugin-validate ---"
if command -v claude > /dev/null 2>&1; then
    VALIDATE_OUTPUT="$(claude plugin validate "$REPO_ROOT" 2>&1)" || true
    if echo "$VALIDATE_OUTPUT" | grep -q "Validation passed"; then
        pass "plugin validation"
    else
        fail "plugin validation: $VALIDATE_OUTPUT"
    fi
else
    echo "SKIP: plugin-validate (claude CLI not found)"
fi

# ---------------------------------------------------------------------------
# 2. init-fresh: run init.sh on a temp dir, verify full structure exists
# ---------------------------------------------------------------------------
echo "--- init-fresh ---"
TMPDIR_FRESH="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_FRESH" "${TMPDIR_DEPRECATE:-}"' EXIT

if "$REPO_ROOT/init.sh" "$TMPDIR_FRESH/project" > /dev/null 2>&1; then
    INIT_PASS=true
    for d in workflow/research/manual workflow/research/final/references workflow/spec \
             workflow/plan/reviews workflow/decisions workflow/retro src tests; do
        if [ ! -d "$TMPDIR_FRESH/project/$d" ]; then
            fail "init-fresh: missing directory $d"
            INIT_PASS=false
        fi
    done
    # Verify templates/ is NOT created
    if [ -d "$TMPDIR_FRESH/project/templates" ]; then
        fail "init-fresh: templates/ directory should not exist"
        INIT_PASS=false
    fi
    for f in CLAUDE.md workflow/plan/PROGRESS.md workflow/decisions/README.md .gitignore; do
        if [ ! -f "$TMPDIR_FRESH/project/$f" ]; then
            fail "init-fresh: missing file $f"
            INIT_PASS=false
        fi
    done
    # Verify CLAUDE.md uses skills-first format (no template references)
    if grep -q "templates/" "$TMPDIR_FRESH/project/CLAUDE.md" 2>/dev/null; then
        fail "init-fresh: CLAUDE.md still references templates/"
        INIT_PASS=false
    fi
    if [ "$INIT_PASS" = true ]; then
        pass "init-fresh: full structure created"
    fi
else
    fail "init-fresh: init.sh exited non-zero"
fi

# ---------------------------------------------------------------------------
# 3. update-templates-deprecated: verify --update-templates prints deprecation
# ---------------------------------------------------------------------------
echo "--- update-templates-deprecated ---"
TMPDIR_DEPRECATE="$(mktemp -d)"

DEPRECATE_OUTPUT="$("$REPO_ROOT/init.sh" "$TMPDIR_DEPRECATE/project" --update-templates 2>&1)" || true
if echo "$DEPRECATE_OUTPUT" | grep -qi "deprecated"; then
    pass "update-templates-deprecated: prints deprecation notice"
else
    fail "update-templates-deprecated: expected deprecation notice"
fi

# ---------------------------------------------------------------------------
# 4. skill-files: verify each skill has SKILL.md but no template.md
# ---------------------------------------------------------------------------
echo "--- skill-files ---"
SKILL_PASS=true
for skill in research spec plan execute verify init-project; do
    if [ ! -f "$REPO_ROOT/skills/$skill/SKILL.md" ]; then
        fail "skill-files: missing skills/$skill/SKILL.md"
        SKILL_PASS=false
    fi
    if [ -f "$REPO_ROOT/skills/$skill/template.md" ]; then
        fail "skill-files: skills/$skill/template.md should not exist"
        SKILL_PASS=false
    fi
done
if [ "$SKILL_PASS" = true ]; then
    pass "skill-files: all skills have SKILL.md, no template.md"
fi

# ---------------------------------------------------------------------------
# 5. no-stale-references: verify no remaining templates/ references in source
# ---------------------------------------------------------------------------
echo "--- no-stale-references ---"
# Exclude .git, local_notes, this test file, MEMORY.md, and top-level docs
# (README.md, CONTRIBUTING.md, and WORKFLOW.md legitimately mention templates/
# in migration guides, deprecation notices, and test descriptions)
STALE_REFS="$(grep -r "templates/" "$REPO_ROOT" \
    --include="*.md" --include="*.sh" --include="Makefile" --include="*.json" \
    -l 2>/dev/null \
    | grep -v ".git/" \
    | grep -v "local_notes/" \
    | grep -v "tests/test.sh" \
    | grep -v "MEMORY.md" \
    | grep -v "README.md" \
    | grep -v "CONTRIBUTING.md" \
    | grep -v "WORKFLOW.md" \
    || true)"
if [ -z "$STALE_REFS" ]; then
    pass "no-stale-references: no templates/ references found"
else
    fail "no-stale-references: found templates/ references in: $STALE_REFS"
fi

# ---------------------------------------------------------------------------
# 6. example-structure: verify the example project has all expected files
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
# 7. example-tests: run pytest on the example's test suite
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
