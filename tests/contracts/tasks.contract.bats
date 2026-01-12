#!/usr/bin/env bats
# Contract tests for tasks.md template and generated specs

PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."
TEMPLATE="$PROJECT_ROOT/templates/tasks.md"

# ============================================================================
# Template Structure Contract
# ============================================================================

@test "CONTRACT: tasks template exists" {
    [ -f "$TEMPLATE" ]
}

@test "CONTRACT: tasks has Overview section" {
    grep -q "^## Overview" "$TEMPLATE"
}

# ============================================================================
# POC-First Workflow Contract (Critical)
# ============================================================================

@test "CONTRACT: tasks has Phase 1: Make It Work (POC)" {
    grep -q "Phase 1.*Make It Work\|Phase 1.*POC" "$TEMPLATE"
}

@test "CONTRACT: tasks has Phase 2: Refactoring" {
    grep -q "Phase 2.*Refactor" "$TEMPLATE"
}

@test "CONTRACT: tasks has Phase 3: Testing" {
    grep -q "Phase 3.*Test" "$TEMPLATE"
}

@test "CONTRACT: tasks has Phase 4: Quality Gates" {
    grep -q "Phase 4.*Quality" "$TEMPLATE"
}

@test "CONTRACT: POC phase explicitly skips tests" {
    grep -A5 "Phase 1" "$TEMPLATE" | grep -qi "skip tests\|without tests\|no tests"
}

# ============================================================================
# Task Structure Contract
# ============================================================================

@test "CONTRACT: tasks use checkbox format" {
    grep -q "\- \[ \]" "$TEMPLATE"
}

@test "CONTRACT: tasks have 'Do' field" {
    grep -q "\*\*Do\*\*:" "$TEMPLATE"
}

@test "CONTRACT: tasks have 'Files' field" {
    grep -q "\*\*Files\*\*:" "$TEMPLATE"
}

@test "CONTRACT: tasks have 'Done when' field" {
    grep -q "\*\*Done when\*\*:" "$TEMPLATE"
}

@test "CONTRACT: tasks have 'Verify' field" {
    grep -q "\*\*Verify\*\*:" "$TEMPLATE"
}

@test "CONTRACT: tasks have 'Commit' field" {
    grep -q "\*\*Commit\*\*:" "$TEMPLATE"
}

# ============================================================================
# Task Numbering Contract
# ============================================================================

@test "CONTRACT: Phase 1 tasks use 1.x numbering" {
    grep -q "1\.1\|1\.2\|1\.3" "$TEMPLATE"
}

@test "CONTRACT: Phase 2 tasks use 2.x numbering" {
    grep -q "2\.1\|2\.2\|2\.3" "$TEMPLATE"
}

@test "CONTRACT: Phase 3 tasks use 3.x numbering" {
    grep -q "3\.1\|3\.2\|3\.3" "$TEMPLATE"
}

@test "CONTRACT: Phase 4 tasks use 4.x numbering" {
    grep -q "4\.1\|4\.2\|4\.3" "$TEMPLATE"
}

# ============================================================================
# POC Checkpoint Contract
# ============================================================================

@test "CONTRACT: Phase 1 has POC Checkpoint task" {
    grep -q "POC Checkpoint\|checkpoint" "$TEMPLATE"
}

@test "CONTRACT: POC Checkpoint verifies end-to-end" {
    grep -A3 -i "checkpoint" "$TEMPLATE" | grep -qi "end-to-end\|demonstrated\|working"
}

# ============================================================================
# Refactoring Phase Contract
# ============================================================================

@test "CONTRACT: Refactoring includes extraction/modularization" {
    grep -A10 "Phase 2" "$TEMPLATE" | grep -qi "extract\|modular"
}

@test "CONTRACT: Refactoring includes error handling" {
    grep -A15 "Phase 2" "$TEMPLATE" | grep -qi "error handling"
}

@test "CONTRACT: Refactoring includes cleanup" {
    grep -A20 "Phase 2" "$TEMPLATE" | grep -qi "cleanup\|clean up"
}

# ============================================================================
# Testing Phase Contract
# ============================================================================

@test "CONTRACT: Testing phase includes unit tests" {
    grep -A10 "Phase 3" "$TEMPLATE" | grep -qi "unit test"
}

@test "CONTRACT: Testing phase includes integration tests" {
    grep -A15 "Phase 3" "$TEMPLATE" | grep -qi "integration test"
}

# ============================================================================
# Quality Gates Contract
# ============================================================================

@test "CONTRACT: Quality gates include local checks" {
    grep -A10 "Phase 4" "$TEMPLATE" | grep -qi "local\|quality check"
}

@test "CONTRACT: Quality gates include type checking" {
    grep -A15 "Phase 4" "$TEMPLATE" | grep -qi "type\|type check\|check-types"
}

@test "CONTRACT: Quality gates include linting" {
    grep -A15 "Phase 4" "$TEMPLATE" | grep -qi "lint"
}

@test "CONTRACT: Quality gates include CI verification" {
    grep -A20 "Phase 4" "$TEMPLATE" | grep -qi "CI\|continuous"
}

@test "CONTRACT: Quality gates include PR creation" {
    grep -A20 "Phase 4" "$TEMPLATE" | grep -qi "PR\|pull request"
}

# ============================================================================
# Traceability Contract
# ============================================================================

@test "CONTRACT: tasks reference Requirements" {
    grep -q "_Requirements:\|Requirements:" "$TEMPLATE" || \
    grep -q "FR-\|AC-" "$TEMPLATE"
}

@test "CONTRACT: tasks reference Design" {
    grep -q "_Design:\|Design:" "$TEMPLATE" || \
    grep -q "Component" "$TEMPLATE"
}

# ============================================================================
# Commit Message Contract
# ============================================================================

@test "CONTRACT: Commit messages use conventional format" {
    grep -q "feat(\|fix(\|refactor(\|test(" "$TEMPLATE"
}

# ============================================================================
# Dependencies Contract
# ============================================================================

@test "CONTRACT: tasks has Dependencies section or diagram" {
    grep -q "^## Dependencies\|Dependencies" "$TEMPLATE"
}

@test "CONTRACT: shows phase dependency flow" {
    grep -q "Phase 1.*→.*Phase 2\|POC.*→.*Refactor" "$TEMPLATE"
}

# ============================================================================
# Notes Contract
# ============================================================================

@test "CONTRACT: tasks has Notes section" {
    grep -q "^## Notes" "$TEMPLATE"
}

@test "CONTRACT: Notes documents POC shortcuts" {
    grep -qi "POC shortcuts\|shortcuts taken" "$TEMPLATE"
}
