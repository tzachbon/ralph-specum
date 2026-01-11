#!/bin/bash
# Ralph Specum Stop Hook Handler
# Reads state, determines if loop should continue or block

# Read input from stdin (Claude Code hook input)
INPUT=$(cat)

# Extract transcript path to find working directory
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# Try to find state file in common locations
find_state_file() {
    local dirs=("./spec" "." "../spec")
    for dir in "${dirs[@]}"; do
        if [[ -f "$dir/.ralph-state.json" ]]; then
            echo "$dir/.ralph-state.json"
            return 0
        fi
    done
    return 1
}

STATE_FILE=$(find_state_file)

# If no state file found, allow normal stop
if [[ -z "$STATE_FILE" || ! -f "$STATE_FILE" ]]; then
    exit 0
fi

# Read state
STATE=$(cat "$STATE_FILE")
MODE=$(echo "$STATE" | jq -r '.mode')
PHASE=$(echo "$STATE" | jq -r '.phase')
ITERATION=$(echo "$STATE" | jq -r '.iteration')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.maxIterations')
TASK_INDEX=$(echo "$STATE" | jq -r '.taskIndex')
TOTAL_TASKS=$(echo "$STATE" | jq -r '.totalTasks')

# Check for max iterations
if [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
    echo '{"decision": "block", "reason": "Max iterations reached. Run /ralph-specum:cancel to cleanup."}'
    exit 0
fi

# Check for stop_hook_active to prevent infinite loops
STOP_HOOK_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [[ "$STOP_HOOK_ACTIVE" == "true" ]]; then
    # Already in a continue loop, check if we should keep going
    # Increment iteration
    NEW_ITERATION=$((ITERATION + 1))
    echo "$STATE" | jq ".iteration = $NEW_ITERATION" > "$STATE_FILE"
fi

# Read last output from transcript to detect phase/task completion
# Look for PHASE_COMPLETE, TASK_COMPLETE, or RALPH_COMPLETE markers

# For now, use a simpler approach: check phase approvals and task progress

case "$PHASE" in
    "requirements"|"design"|"tasks")
        # Check if phase needs approval (interactive mode)
        PHASE_APPROVED=$(echo "$STATE" | jq -r ".phaseApprovals.$PHASE")

        if [[ "$MODE" == "interactive" && "$PHASE_APPROVED" != "true" ]]; then
            # Block and wait for approval
            echo "{\"decision\": \"block\", \"reason\": \"Phase '$PHASE' complete. Review the generated file and run /ralph-specum:approve to continue.\"}"
            exit 0
        fi

        # Auto mode or already approved: continue
        # The approve command will handle compaction and phase advancement
        ;;

    "execution")
        # Check if all tasks are done
        if [[ "$TASK_INDEX" -ge "$TOTAL_TASKS" && "$TOTAL_TASKS" -gt 0 ]]; then
            # All done, allow stop
            exit 0
        fi

        # More tasks to do, continue
        # Increment iteration for tracking
        NEW_ITERATION=$((ITERATION + 1))
        echo "$STATE" | jq ".iteration = $NEW_ITERATION" > "$STATE_FILE"

        # Return continue signal (empty output = continue)
        exit 0
        ;;
esac

# Default: allow stop
exit 0
