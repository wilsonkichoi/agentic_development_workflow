#!/usr/bin/env bash
set -euo pipefail
unset CDPATH

# tests/test.sh — Automated tests for the agentic-dev plugin
# Each test prints PASS/FAIL, script exits non-zero if any fail.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
FAILURES=0

pass() { echo "PASS: $1"; }
fail() { echo "FAIL: $1"; FAILURES=$((FAILURES + 1)); }

# --- Helpers ---

# Extract a top-level string field from a JSON file using python3
json_field() {
    python3 -c "import json,sys; print(json.load(open(sys.argv[1]))[sys.argv[2]])" "$1" "$2"
}

# Extract a field value from YAML frontmatter (between first two --- lines)
# Handles both quoted ("value") and unquoted (value) forms
yaml_frontmatter_field() {
    sed -n '/^---$/,/^---$/{
        /^'"$2"':/{
            s/^[^:]*: *//
            s/^"//
            s/"$//
            s/[[:space:]]*$//
            p
            q
        }
    }' "$1"
}

# --- Temp dirs (created lazily, cleaned up on exit) ---
TMPDIR_FRESH=""
TMPDIR_IDEMP=""
cleanup() { rm -rf "${TMPDIR_FRESH:-}" "${TMPDIR_IDEMP:-}"; }
trap cleanup EXIT

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
# 4. skill-files: verify each skill has SKILL.md
# ---------------------------------------------------------------------------
echo "--- skill-files ---"
SKILL_PASS=true
for skill in research spec plan execute verify init-project review auto; do
    if [ ! -f "$REPO_ROOT/skills/$skill/SKILL.md" ]; then
        fail "skill-files: missing skills/$skill/SKILL.md"
        SKILL_PASS=false
    fi
done
if [ "$SKILL_PASS" = true ]; then
    pass "skill-files: all skills have SKILL.md"
fi

# ---------------------------------------------------------------------------
# 5. skill-frontmatter: SKILL.md has name matching dir and non-empty description
# ---------------------------------------------------------------------------
echo "--- skill-frontmatter ---"
SKILL_FM_PASS=true
for skill in research spec plan execute verify init-project review auto; do
    SKILL_FILE="$REPO_ROOT/skills/$skill/SKILL.md"
    if [ ! -f "$SKILL_FILE" ]; then
        # Already caught by skill-files test
        continue
    fi

    # Check frontmatter exists
    if ! head -1 "$SKILL_FILE" | grep -q '^---$'; then
        fail "skill-frontmatter: $skill/SKILL.md missing frontmatter"
        SKILL_FM_PASS=false
        continue
    fi

    # Check name field matches directory name
    FM_NAME="$(yaml_frontmatter_field "$SKILL_FILE" "name")"
    if [ -z "$FM_NAME" ]; then
        fail "skill-frontmatter: $skill/SKILL.md missing name field"
        SKILL_FM_PASS=false
    elif [ "$FM_NAME" != "$skill" ]; then
        fail "skill-frontmatter: $skill/SKILL.md name is '$FM_NAME', expected '$skill'"
        SKILL_FM_PASS=false
    fi

    # Check description field exists
    FM_DESC="$(yaml_frontmatter_field "$SKILL_FILE" "description")"
    if [ -z "$FM_DESC" ]; then
        fail "skill-frontmatter: $skill/SKILL.md missing description field"
        SKILL_FM_PASS=false
    fi
done
if [ "$SKILL_FM_PASS" = true ]; then
    pass "skill-frontmatter: all skills have valid name and description"
fi

# ---------------------------------------------------------------------------
# 6. agent-frontmatter: every .agent.md has a non-empty description
# ---------------------------------------------------------------------------
echo "--- agent-frontmatter ---"
AGENT_FM_PASS=true
for agent_file in "$REPO_ROOT"/agents/*.agent.md; do
    agent_name="$(basename "$agent_file")"
    if ! head -1 "$agent_file" | grep -q '^---$'; then
        fail "agent-frontmatter: $agent_name missing frontmatter"
        AGENT_FM_PASS=false
        continue
    fi
    FM_DESC="$(yaml_frontmatter_field "$agent_file" "description")"
    if [ -z "$FM_DESC" ]; then
        fail "agent-frontmatter: $agent_name missing or empty description"
        AGENT_FM_PASS=false
    fi
done
if [ "$AGENT_FM_PASS" = true ]; then
    pass "agent-frontmatter: all agents have description"
fi

# ---------------------------------------------------------------------------
# 7. agent-count: number of .agent.md files matches README claim
# ---------------------------------------------------------------------------
echo "--- agent-count ---"
# README line: | **Agents** | 13 | ... |
README_COUNT="$(sed -n 's/.*\*\*Agents\*\* *| *\([0-9][0-9]*\) *|.*/\1/p' "$REPO_ROOT/README.md")"
ACTUAL_COUNT="$(ls "$REPO_ROOT"/agents/*.agent.md 2>/dev/null | wc -l | tr -d ' ')"

if [ -z "$README_COUNT" ]; then
    fail "agent-count: could not parse agent count from README.md"
elif [ "$README_COUNT" -ne "$ACTUAL_COUNT" ]; then
    fail "agent-count: README claims $README_COUNT agents, found $ACTUAL_COUNT"
else
    pass "agent-count: $ACTUAL_COUNT agents match README"
fi

# ---------------------------------------------------------------------------
# 8. version-consistency: plugin.json versions match
# ---------------------------------------------------------------------------
echo "--- version-consistency ---"
ROOT_VERSION="$(json_field "$REPO_ROOT/plugin.json" "version")"
PLUGIN_VERSION="$(json_field "$REPO_ROOT/.claude-plugin/plugin.json" "version")"
GEMINI_VERSION="$(json_field "$REPO_ROOT/gemini-extension.json" "version")"

if [ -z "$ROOT_VERSION" ] || [ -z "$PLUGIN_VERSION" ] || [ -z "$GEMINI_VERSION" ]; then
    fail "version-consistency: could not parse version from manifest files"
elif [ "$ROOT_VERSION" != "$PLUGIN_VERSION" ] || [ "$ROOT_VERSION" != "$GEMINI_VERSION" ]; then
    fail "version-consistency: root=$ROOT_VERSION, .claude-plugin=$PLUGIN_VERSION, gemini=$GEMINI_VERSION"
else
    pass "version-consistency: all manifest files at v$ROOT_VERSION"
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
