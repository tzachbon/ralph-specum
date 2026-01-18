---
description: Generate implementation tasks from design
argument-hint: [spec-name]
allowed-tools: [Read, Write, Task, Bash, AskUserQuestion]
---

# Tasks Phase

You are generating implementation tasks for a specification. Running this command implicitly approves the design phase.

<mandatory>
**YOU ARE A COORDINATOR, NOT A TASK PLANNER.**

You MUST delegate ALL task planning to the `task-planner` subagent.
Do NOT write task breakdowns, verification steps, or tasks.md yourself.
</mandatory>

## Determine Active Spec

1. If `$ARGUMENTS` contains a spec name, use that
2. Otherwise, read `./specs/.current-spec` to get active spec
3. If no active spec, error: "No active spec. Run /ralph-specum:new <name> first."

## Orphaned Execution Check

<mandatory>
**BEFORE proceeding with tasks, check if there's an orphaned execution loop.**

This check ensures interrupted executions are detected and the user is warned.
</mandatory>

### Step 1: Check if Ralph Loop Already Running

Check if the ralph-loop state file exists:
```bash
test -f .claude/ralph-loop.local.md && echo "RUNNING" || echo "NOT_RUNNING"
```

- If `RUNNING`: Ralph loop is active, skip to "Validate" section
- If `NOT_RUNNING`: Continue to Step 2

### Step 2: Check for Orphaned Execution

1. Read `./specs/$spec/.ralph-state.json` (if exists)
2. Check if `phase == "execution"`

If phase is NOT "execution", skip to "Validate" section (no orphaned loop).

### Step 3: Warn and Stop

If phase IS "execution" but no ralph-loop running:

1. Display warning:
   ```
   ⚠️ ORPHANED EXECUTION DETECTED

   Spec '$spec' is in execution phase (task $taskIndex/$totalTasks) but ralph-loop is not running.

   To resume execution: /ralph-specum:implement
   To cancel and start fresh: /ralph-specum:cancel
   ```

2. **STOP** - Do NOT continue with tasks phase. Wait for user to handle the orphaned execution.

## Validate

1. Check `./specs/$spec/` directory exists
2. Check `./specs/$spec/design.md` exists. If not, error: "Design not found. Run /ralph-specum:design first."
3. Check `./specs/$spec/requirements.md` exists
4. Read `.ralph-state.json`
5. Clear approval flag: update state with `awaitingApproval: false`

## Gather Context

Read:
- `./specs/$spec/requirements.md` (required)
- `./specs/$spec/design.md` (required)
- `./specs/$spec/research.md` (if exists)
- `./specs/$spec/.progress.md`

## Interview

<mandatory>
**Skip interview if --quick flag detected in $ARGUMENTS.**

If NOT quick mode, conduct interview using AskUserQuestion before delegating to subagent.
</mandatory>

### Quick Mode Check

Check if `--quick` appears anywhere in `$ARGUMENTS`. If present, skip directly to "Execute Tasks Generation".

### Tasks Interview

Use AskUserQuestion to gather execution and deployment context:

```
AskUserQuestion:
  questions:
    - question: "What testing depth is needed?"
      options:
        - "Standard - unit + integration (Recommended)"
        - "Minimal - POC only, add tests later"
        - "Comprehensive - include E2E"
        - "Other"
    - question: "Deployment considerations?"
      options:
        - "Standard CI/CD pipeline"
        - "Feature flag needed"
        - "Gradual rollout required"
        - "Other"
```

### Adaptive Depth

If user selects "Other" for any question:
1. Ask a follow-up question to clarify using AskUserQuestion
2. Continue until clarity reached or 5 follow-up rounds complete
3. Each follow-up should probe deeper into the "Other" response

### Interview Context Format

After interview, format responses as:

```
Interview Context:
- Testing depth: [Answer]
- Deployment considerations: [Answer]
- Follow-up details: [Any additional clarifications]
```

Store this context to include in the Task delegation prompt.

## Execute Tasks Generation

<mandatory>
Use the Task tool with `subagent_type: task-planner` to generate tasks.
ALL specs MUST follow POC-first workflow.
</mandatory>

Invoke task-planner agent with prompt:

```
You are creating implementation tasks for spec: $spec
Spec path: ./specs/$spec/

Context:
- Requirements: [include requirements.md content]
- Design: [include design.md content]

[If interview was conducted, include:]
Interview Context:
$interview_context

Your task:
1. Read requirements and design thoroughly
2. Break implementation into POC-first phases:
   - Phase 1: Make It Work (POC) - validate idea, skip tests
   - Phase 2: Refactoring - clean up code
   - Phase 3: Testing - unit, integration, e2e
   - Phase 4: Quality Gates - lint, types, CI
3. Create atomic, autonomous-ready tasks
4. Each task MUST include:
   - **Do**: Exact implementation steps
   - **Files**: Exact file paths to create/modify
   - **Done when**: Explicit success criteria
   - **Verify**: Command to verify completion
   - **Commit**: Conventional commit message
   - _Requirements: references_
   - _Design: references_
5. Count total tasks
6. Output to ./specs/$spec/tasks.md
7. Include interview responses in an "Execution Context" section of tasks.md

Use the tasks.md template with frontmatter:
---
spec: $spec
phase: tasks
total_tasks: <count>
created: <timestamp>
---

Critical rules:
- Tasks must be executable without human interaction
- Each task = one commit
- Verify command must be runnable
- POC phase allows shortcuts, later phases clean up
```

## Update State

After tasks complete:

1. Count total tasks from generated file
2. Update `.ralph-state.json`:
   ```json
   {
     "phase": "tasks",
     "totalTasks": <count>,
     "awaitingApproval": true,
     ...
   }
   ```

3. Update `.progress.md`:
   - Mark design as implicitly approved
   - Set current phase to tasks
   - Update task count

## Commit Spec (if enabled)

Read `commitSpec` from `.ralph-state.json` (set during `/ralph-specum:start`).

If `commitSpec` is true:

1. Stage tasks file:
   ```bash
   git add ./specs/$spec/tasks.md
   ```
2. Commit with message:
   ```bash
   git commit -m "spec($spec): add implementation tasks"
   ```
3. Push to current branch:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

If commit or push fails, display warning but continue (don't block the workflow).

## Output

```
Tasks phase complete for '$spec'.

Output: ./specs/$spec/tasks.md
Total tasks: <count>
[If commitSpec: "Spec committed and pushed."]

Next: Review tasks.md, then run /ralph-specum:implement to start execution
```
