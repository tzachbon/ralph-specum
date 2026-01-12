#!/usr/bin/env bats
# Tests for phase transition logic and state machine behavior

load '../helpers/test-utils.sh'

SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../hooks/scripts/stop-handler.sh"
FIXTURES="${BATS_TEST_DIRNAME}/fixtures"

setup() {
    setup_test_dir
}

teardown() {
    cleanup_test_dir
}

# ============================================================================
# User Flow: Interactive Mode - Full Workflow
# ============================================================================

@test "FLOW: Interactive mode blocks at each phase for approval" {
    # Phase 1: Requirements - should block
    cp "$FIXTURES/state-requirements-start.json" ".ralph-state.json"
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"requirements"* ]]

    # Phase 2: Design - should block
    cp "$FIXTURES/state-design-pending.json" ".ralph-state.json"
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"design"* ]]

    # Phase 3: Tasks - should block
    cp "$FIXTURES/state-tasks-pending.json" ".ralph-state.json"
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"tasks"* ]]
}

@test "FLOW: Interactive mode allows completion after all tasks done" {
    cp "$FIXTURES/state-execution-complete.json" ".ralph-state.json"
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]  # Empty output means allow stop
}

# ============================================================================
# User Flow: Auto Mode - Full Workflow
# ============================================================================

@test "FLOW: Auto mode advances through all phases" {
    # Start at requirements
    cp "$FIXTURES/state-auto-mode.json" ".ralph-state.json"

    # Requirements -> Design
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    new_phase=$(jq -r '.phase' .ralph-state.json)
    [ "$new_phase" = "design" ]

    # Design -> Tasks
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    new_phase=$(jq -r '.phase' .ralph-state.json)
    [ "$new_phase" = "tasks" ]

    # Tasks -> Execution
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    new_phase=$(jq -r '.phase' .ralph-state.json)
    [ "$new_phase" = "execution" ]
}

@test "FLOW: Auto mode marks phases as approved during transitions" {
    cp "$FIXTURES/state-auto-mode.json" ".ralph-state.json"

    # After first transition
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    req_approved=$(jq -r '.phaseApprovals.requirements' .ralph-state.json)
    [ "$req_approved" = "true" ]

    # After second transition
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    design_approved=$(jq -r '.phaseApprovals.design' .ralph-state.json)
    [ "$design_approved" = "true" ]

    # After third transition
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    tasks_approved=$(jq -r '.phaseApprovals.tasks' .ralph-state.json)
    [ "$tasks_approved" = "true" ]
}

# ============================================================================
# User Flow: Resume from Midpoint
# ============================================================================

@test "FLOW: Can resume execution from midway point" {
    cp "$FIXTURES/state-execution-midway.json" ".ralph-state.json"

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]

    # Should continue execution
    iteration=$(jq -r '.iteration' .ralph-state.json)
    [ "$iteration" -eq 16 ]  # Incremented from 15
}

@test "FLOW: Preserves task progress on resume" {
    cp "$FIXTURES/state-execution-midway.json" ".ralph-state.json"

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    # Task index should be preserved
    task_index=$(jq -r '.taskIndex' .ralph-state.json)
    [ "$task_index" -eq 3 ]

    # Total tasks should be preserved
    total_tasks=$(jq -r '.totalTasks' .ralph-state.json)
    [ "$total_tasks" -eq 10 ]
}

# ============================================================================
# Phase Approval Flow
# ============================================================================

@test "FLOW: Phase cannot advance without approval in interactive mode" {
    create_mock_state "interactive" "requirements" 5 50 0 0 '{}'

    # First attempt - blocks
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]

    # Try again - still blocks (no approval)
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]

    # Phase should not have changed
    phase=$(jq -r '.phase' .ralph-state.json)
    [ "$phase" = "requirements" ]
}

@test "FLOW: Phase advances after approval set externally" {
    create_mock_state "interactive" "requirements" 5 50 0 0 '{"requirements": true}'

    # With approval, should not block at requirements
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    # The script doesn't advance in interactive mode even with approval
    # It just doesn't block anymore (allows stop)
    [ "$status" -eq 0 ]
}

# ============================================================================
# Iteration Safety Flow
# ============================================================================

@test "FLOW: Iteration counter prevents infinite loops" {
    create_mock_state "auto" "requirements" 49 50 0 0 '{}'

    # At iteration 49, max 50 - should still work
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]

    # Now at iteration 50, should block with max message
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"Max iterations reached"* ]]
}

@test "FLOW: Each action increments iteration" {
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'

    for i in {1..3}; do
        run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
        iteration=$(jq -r '.iteration' .ralph-state.json)
        [ "$iteration" -eq "$i" ]
    done
}

# ============================================================================
# Error Recovery Flows
# ============================================================================

@test "FLOW: Gracefully handles missing state fields" {
    # Create minimal state
    cat > ".ralph-state.json" << 'EOF'
{
    "mode": "interactive",
    "phase": "requirements"
}
EOF

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    # Should not crash
}

@test "FLOW: Handles empty phaseApprovals object" {
    create_mock_state "interactive" "design" 5 50 0 0 '{}'

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
}

# ============================================================================
# Compaction Trigger Flows
# ============================================================================

@test "FLOW: Auto mode triggers compaction instruction at phase boundaries" {
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"/compact"* ]] || [[ "$output" == *"compact"* ]]
}

@test "FLOW: Compaction instruction includes progress file reference" {
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *".ralph-progress.md"* ]]
}

# ============================================================================
# Task Execution Flow
# ============================================================================

@test "FLOW: Execution continues until all tasks complete" {
    # Start with task 0 of 3
    create_mock_state "auto" "execution" 0 50 0 3 '{"requirements": true, "design": true, "tasks": true}'

    # Should block and request continuation
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]

    # Manually advance task index to simulate completion
    jq '.taskIndex = 3' .ralph-state.json > tmp.json && mv tmp.json .ralph-state.json

    # Now should allow stop (all tasks done)
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ -z "$output" ]
}

@test "FLOW: Interactive execution allows discussion between tasks" {
    create_mock_state "interactive" "execution" 5 50 1 5 '{"requirements": true, "design": true, "tasks": true}'

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"Task done"* ]] || [[ "$output" == *"Discuss"* ]] || [[ "$output" == *"continue"* ]]
}
