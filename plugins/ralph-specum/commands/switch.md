---
description: Switch active spec
argument-hint: <spec-name>
allowed-tools: [Read, Write, Bash, Glob, Task]
---

# Switch Active Spec

You are switching the active specification.

## Orphaned Execution Check

<mandatory>
**BEFORE switching, check if there's an orphaned execution loop.**

This check ensures interrupted executions are detected and the user is warned.
</mandatory>

### Step 1: Check if Ralph Loop Already Running

Check if the ralph-loop state file exists:
```bash
test -f .claude/ralph-loop.local.md && echo "RUNNING" || echo "NOT_RUNNING"
```

- If `RUNNING`: Ralph loop is active, skip to "Parse Arguments" section
- If `NOT_RUNNING`: Continue to Step 2

### Step 2: Check for Orphaned Execution

1. Read `./specs/.current-spec` to get active spec name (if exists)
2. If no current spec, skip to "Parse Arguments" section
3. Read `./specs/$spec/.ralph-state.json` (if exists)
4. Check if `phase == "execution"`

If no state file or phase is NOT "execution", skip to "Parse Arguments" section.

### Step 3: Warn and Stop

If phase IS "execution" but no ralph-loop running:

1. Display warning:
   ```
   ⚠️ ORPHANED EXECUTION DETECTED

   Spec '$spec' is in execution phase (task $taskIndex/$totalTasks) but ralph-loop is not running.

   To resume execution: /ralph-specum:implement
   To cancel and start fresh: /ralph-specum:cancel
   ```

2. **STOP** - Do NOT continue with switch command. Wait for user to handle the orphaned execution.

## Parse Arguments

From `$ARGUMENTS`:
- **name**: The spec name to switch to (required)

## Validate

1. If no name provided, list available specs and ask user to choose
2. Check if `./specs/$name/` exists
3. If not, error: "Spec '$name' not found. Available specs: <list>"

## List Available (if no argument)

If `$ARGUMENTS` is empty:

1. List all directories in `./specs/`
2. Read current active spec from `./specs/.current-spec`
3. Show list with current marked

```
Available specs:
- feature-a [ACTIVE]
- feature-b
- feature-c

Run: /ralph-specum:switch <spec-name>
```

## Execute Switch

1. Update `./specs/.current-spec`:
   ```bash
   echo "$name" > ./specs/.current-spec
   ```

2. Read the spec's state:
   - `.ralph-state.json` for phase and progress
   - `.progress.md` for context

## Output

```
Switched to spec: $name

Current phase: <phase>
Progress: <taskIndex>/<totalTasks> tasks

Files present:
- [x/blank] research.md
- [x/blank] requirements.md
- [x/blank] design.md
- [x/blank] tasks.md

Next: Run /ralph-specum:<appropriate-phase> to continue
```
