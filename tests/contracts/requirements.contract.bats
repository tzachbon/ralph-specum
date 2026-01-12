#!/usr/bin/env bats
# Contract tests for requirements.md template and generated specs

PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."
TEMPLATE="$PROJECT_ROOT/templates/requirements.md"

# ============================================================================
# Template Structure Contract
# ============================================================================

@test "CONTRACT: requirements template exists" {
    [ -f "$TEMPLATE" ]
}

@test "CONTRACT: requirements has Goal section" {
    grep -q "^## Goal" "$TEMPLATE"
}

@test "CONTRACT: requirements has User Stories section" {
    grep -q "^## User Stories" "$TEMPLATE"
}

@test "CONTRACT: requirements has Functional Requirements section" {
    grep -q "^## Functional Requirements" "$TEMPLATE"
}

@test "CONTRACT: requirements has Non-Functional Requirements section" {
    grep -q "^## Non-Functional Requirements" "$TEMPLATE"
}

@test "CONTRACT: requirements has Glossary section" {
    grep -q "^## Glossary" "$TEMPLATE"
}

@test "CONTRACT: requirements has Out of Scope section" {
    grep -q "^## Out of Scope" "$TEMPLATE"
}

@test "CONTRACT: requirements has Dependencies section" {
    grep -q "^## Dependencies" "$TEMPLATE"
}

@test "CONTRACT: requirements has Success Criteria section" {
    grep -q "^## Success Criteria" "$TEMPLATE"
}

@test "CONTRACT: requirements has Risks section" {
    grep -q "^## Risks" "$TEMPLATE"
}

# ============================================================================
# User Story Format Contract
# ============================================================================

@test "CONTRACT: User Stories use standard format (As a/I want to/So that)" {
    grep -q "\*\*As a\*\*" "$TEMPLATE"
    grep -q "\*\*I want to\*\*" "$TEMPLATE"
    grep -q "\*\*So that\*\*" "$TEMPLATE"
}

@test "CONTRACT: User Stories have Acceptance Criteria" {
    grep -q "\*\*Acceptance Criteria:\*\*" "$TEMPLATE" || \
    grep -q "Acceptance Criteria" "$TEMPLATE"
}

@test "CONTRACT: Acceptance Criteria use AC- prefix" {
    grep -q "AC-" "$TEMPLATE"
}

@test "CONTRACT: User Stories have US- prefix" {
    grep -q "US-" "$TEMPLATE" || grep -q "### US-" "$TEMPLATE"
}

# ============================================================================
# Requirements ID Format Contract
# ============================================================================

@test "CONTRACT: Functional Requirements use FR- prefix" {
    grep -q "FR-" "$TEMPLATE"
}

@test "CONTRACT: Non-Functional Requirements use NFR- prefix" {
    grep -q "NFR-" "$TEMPLATE"
}

@test "CONTRACT: Requirements table has Priority column" {
    grep -q "Priority" "$TEMPLATE"
}

# ============================================================================
# Completeness Contract
# ============================================================================

@test "CONTRACT: Template has placeholders for customization" {
    # Check for template placeholders
    grep -q "{{" "$TEMPLATE"
}

@test "CONTRACT: Template includes feature name placeholder" {
    grep -q "{{FEATURE_NAME}}" "$TEMPLATE" || grep -q "FEATURE_NAME" "$TEMPLATE"
}

# ============================================================================
# Table Structure Contract
# ============================================================================

@test "CONTRACT: Functional Requirements is a markdown table" {
    # Should have table header separator
    grep -A2 "^## Functional Requirements" "$TEMPLATE" | grep -q "|.*|"
}

@test "CONTRACT: Non-Functional Requirements is a markdown table" {
    grep -A2 "^## Non-Functional Requirements" "$TEMPLATE" | grep -q "|.*|"
}

@test "CONTRACT: Risks section is a markdown table" {
    grep -A2 "^## Risks" "$TEMPLATE" | grep -q "|.*|"
}
