#!/bin/bash
# Ralph Specum Restart Runner
# Monitors for restart markers and relaunches Claude with fresh context
#
# Usage: ./restart-runner.sh [spec-dir] [--watch-interval SECONDS]
#
# This script runs Claude Code in a loop, automatically restarting
# when a restart marker is detected (e.g., after phases complete or
# between tasks when --force-restart is enabled).

set -e

# Configuration
SPEC_DIR="${1:-./spec}"
WATCH_INTERVAL="${2:-2}"  # Check every 2 seconds by default
MAX_RESTARTS=100          # Safety limit

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[ralph-runner]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ralph-runner]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[ralph-runner]${NC} $1"
}

log_error() {
    echo -e "${RED}[ralph-runner]${NC} $1"
}

# Find restart marker in spec directories
find_restart_marker() {
    local marker=$(find "$SPEC_DIR" -maxdepth 2 -name ".ralph-restart" -type f 2>/dev/null | head -n 1)
    echo "$marker"
}

# Find state file
find_state_file() {
    local state=$(find "$SPEC_DIR" -maxdepth 2 -name ".ralph-state.json" -type f 2>/dev/null | head -n 1)
    echo "$state"
}

# Get resume instruction from marker
get_resume_instruction() {
    local marker="$1"
    if [[ -f "$marker" ]]; then
        jq -r '.instruction // "Resume execution"' "$marker"
    else
        echo "Resume execution"
    fi
}

# Check if workflow is complete
is_workflow_complete() {
    local state_file=$(find_state_file)
    if [[ ! -f "$state_file" ]]; then
        return 0  # No state = complete or not started
    fi

    local phase=$(jq -r '.phase' "$state_file")
    local task_index=$(jq -r '.taskIndex' "$state_file")
    local total_tasks=$(jq -r '.totalTasks' "$state_file")

    if [[ "$phase" == "execution" && "$task_index" -ge "$total_tasks" && "$total_tasks" -gt 0 ]]; then
        return 0  # Complete
    fi

    return 1  # Not complete
}

# Run Claude with resume prompt
run_claude() {
    local instruction="$1"
    local state_file=$(find_state_file)
    local spec_path=""

    if [[ -f "$state_file" ]]; then
        spec_path=$(jq -r '.specPath' "$state_file")
    fi

    # Build the prompt for Claude
    local prompt="$instruction

Please read the state files and continue:
1. Read $spec_path/.ralph-state.json to understand current phase and task
2. Read $spec_path/.ralph-progress.md for context and learnings
3. Continue with the next task from $spec_path/tasks.md

Run /ralph-specum:implement to resume execution."

    log_info "Launching Claude Code..."
    log_info "Prompt: $prompt"

    # Run Claude Code with the resume prompt
    # Using --print to send initial prompt, -p for non-interactive
    claude --print "$prompt" 2>&1 || true

    return $?
}

# Main loop
main() {
    local restart_count=0

    log_info "Starting Ralph Specum Restart Runner"
    log_info "Spec directory: $SPEC_DIR"
    log_info "Watch interval: ${WATCH_INTERVAL}s"

    # Initial check for existing restart marker
    local marker=$(find_restart_marker)
    if [[ -n "$marker" ]]; then
        log_info "Found existing restart marker: $marker"
    fi

    while true; do
        # Safety limit
        if [[ $restart_count -ge $MAX_RESTARTS ]]; then
            log_error "Max restarts ($MAX_RESTARTS) reached. Exiting."
            exit 1
        fi

        # Check if workflow is complete
        if is_workflow_complete; then
            log_success "Workflow complete! No more tasks."
            exit 0
        fi

        # Look for restart marker
        marker=$(find_restart_marker)

        if [[ -n "$marker" && -f "$marker" ]]; then
            restart_count=$((restart_count + 1))

            log_info "Restart marker found (restart #$restart_count)"
            log_info "$(cat "$marker" | jq -c '.')"

            local instruction=$(get_resume_instruction "$marker")

            # Remove the marker before restarting
            rm -f "$marker"

            log_info "Starting new Claude instance..."

            # Run Claude and wait for it to complete
            run_claude "$instruction"

            log_info "Claude instance exited. Checking for next restart..."

            # Small delay before checking again
            sleep "$WATCH_INTERVAL"
        else
            # No marker found, wait and check again
            sleep "$WATCH_INTERVAL"
        fi
    done
}

# Handle interrupt
trap 'log_warn "Interrupted. Exiting..."; exit 130' INT TERM

# Run main
main
