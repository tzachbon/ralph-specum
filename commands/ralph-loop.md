---
description: Start spec-driven development loop. Creates specs from goal, executes tasks with smart compaction between phases.
argument-hint: "goal description" [--mode interactive|auto] [--dir ./spec-dir]
---

# Ralph Specum Loop

You are starting a spec-driven development loop with smart compaction.

## Parse Arguments

From `$ARGUMENTS`, extract:
- **goal**: The quoted goal description (required)
- **mode**: `interactive` (default) or `auto`
- **dir**: Spec directory path (default: `./spec`)

## Initialize

1. Create the spec directory if it doesn't exist
2. Check for existing `.ralph-state.json` in the spec directory
   - If exists: Resume from current state
   - If not: Initialize new state

3. Initialize `.ralph-state.json`:
```json
{
  "mode": "<mode>",
  "goal": "<goal description>",
  "specPath": "<dir>",
  "phase": "requirements",
  "taskIndex": 0,
  "totalTasks": 0,
  "currentTaskName": "",
  "phaseApprovals": {
    "requirements": false,
    "design": false,
    "tasks": false
  },
  "iteration": 1,
  "maxIterations": 50
}
```

4. Initialize `.ralph-progress.md` from template

## Workflow

**ALWAYS read `.ralph-progress.md` first on each iteration.**

### Phase: Requirements
- Generate `requirements.md` based on the goal
- Include: user stories, acceptance criteria, FR/NFR, glossary
- Update `.ralph-progress.md` with current goal and any learnings
- When complete, output: `PHASE_COMPLETE: requirements`

### Phase: Design
- Read `requirements.md` for context
- Generate `design.md` with architecture, patterns, file matrix
- Update `.ralph-progress.md`
- When complete, output: `PHASE_COMPLETE: design`

### Phase: Tasks
- Read `requirements.md` and `design.md`
- Generate `tasks.md` with numbered phases and tasks
- Update `.ralph-state.json` with `totalTasks`
- Update `.ralph-progress.md`
- When complete, output: `PHASE_COMPLETE: tasks`

### Phase: Execution
- Read `tasks.md` and `.ralph-progress.md`
- Execute current task (from `taskIndex`)
- Update `.ralph-progress.md`:
  - Mark task as complete
  - Add any learnings discovered
  - Update current goal to next task
- When task complete, output: `TASK_COMPLETE: <task_number>`

## Completion

When all tasks are done:
1. Run quality gates (if applicable)
2. Delete `.ralph-progress.md`
3. Delete `.ralph-state.json`
4. Output: `RALPH_COMPLETE`

## Loop Control

- Max iterations: 50 (prevents infinite loops)
- Completion promise: `RALPH_COMPLETE`
- The stop hook will handle continuation based on phase/task status

## Important Rules

1. **Always read `.ralph-progress.md` first** after any compaction
2. **Update progress file before any phase/task transition**
3. **Append learnings immediately** when discovered
4. **Never skip the progress file update** before stopping

--max-iterations 50 --completion-promise RALPH_COMPLETE
