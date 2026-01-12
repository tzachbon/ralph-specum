#!/usr/bin/env bats
# Unit tests for stop-handler.sh

load '../helpers/test-utils.sh'

# Path to the script under test
SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../hooks/scripts/stop-handler.sh"

setup() {
    setup_test_dir
}

teardown() {
    cleanup_test_dir
}

# ============================================================================
# No State File Tests
# ============================================================================

@test "exits cleanly when no state file exists" {
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "exits cleanly when state file path is invalid" {
    echo '{"invalid": true}' > ".ralph-state.json.wrong"
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

# ============================================================================
# Max Iterations Tests
# ============================================================================

@test "blocks when max iterations reached" {
    create_mock_state "interactive" "requirements" 50 50
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Max iterations reached"* ]]
    [[ "$output" == *"block"* ]]
}

@test "continues when under max iterations" {
    create_mock_state "interactive" "execution" 10 50 5 5
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    # Should not contain max iterations message
    [[ "$output" != *"Max iterations reached"* ]]
}

# ============================================================================
# Interactive Mode - Requirements Phase Tests
# ============================================================================

@test "interactive mode: blocks at requirements phase when not approved" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"requirements"* ]]
    [[ "$output" == *"approve"* ]]
}

@test "interactive mode: blocks at design phase when not approved" {
    create_mock_state "interactive" "design" 1 50 0 0 '{"requirements": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"design"* ]]
}

@test "interactive mode: blocks at tasks phase when not approved" {
    create_mock_state "interactive" "tasks" 2 50 0 0 '{"requirements": true, "design": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"tasks"* ]]
}

# ============================================================================
# Auto Mode - Phase Transition Tests
# ============================================================================

@test "auto mode: advances from requirements to design" {
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"compact"* ]]

    # Verify state was updated
    new_phase=$(jq -r '.phase' .ralph-state.json)
    [ "$new_phase" = "design" ]
}

@test "auto mode: advances from design to tasks" {
    create_mock_state "auto" "design" 1 50 0 0 '{"requirements": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]

    new_phase=$(jq -r '.phase' .ralph-state.json)
    [ "$new_phase" = "tasks" ]
}

@test "auto mode: advances from tasks to execution" {
    create_mock_state "auto" "tasks" 2 50 0 0 '{"requirements": true, "design": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]

    new_phase=$(jq -r '.phase' .ralph-state.json)
    [ "$new_phase" = "execution" ]
}

@test "auto mode: marks phase as approved after advancing" {
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    approved=$(jq -r '.phaseApprovals.requirements' .ralph-state.json)
    [ "$approved" = "true" ]
}

@test "auto mode: increments iteration after advancing" {
    create_mock_state "auto" "requirements" 5 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    iteration=$(jq -r '.iteration' .ralph-state.json)
    [ "$iteration" -eq 6 ]
}

# ============================================================================
# Execution Phase Tests
# ============================================================================

@test "execution: allows stop when all tasks complete" {
    create_mock_state "interactive" "execution" 10 50 5 5 '{"requirements": true, "design": true, "tasks": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "execution: blocks in interactive mode with tasks remaining" {
    create_mock_state "interactive" "execution" 10 50 2 5 '{"requirements": true, "design": true, "tasks": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"Task done"* ]]
}

@test "execution: continues in auto mode with tasks remaining" {
    create_mock_state "auto" "execution" 10 50 2 5 '{"requirements": true, "design": true, "tasks": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"compact"* ]]
}

@test "execution: increments iteration on task completion" {
    create_mock_state "auto" "execution" 5 50 2 5 '{"requirements": true, "design": true, "tasks": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    iteration=$(jq -r '.iteration' .ralph-state.json)
    [ "$iteration" -eq 6 ]
}

# ============================================================================
# Compaction Instructions Tests
# ============================================================================

@test "requirements phase: includes correct compaction keywords" {
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"user stories"* ]]
    [[ "$output" == *"acceptance criteria"* ]]
    [[ "$output" == *"functional requirements"* ]]
}

@test "design phase: includes correct compaction keywords" {
    create_mock_state "auto" "design" 1 50 0 0 '{"requirements": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"architecture decisions"* ]]
    [[ "$output" == *"component boundaries"* ]]
}

@test "tasks phase: includes correct compaction keywords" {
    create_mock_state "auto" "tasks" 2 50 0 0 '{"requirements": true, "design": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"task list"* ]]
    [[ "$output" == *"quality gates"* ]]
}

@test "execution phase: includes correct compaction keywords" {
    create_mock_state "auto" "execution" 3 50 1 5 '{"requirements": true, "design": true, "tasks": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"current task context"* ]]
    [[ "$output" == *"verification results"* ]]
}

# ============================================================================
# State File Location Tests
# ============================================================================

@test "finds state file in spec subdirectory" {
    mkdir -p spec
    cd spec && create_mock_state "interactive" "requirements" 0 50 0 0 '{}' && cd ..
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
}

@test "finds state file in current directory" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
}

# ============================================================================
# Edge Cases
# ============================================================================

@test "handles zero total tasks in execution" {
    create_mock_state "interactive" "execution" 0 50 0 0 '{"requirements": true, "design": true, "tasks": true}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    # Should allow stop when totalTasks is 0 (edge case)
}

@test "handles malformed phase gracefully" {
    create_mock_state "interactive" "unknown_phase" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    # Should exit cleanly (default case)
}

@test "handles empty mode field" {
    cat > ".ralph-state.json" << 'EOF'
{
    "mode": "",
    "phase": "requirements",
    "iteration": 0,
    "maxIterations": 50,
    "taskIndex": 0,
    "totalTasks": 0,
    "phaseApprovals": {}
}
EOF
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
}

# ============================================================================
# JSON Output Format Tests
# ============================================================================

@test "output is valid JSON when blocking" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    echo "$output" | jq empty
    [ "$?" -eq 0 ]
}

@test "output contains decision field when blocking" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    decision=$(echo "$output" | jq -r '.decision')
    [ "$decision" = "block" ]
}

@test "output contains reason field when blocking" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    reason=$(echo "$output" | jq -r '.reason')
    [ -n "$reason" ]
}
