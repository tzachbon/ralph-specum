---
description: Smart entry point that detects if you need a new spec or should resume existing
argument-hint: [name] [goal] [--fresh]
allowed-tools: [Read, Write, Bash, Task, AskUserQuestion]
---

# Start

Smart entry point for ralph-specum. Detects whether to create a new spec or resume an existing one.

## Parse Arguments

From `$ARGUMENTS`, extract:
- **name**: Optional spec name (kebab-case)
- **goal**: Everything after the name except flags (optional)
- **--fresh**: Force new spec without prompting if one exists

Examples:
- `/ralph-specum:start` -> Auto-detect: resume active or ask for new
- `/ralph-specum:start user-auth` -> Resume or create user-auth
- `/ralph-specum:start user-auth Add OAuth2` -> Create user-auth with goal
- `/ralph-specum:start user-auth --fresh` -> Force new, overwrite if exists
- `/ralph-specum:start "Build auth with JWT" --quick` -> Quick mode with goal
- `/ralph-specum:start my-feature "Add logging" --quick` -> Quick mode with name+goal

## Quick Mode Flow

When `--quick` flag detected, bypass interactive spec phases and auto-generate all artifacts.

### Input Validation

1. Validate goal/plan content is non-empty
2. If empty: error "Quick mode requires a goal or plan content"

### Name Inference

If no explicit name provided, infer from goal:
1. Take first 3 words of goal
2. Convert to kebab-case (lowercase, spaces to hyphens)
3. Truncate to max 30 characters
4. Strip non-alphanumeric except hyphens

Example: "Build authentication with JWT tokens" -> "build-authentication-with"

### Quick Mode Execution

```
1. Validate input (non-empty goal/plan)
   |
2. Infer name from goal (if not provided)
   |
3. Create spec directory: ./specs/$name/
   |
4. Write .ralph-state.json:
   {
     "source": "plan",
     "name": "$name",
     "basePath": "./specs/$name",
     "phase": "tasks",
     "taskIndex": 0,
     "totalTasks": 0,
     "taskIteration": 1,
     "maxTaskIterations": 5,
     "globalIteration": 1,
     "maxGlobalIterations": 100
   }
   |
5. Write .progress.md with original goal:
   # Progress: $name

   ## Goal
   $goal

   ## Status
   - [x] Spec created (quick mode)
   - [ ] Implementation

   ## Current Task
   Awaiting generation
   |
6. Update .current-spec: echo "$name" > ./specs/.current-spec
   |
7. Invoke plan-synthesizer agent via Task tool:
   Task: plan-synthesizer
   Input: goal="$goal", basePath="./specs/$name"
   |
8. After generation completes:
   - Update .ralph-state.json: phase="execution", taskIndex=0
   - Read tasks.md to get totalTasks count
   |
9. Display brief summary:
   Quick mode: Created spec '$name'
   Generated: research.md, requirements.md, design.md, tasks.md
   Starting execution...
   |
10. Invoke spec-executor for task 1:
    Task: spec-executor
    Input: specName="$name", taskIndex=0
```

### Quick Mode Output

**Success:**
```
Quick mode: Created 'build-auth-with' at ./specs/build-auth-with/
Generated 4 artifacts from goal.
Starting task 1/N...
```

## Detection Logic

```
1. Check if name provided in arguments
   |
   +-- Yes: Check if ./specs/$name/ exists
   |   |
   |   +-- Exists + no --fresh: Ask "Resume '$name' or start fresh?"
   |   |   +-- Resume: Go to resume flow
   |   |   +-- Fresh: Delete existing, go to new flow
   |   |
   |   +-- Exists + --fresh: Delete existing, go to new flow
   |   |
   |   +-- Not exists: Go to new flow
   |
   +-- No: Check ./specs/.current-spec
       |
       +-- Has active spec: Go to resume flow
       |
       +-- No active spec: Ask for name and goal, go to new flow
```

## Resume Flow

1. Read `./specs/$name/.ralph-state.json`
2. If no state file (completed or never started):
   - Check what files exist (research.md, requirements.md, etc.)
   - Determine last completed phase
   - Ask: "Continue to next phase or restart?"
3. If state file exists:
   - Read current phase and task index
   - Show brief status:
     ```
     Resuming '$name'
     Phase: execution, Task 3/8
     Last: "Add error handling"
     ```
   - Continue from current phase

### Resume by Phase

| Phase | Action |
|-------|--------|
| research | Invoke research-analyst agent |
| requirements | Invoke product-manager agent |
| design | Invoke architect-reviewer agent |
| tasks | Invoke task-planner agent |
| execution | Invoke spec-executor for current task |

## New Flow

1. If no name provided, ask:
   - "What should we call this spec?" (validates kebab-case)
2. If no goal provided, ask:
   - "What is the goal? Describe what you want to build."
3. Create spec directory: `./specs/$name/`
4. Update active spec: `echo "$name" > ./specs/.current-spec`
5. Initialize `.ralph-state.json`:
   ```json
   {
     "source": "spec",
     "name": "$name",
     "basePath": "./specs/$name",
     "phase": "research",
     "taskIndex": 0,
     "totalTasks": 0,
     "taskIteration": 1,
     "maxTaskIterations": 5,
     "globalIteration": 1,
     "maxGlobalIterations": 100
   }
   ```
6. Create `.progress.md` with goal
7. Invoke research-analyst agent

## Status Display (on resume)

Before resuming, show brief status:

```
Resuming: user-auth
Phase: execution
Progress: 3/8 tasks complete
Current: 2.1 Add error handling

Continuing...
```

## Output

After detection and action:

**New spec:**
```
Created spec 'user-auth' at ./specs/user-auth/

Starting research phase...
```

**Resume:**
```
Resuming 'user-auth' at execution phase, task 4/8

Continuing task: 2.2 Extract retry logic
```
