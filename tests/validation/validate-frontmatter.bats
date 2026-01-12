#!/usr/bin/env bats
# Validation tests for YAML frontmatter in markdown files

PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."

# Helper to extract frontmatter
extract_frontmatter() {
    sed -n '/^---$/,/^---$/p' "$1" | sed '1d;$d'
}

# Helper to check if file has frontmatter
has_frontmatter() {
    head -1 "$1" | grep -q "^---$"
}

# ============================================================================
# Commands Frontmatter Validation
# ============================================================================

@test "all command files have frontmatter" {
    for file in "$PROJECT_ROOT"/commands/*.md; do
        run has_frontmatter "$file"
        [ "$status" -eq 0 ] || fail "Missing frontmatter in $(basename "$file")"
    done
}

@test "command files have valid YAML frontmatter" {
    for file in "$PROJECT_ROOT"/commands/*.md; do
        frontmatter=$(extract_frontmatter "$file")
        echo "$frontmatter" | yq eval '.' - > /dev/null 2>&1 || \
            fail "Invalid YAML in $(basename "$file")"
    done
}

@test "command files have 'name' field" {
    for file in "$PROJECT_ROOT"/commands/*.md; do
        frontmatter=$(extract_frontmatter "$file")
        name=$(echo "$frontmatter" | yq eval '.name // ""' -)
        [ -n "$name" ] || fail "Missing 'name' in $(basename "$file")"
    done
}

@test "ralph-loop.md has required fields" {
    file="$PROJECT_ROOT/commands/ralph-loop.md"
    frontmatter=$(extract_frontmatter "$file")

    name=$(echo "$frontmatter" | yq eval '.name // ""' -)
    [ -n "$name" ]

    # Check for description or other expected fields
    [ -n "$frontmatter" ]
}

# ============================================================================
# Agents Frontmatter Validation
# ============================================================================

@test "all agent files have frontmatter" {
    for file in "$PROJECT_ROOT"/agents/*.md; do
        run has_frontmatter "$file"
        [ "$status" -eq 0 ] || fail "Missing frontmatter in $(basename "$file")"
    done
}

@test "agent files have valid YAML frontmatter" {
    for file in "$PROJECT_ROOT"/agents/*.md; do
        frontmatter=$(extract_frontmatter "$file")
        echo "$frontmatter" | yq eval '.' - > /dev/null 2>&1 || \
            fail "Invalid YAML in $(basename "$file")"
    done
}

@test "agent files have 'name' field" {
    for file in "$PROJECT_ROOT"/agents/*.md; do
        frontmatter=$(extract_frontmatter "$file")
        name=$(echo "$frontmatter" | yq eval '.name // ""' -)
        [ -n "$name" ] || fail "Missing 'name' in $(basename "$file")"
    done
}

@test "product-manager agent exists and has correct name" {
    file="$PROJECT_ROOT/agents/product-manager.md"
    [ -f "$file" ]
    frontmatter=$(extract_frontmatter "$file")
    name=$(echo "$frontmatter" | yq eval '.name // ""' -)
    [[ "$name" == *"product"* ]] || [[ "$name" == *"manager"* ]] || \
        [[ "$name" == *"requirements"* ]]
}

@test "architect-reviewer agent exists and has correct name" {
    file="$PROJECT_ROOT/agents/architect-reviewer.md"
    [ -f "$file" ]
    frontmatter=$(extract_frontmatter "$file")
    name=$(echo "$frontmatter" | yq eval '.name // ""' -)
    [[ "$name" == *"architect"* ]] || [[ "$name" == *"design"* ]] || \
        [[ "$name" == *"reviewer"* ]]
}

@test "task-planner agent exists and has correct name" {
    file="$PROJECT_ROOT/agents/task-planner.md"
    [ -f "$file" ]
    frontmatter=$(extract_frontmatter "$file")
    name=$(echo "$frontmatter" | yq eval '.name // ""' -)
    [[ "$name" == *"task"* ]] || [[ "$name" == *"planner"* ]]
}

@test "spec-executor agent exists and has correct name" {
    file="$PROJECT_ROOT/agents/spec-executor.md"
    [ -f "$file" ]
    frontmatter=$(extract_frontmatter "$file")
    name=$(echo "$frontmatter" | yq eval '.name // ""' -)
    [[ "$name" == *"executor"* ]] || [[ "$name" == *"spec"* ]]
}

# ============================================================================
# Required Agents for Workflow
# ============================================================================

@test "all required agents exist" {
    required_agents=("product-manager.md" "architect-reviewer.md" "task-planner.md" "spec-executor.md")
    for agent in "${required_agents[@]}"; do
        [ -f "$PROJECT_ROOT/agents/$agent" ] || fail "Missing required agent: $agent"
    done
}

@test "all required commands exist" {
    required_commands=("ralph-loop.md" "approve.md" "implement.md" "cancel-ralph.md" "help.md")
    for cmd in "${required_commands[@]}"; do
        [ -f "$PROJECT_ROOT/commands/$cmd" ] || fail "Missing required command: $cmd"
    done
}

# ============================================================================
# Template Files Validation
# ============================================================================

@test "all required templates exist" {
    required_templates=("requirements.md" "design.md" "tasks.md" "progress.md")
    for template in "${required_templates[@]}"; do
        [ -f "$PROJECT_ROOT/templates/$template" ] || fail "Missing required template: $template"
    done
}

@test "requirements template has essential sections" {
    file="$PROJECT_ROOT/templates/requirements.md"
    grep -q "## Goal" "$file" || fail "Missing Goal section"
    grep -q "## User Stories" "$file" || fail "Missing User Stories section"
    grep -q "## Functional Requirements" "$file" || fail "Missing Functional Requirements section"
}

@test "design template has essential sections" {
    file="$PROJECT_ROOT/templates/design.md"
    grep -q "## Overview" "$file" || fail "Missing Overview section"
    grep -q "## Architecture" "$file" || fail "Missing Architecture section"
    grep -q "## Technical Decisions" "$file" || fail "Missing Technical Decisions section"
}

@test "tasks template has POC-first phases" {
    file="$PROJECT_ROOT/templates/tasks.md"
    grep -q "Phase 1.*Make It Work\|POC" "$file" || fail "Missing POC phase"
    grep -q "Phase 2.*Refactor" "$file" || fail "Missing Refactoring phase"
    grep -q "Phase 3.*Test" "$file" || fail "Missing Testing phase"
    grep -q "Phase 4.*Quality" "$file" || fail "Missing Quality Gates phase"
}
