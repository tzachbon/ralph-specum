#!/usr/bin/env bats
# Contract tests for design.md template and generated specs

PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."
TEMPLATE="$PROJECT_ROOT/templates/design.md"

# ============================================================================
# Template Structure Contract
# ============================================================================

@test "CONTRACT: design template exists" {
    [ -f "$TEMPLATE" ]
}

@test "CONTRACT: design has Overview section" {
    grep -q "^## Overview" "$TEMPLATE"
}

@test "CONTRACT: design has Architecture section" {
    grep -q "^## Architecture" "$TEMPLATE"
}

@test "CONTRACT: design has Technical Decisions section" {
    grep -q "^## Technical Decisions" "$TEMPLATE"
}

@test "CONTRACT: design has File Structure section" {
    grep -q "^## File Structure" "$TEMPLATE"
}

@test "CONTRACT: design has Interfaces section" {
    grep -q "^## Interfaces" "$TEMPLATE"
}

@test "CONTRACT: design has Error Handling section" {
    grep -q "^## Error Handling" "$TEMPLATE"
}

@test "CONTRACT: design has Edge Cases section" {
    grep -q "^## Edge Cases" "$TEMPLATE"
}

@test "CONTRACT: design has Test Strategy section" {
    grep -q "^## Test Strategy" "$TEMPLATE"
}

# ============================================================================
# Architecture Subsections Contract
# ============================================================================

@test "CONTRACT: Architecture has Component Diagram" {
    grep -q "Component Diagram\|### Component" "$TEMPLATE"
}

@test "CONTRACT: Architecture has Components subsection" {
    grep -q "### Components\|#### Component" "$TEMPLATE"
}

@test "CONTRACT: Architecture has Data Flow" {
    grep -q "Data Flow" "$TEMPLATE"
}

# ============================================================================
# Diagram Format Contract
# ============================================================================

@test "CONTRACT: design includes mermaid diagram syntax" {
    grep -q '```mermaid' "$TEMPLATE"
}

@test "CONTRACT: design has component diagram in mermaid" {
    grep -q "graph TB\|graph LR\|flowchart" "$TEMPLATE"
}

@test "CONTRACT: design has sequence diagram in mermaid" {
    grep -q "sequenceDiagram" "$TEMPLATE"
}

# ============================================================================
# Technical Decisions Contract
# ============================================================================

@test "CONTRACT: Technical Decisions is a table" {
    grep -A2 "^## Technical Decisions" "$TEMPLATE" | grep -q "|.*|"
}

@test "CONTRACT: Technical Decisions has Options column" {
    grep -q "Options Considered\|Options" "$TEMPLATE"
}

@test "CONTRACT: Technical Decisions has Rationale column" {
    grep -q "Rationale" "$TEMPLATE"
}

# ============================================================================
# File Structure Contract
# ============================================================================

@test "CONTRACT: File Structure is a table" {
    grep -A2 "^## File Structure" "$TEMPLATE" | grep -q "|.*|"
}

@test "CONTRACT: File Structure has Action column" {
    grep -q "Action" "$TEMPLATE"
}

@test "CONTRACT: File Structure has Purpose column" {
    grep -q "Purpose" "$TEMPLATE"
}

# ============================================================================
# Interface Definition Contract
# ============================================================================

@test "CONTRACT: Interfaces section has code block" {
    grep -A5 "^## Interfaces" "$TEMPLATE" | grep -q '```'
}

@test "CONTRACT: Interface examples use TypeScript syntax" {
    grep -q "interface\|type " "$TEMPLATE" || grep -q '```typescript' "$TEMPLATE"
}

# ============================================================================
# Test Strategy Contract
# ============================================================================

@test "CONTRACT: Test Strategy has Unit Tests subsection" {
    grep -q "Unit Tests\|### Unit" "$TEMPLATE"
}

@test "CONTRACT: Test Strategy has Integration Tests subsection" {
    grep -q "Integration Tests\|### Integration" "$TEMPLATE"
}

# ============================================================================
# Completeness Contract
# ============================================================================

@test "CONTRACT: design has Security Considerations" {
    grep -q "Security" "$TEMPLATE"
}

@test "CONTRACT: design has Performance Considerations" {
    grep -q "Performance" "$TEMPLATE"
}

@test "CONTRACT: design has Existing Patterns section" {
    grep -q "Existing Patterns\|Patterns to Follow" "$TEMPLATE"
}

@test "CONTRACT: design has Dependencies section" {
    grep -q "^## Dependencies" "$TEMPLATE"
}
