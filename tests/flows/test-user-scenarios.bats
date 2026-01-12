#!/usr/bin/env bats
# User scenario tests - testing real-world usage patterns

load '../helpers/test-utils.sh'

SCRIPT_PATH="${BATS_TEST_DIRNAME}/../../hooks/scripts/stop-handler.sh"
PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."

setup() {
    setup_test_dir
}

teardown() {
    cleanup_test_dir
}

# ============================================================================
# Scenario: New User Starting First Spec
# ============================================================================

@test "SCENARIO: New user runs ralph-loop for first time" {
    # User runs /ralph-loop "Build a todo app"
    # System creates initial state and starts requirements phase

    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'

    # When requirements phase completes, hook should block
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    # User should see message about approval
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"approve"* ]] || [[ "$output" == *"Options"* ]]
}

@test "SCENARIO: User approves requirements and moves to design" {
    # After user runs /approve, state is updated externally
    # Then design phase runs and completes

    create_mock_state "interactive" "design" 5 50 0 0 '{"requirements": true}'

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    # Should block at design for approval
    [[ "$output" == *"block"* ]]
    [[ "$output" == *"design"* ]]
}

# ============================================================================
# Scenario: Experienced User Using Auto Mode
# ============================================================================

@test "SCENARIO: Experienced user runs in auto mode" {
    # User runs /ralph-loop --auto "Build a todo app"
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'

    # After requirements, should auto-advance with compaction
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    # Should trigger compaction
    [[ "$output" == *"compact"* ]]

    # Phase should advance automatically
    phase=$(jq -r '.phase' .ralph-state.json)
    [ "$phase" = "design" ]
}

@test "SCENARIO: Auto mode completes full spec generation" {
    create_mock_state "auto" "requirements" 0 50 0 0 '{}'

    # Run through all spec phases
    for expected_phase in "design" "tasks" "execution"; do
        run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
        phase=$(jq -r '.phase' .ralph-state.json)
        [ "$phase" = "$expected_phase" ]
    done
}

# ============================================================================
# Scenario: User Wants to Discuss Before Continuing
# ============================================================================

@test "SCENARIO: User discusses requirements before approving" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'

    # First completion - blocks for discussion
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]

    # User discusses, agent responds, completes again - still blocks
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]

    # Phase hasn't changed - still requirements
    phase=$(jq -r '.phase' .ralph-state.json)
    [ "$phase" = "requirements" ]
}

# ============================================================================
# Scenario: User Cancels Mid-Workflow
# ============================================================================

@test "SCENARIO: User can see current phase in state" {
    # User runs /cancel-ralph which reads state
    create_mock_state "interactive" "design" 8 50 0 0 '{"requirements": true}'

    # State file should be readable
    phase=$(jq -r '.phase' .ralph-state.json)
    [ "$phase" = "design" ]

    iteration=$(jq -r '.iteration' .ralph-state.json)
    [ "$iteration" -eq 8 ]
}

# ============================================================================
# Scenario: User Resumes After Break
# ============================================================================

@test "SCENARIO: User resumes execution after taking a break" {
    # User had started execution, took a break, now running /implement
    create_mock_state "interactive" "execution" 20 50 4 12 '{"requirements": true, "design": true, "tasks": true}'

    # Should continue from task 4
    task_index=$(jq -r '.taskIndex' .ralph-state.json)
    [ "$task_index" -eq 4 ]

    # Hook should allow continuation
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]  # Blocks to show task status
}

# ============================================================================
# Scenario: Long-Running Workflow Safety
# ============================================================================

@test "SCENARIO: System prevents runaway loops" {
    # Simulate a situation where something is stuck
    create_mock_state "auto" "requirements" 49 50 0 0 '{}'

    # Near max iterations
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"

    # At max iterations, should stop
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"Max iterations"* ]]
}

# ============================================================================
# Scenario: Complex Project with Many Tasks
# ============================================================================

@test "SCENARIO: Large project with 20 tasks" {
    create_mock_state "interactive" "execution" 30 100 10 20 '{"requirements": true, "design": true, "tasks": true}'

    # Mid-execution
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]

    # Complete all tasks
    jq '.taskIndex = 20' .ralph-state.json > tmp.json && mv tmp.json .ralph-state.json

    # Should allow completion
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ -z "$output" ]
}

# ============================================================================
# Scenario: State File in Spec Subdirectory
# ============================================================================

@test "SCENARIO: Spec files organized in spec/ directory" {
    mkdir -p spec
    cd spec
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    cd ..

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [[ "$output" == *"block"* ]]
}

# ============================================================================
# Scenario: Error Recovery
# ============================================================================

@test "SCENARIO: Gracefully handles corrupted state" {
    echo "not json" > ".ralph-state.json"

    # Should not crash, just allow stop
    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
}

@test "SCENARIO: Handles state file with extra fields" {
    cat > ".ralph-state.json" << 'EOF'
{
    "mode": "interactive",
    "phase": "requirements",
    "iteration": 0,
    "maxIterations": 50,
    "taskIndex": 0,
    "totalTasks": 0,
    "phaseApprovals": {},
    "customField": "extra data",
    "metadata": {"version": "1.0"}
}
EOF

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
    [[ "$output" == *"block"* ]]
}

# ============================================================================
# Scenario: Different Goal Types
# ============================================================================

@test "SCENARIO: Works with simple goals" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    jq '.goal = "Fix bug"' .ralph-state.json > tmp.json && mv tmp.json .ralph-state.json

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
}

@test "SCENARIO: Works with complex multi-line goals" {
    create_mock_state "interactive" "requirements" 0 50 0 0 '{}'
    jq '.goal = "Build a comprehensive user management system with:\n- Authentication\n- Authorization\n- Profile management"' .ralph-state.json > tmp.json && mv tmp.json .ralph-state.json

    run bash -c "echo '{}' | bash '$SCRIPT_PATH'"
    [ "$status" -eq 0 ]
}
