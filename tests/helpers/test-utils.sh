#!/bin/bash
# Test utilities for Ralph Specum tests

# Create a temporary test directory
setup_test_dir() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    cd "$TEST_DIR" || exit 1
}

# Cleanup test directory
cleanup_test_dir() {
    if [[ -n "$TEST_DIR" && -d "$TEST_DIR" ]]; then
        rm -rf "$TEST_DIR"
    fi
}

# Create a mock state file with given parameters
create_mock_state() {
    local mode="${1:-interactive}"
    local phase="${2:-requirements}"
    local iteration="${3:-0}"
    local max_iterations="${4:-50}"
    local task_index="${5:-0}"
    local total_tasks="${6:-0}"
    local approvals="${7:-{}}"

    cat > ".ralph-state.json" << EOF
{
    "mode": "$mode",
    "phase": "$phase",
    "iteration": $iteration,
    "maxIterations": $max_iterations,
    "taskIndex": $task_index,
    "totalTasks": $total_tasks,
    "phaseApprovals": $approvals
}
EOF
}

# Create state in spec subdirectory
create_mock_state_in_spec() {
    mkdir -p spec
    cd spec || exit 1
    create_mock_state "$@"
    cd ..
}

# Run the stop handler and capture output
run_stop_handler() {
    local script_path="${BATS_TEST_DIRNAME}/../../hooks/scripts/stop-handler.sh"
    echo '{"transcript_path": "/tmp/test"}' | bash "$script_path"
}

# Assert JSON field value
assert_json_field() {
    local json="$1"
    local field="$2"
    local expected="$3"
    local actual
    actual=$(echo "$json" | jq -r "$field")

    if [[ "$actual" != "$expected" ]]; then
        echo "Expected $field to be '$expected', got '$actual'"
        return 1
    fi
}

# Check if state file was updated
get_state_field() {
    local field="$1"
    jq -r "$field" ".ralph-state.json"
}

# Validate JSON against schema using ajv (if available) or basic checks
validate_json_schema() {
    local json_file="$1"
    local schema_file="$2"

    if command -v ajv &> /dev/null; then
        ajv validate -s "$schema_file" -d "$json_file"
    else
        # Basic JSON validity check
        jq empty "$json_file" 2>/dev/null
    fi
}

# Parse YAML frontmatter from markdown file
extract_frontmatter() {
    local file="$1"
    sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d'
}

# Check if file contains required sections
check_required_sections() {
    local file="$1"
    shift
    local sections=("$@")

    for section in "${sections[@]}"; do
        if ! grep -q "^## $section" "$file" && ! grep -q "^# $section" "$file"; then
            echo "Missing required section: $section"
            return 1
        fi
    done
}
