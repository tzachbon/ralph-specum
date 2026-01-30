---
description: Start task execution loop
argument-hint: [--max-task-iterations 5]
allowed-tools: [Read, Write, Edit, Task, Bash, Skill]
---

# Start Execution

You are starting the task execution loop.

## Ralph Loop Dependency Check

**BEFORE proceeding**, verify Ralph Loop plugin is installed by attempting to invoke the skill.

If the Skill tool fails with "skill not found" or similar error for `ralph-loop:ralph-loop`:
1. Output error: "ERROR: Ralph Loop plugin not found. Install with: /plugin install ralph-wiggum@claude-plugins-official"
2. STOP execution immediately. Do NOT continue.

This is a hard dependency. The command cannot function without Ralph Loop.

## Determine Active Spec

1. Read `./specs/.current-spec` to get active spec name
2. If file missing or empty: error "No active spec. Run /ralph-specum:new <name> first."

## Validate Prerequisites

1. Check `./specs/$spec/` directory exists
2. Check `./specs/$spec/tasks.md` exists. If not: error "Tasks not found. Run /ralph-specum:tasks first."

## Parse Arguments

From `$ARGUMENTS`:
- **--max-task-iterations**: Max retries per task (default: 5)
- **--recovery-mode**: Enable iterative failure recovery (default: false). When enabled, failed tasks trigger automatic fix task generation instead of stopping.

## Initialize Execution State

1. Count total tasks in tasks.md (lines matching `- [ ]` or `- [x]`)
2. Count already completed tasks (lines matching `- [x]`)
3. Set taskIndex to first incomplete task

Write `.ralph-state.json`:
```json
{
  "phase": "execution",
  "taskIndex": <first incomplete>,
  "totalTasks": <count>,
  "taskIteration": 1,
  "maxTaskIterations": <parsed from --max-task-iterations or default 5>,
  "recoveryMode": <true if --recovery-mode flag present, false otherwise>,
  "maxFixTasksPerOriginal": 3,
  "fixTaskMap": {}
}
```

## Invoke Ralph Loop

Calculate max iterations: `max(5, min(10, ceil(totalTasks / 5)))`

This formula:
- Minimum 5 iterations (safety floor for small specs)
- Maximum 10 iterations (prevents runaway loops)
- Scales with task count: 5 tasks = 5 iterations, 50 tasks = 10 iterations

### Step 1: Write Coordinator Prompt to File

Write the ENTIRE coordinator prompt (from section below) to `./specs/$spec/.coordinator-prompt.md`.

This file contains the full instructions for task execution. Writing it to a file avoids shell argument parsing issues with the multi-line prompt.

### Step 2: Invoke Ralph Loop Skill

Use the Skill tool to invoke `ralph-loop:ralph-loop` with args:

```
Read ./specs/$spec/.coordinator-prompt.md and follow those instructions exactly. Output ALL_TASKS_COMPLETE when done. --max-iterations <calculated> --completion-promise ALL_TASKS_COMPLETE
```

Replace `$spec` with the actual spec name and `<calculated>` with the calculated max iterations value.

## Coordinator Prompt

Write this prompt to `./specs/$spec/.coordinator-prompt.md`:

```text
You are the execution COORDINATOR for spec: $spec

<skill-reference>
**Apply skill**: `plugins/ralph-specum/skills/coordinator-pattern/SKILL.md`

Use this skill for:
- Role definition (coordinator vs implementer)
- State reading from .ralph-state.json
- Task delegation via Task tool
- Completion checking and signaling
- State updates after task completion
- Retry handling logic
- Parallel execution patterns
</skill-reference>

### Task Parsing

Read `./specs/$spec/tasks.md` and find the task at taskIndex (0-based).

Tasks follow this format:
```markdown
- [ ] X.Y Task description
  - **Do**: Steps to execute
  - **Files**: Files to modify
  - **Done when**: Success criteria
  - **Verify**: Verification command
  - **Commit**: Commit message
```

Extract the full task block including all bullet points under it.

Detect markers in task description:
- [P] = parallel task (can run with adjacent [P] tasks)
- [VERIFY] = verification task (delegate to qa-engineer)
- No marker = sequential task

### [VERIFY] Task Detection

Before standard delegation, check if current task has [VERIFY] marker.
Look for `[VERIFY]` in task description line (e.g., `- [ ] 1.4 [VERIFY] Quality checkpoint`).

If [VERIFY] marker present:
1. Do NOT delegate to spec-executor
2. Delegate to qa-engineer via Task tool instead
3. [VERIFY] tasks are ALWAYS sequential (break parallel groups)

### Failure Handling

<skill-reference>
**Apply skill**: `plugins/ralph-specum/skills/failure-recovery/SKILL.md`

Use this skill when spec-executor does NOT output TASK_COMPLETE:
- Parse failure output to extract error details
- Check recoveryMode state (defaults to false)
- Generate fix tasks when recovery mode enabled
- Insert fix tasks into tasks.md
- Track fix attempts in fixTaskMap
- Orchestrate the iterative recovery loop
</skill-reference>

### Verification Before Advancing

<skill-reference>
**Apply skill**: `plugins/ralph-specum/skills/verification-layers/SKILL.md`

Run 4-layer verification BEFORE advancing taskIndex:
1. Contradiction detection - no "requires manual" + TASK_COMPLETE
2. Uncommitted spec files check - tasks.md and .progress.md committed
3. Checkmark verification - count matches taskIndex + 1
4. Completion signal verification - explicit TASK_COMPLETE present

All layers must pass before advancing state.
</skill-reference>

### Progress Merge (Parallel Only)

After parallel batch completes:
1. Read each temp progress file (.progress-task-N.md)
2. Extract completed task entries and learnings
3. Append to main .progress.md in task index order
4. Delete temp files after merge

### Completion Signal

**Phase 5 Detection**: Before outputting ALL_TASKS_COMPLETE, check if Phase 5 (PR Lifecycle) is required:

1. Read tasks.md to detect Phase 5 tasks (look for "Phase 5: PR Lifecycle" section)
2. If Phase 5 exists AND taskIndex >= totalTasks:
   - Enter PR Lifecycle Loop
   - Do NOT output ALL_TASKS_COMPLETE yet
3. If NO Phase 5 OR Phase 5 complete:
   - Proceed with standard completion

**Standard Completion** (no Phase 5 or Phase 5 done):

Output exactly `ALL_TASKS_COMPLETE` when:
- taskIndex >= totalTasks AND
- All tasks marked [x] in tasks.md AND
- Zero test regressions verified AND
- Code is modular/reusable (documented in .progress.md)

Before outputting:
1. Verify all tasks marked [x] in tasks.md
2. Delete .ralph-state.json (cleanup execution state)
3. Keep .progress.md (preserve learnings and history)
4. Check for PR and output link if exists: `gh pr view --json url -q .url 2>/dev/null`

This signal terminates the Ralph Loop loop.

Do NOT output ALL_TASKS_COMPLETE if tasks remain incomplete.
Do NOT output TASK_COMPLETE (that's for spec-executor only).

### PR Lifecycle Loop (Phase 5)

CRITICAL: Phase 5 is continuous autonomous PR management. Do NOT stop until all criteria met.

**Entry Conditions**:
- All Phase 1-4 tasks complete
- Phase 5 tasks detected in tasks.md

**Loop Steps**:
1. Create PR (if not exists): `gh pr create --title "feat: <spec>" --body "<summary>"`
2. CI Monitoring: Wait 3 min, check `gh pr checks`, fix failures, repeat
3. Review Comments: Check `gh pr view --json reviews`, address feedback
4. Final Validation: All tasks [x], CI green, no unresolved reviews
5. Completion: Delete state, output ALL_TASKS_COMPLETE with PR link

**Timeout Protection**:
- Max 48 hours in PR Lifecycle Loop
- Max 20 CI monitoring cycles
- If exceeded: Output error and STOP (do not output ALL_TASKS_COMPLETE)
```

## Output on Start

```text
Starting execution for '$spec'

Tasks: $completed/$total completed
Starting from task $taskIndex

The execution loop will:
- Execute one task at a time
- Continue until all tasks complete or max iterations reached

Beginning execution...
```
