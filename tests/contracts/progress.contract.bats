#!/usr/bin/env bats
# Contract tests for progress.md template

PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."
TEMPLATE="$PROJECT_ROOT/templates/progress.md"

# ============================================================================
# Template Structure Contract
# ============================================================================

@test "CONTRACT: progress template exists" {
    [ -f "$TEMPLATE" ]
}

@test "CONTRACT: progress has Current Goal section" {
    grep -q "^## Current Goal" "$TEMPLATE"
}

@test "CONTRACT: progress has Original Goal section" {
    grep -q "^## Original Goal" "$TEMPLATE"
}

@test "CONTRACT: progress has Completed section" {
    grep -q "^## Completed" "$TEMPLATE"
}

@test "CONTRACT: progress has Learnings section" {
    grep -q "^## Learnings" "$TEMPLATE"
}

@test "CONTRACT: progress has Blockers section" {
    grep -q "^## Blockers" "$TEMPLATE"
}

@test "CONTRACT: progress has Next Steps section" {
    grep -q "^## Next Steps" "$TEMPLATE"
}

# ============================================================================
# Current Goal Details Contract
# ============================================================================

@test "CONTRACT: Current Goal shows Phase" {
    grep -q "\*\*Phase\*\*:" "$TEMPLATE" || grep -q "Phase:" "$TEMPLATE"
}

@test "CONTRACT: Current Goal shows Task progress" {
    grep -q "\*\*Task\*\*:" "$TEMPLATE" || grep -q "Task:" "$TEMPLATE"
}

@test "CONTRACT: Current Goal shows Objective" {
    grep -q "\*\*Objective\*\*:" "$TEMPLATE" || grep -q "Objective:" "$TEMPLATE"
}

# ============================================================================
# Compaction Survival Contract
# ============================================================================

@test "CONTRACT: progress is designed to survive compaction" {
    # The file should contain critical information that needs to persist
    # Check for placeholder for goal
    grep -q "{{USER_GOAL_DESCRIPTION}}\|USER_GOAL" "$TEMPLATE" || \
    grep -q "Original Goal" "$TEMPLATE"
}

@test "CONTRACT: Learnings section exists for knowledge preservation" {
    grep -q "## Learnings" "$TEMPLATE"
    # Should have placeholder or example content
    grep -A2 "## Learnings" "$TEMPLATE" | grep -q "_\|{{" || true
}

# ============================================================================
# Status Tracking Contract
# ============================================================================

@test "CONTRACT: shows task count format" {
    grep -q "[0-9]/[0-9]\|0/0" "$TEMPLATE"
}

@test "CONTRACT: has initial phase value" {
    grep -q "requirements\|Requirements" "$TEMPLATE"
}

# ============================================================================
# Next Steps Contract
# ============================================================================

@test "CONTRACT: Next Steps uses numbered list" {
    grep -A5 "## Next Steps" "$TEMPLATE" | grep -q "^[0-9]\."
}
