---
description: Generate implementation tasks from design
argument-hint: [spec-name]
allowed-tools: [Read, Write, Task, Bash, AskUserQuestion]
---

# Tasks Phase

Generate implementation tasks for a specification. Running this command implicitly approves the design phase.

<mandatory>
**YOU ARE A COORDINATOR, NOT A TASK PLANNER.**
Delegate ALL task planning to the `task-planner` subagent via Task tool.
</mandatory>

## Determine Active Spec

1. If `$ARGUMENTS` contains a spec name, use that
2. Otherwise, read `./specs/.current-spec` to get active spec
3. If no active spec, error: "No active spec. Run /ralph-specum:new <name> first."

## Validate

1. Check `./specs/$spec/` directory exists
2. Check `./specs/$spec/design.md` exists. If not, error: "Design not found. Run /ralph-specum:design first."
3. Check `./specs/$spec/requirements.md` exists
4. Read `.ralph-state.json` and clear approval flag: `awaitingApproval: false`

## Gather Context

Read: `./specs/$spec/requirements.md`, `./specs/$spec/design.md`, `./specs/$spec/research.md` (if exists), `./specs/$spec/.progress.md`

## Interview

<skill-reference>
**Apply skill**: `skills/interview-framework/SKILL.md`
Use interview framework for single-question loop, parameter chain, and completion signals.
</skill-reference>

**Skip if --quick flag in $ARGUMENTS.**

### Tasks Interview Question Pool

| # | Question | Required | Key | Options |
|---|----------|----------|-----|---------|
| 1 | What testing depth for {goal}? | Required | `testingDepth` | Standard unit+integration / Minimal POC only / Comprehensive E2E / Other |
| 2 | Deployment considerations for {goal}? | Required | `deploymentApproach` | Standard CI/CD / Feature flag / Gradual rollout / Other |
| 3 | What's the execution priority? | Required | `executionPriority` | Ship fast POC / Balanced quality+speed / Quality first / Other |
| 4 | Any other execution context? (or 'done') | Optional | `additionalTasksContext` | No, proceed / Yes, more details / Other |

Store responses in `.progress.md` under `### Tasks Interview (from tasks.md)`

## Execute Tasks Generation

Use Task tool with `subagent_type: task-planner`:

```text
You are creating implementation tasks for spec: $spec
Spec path: ./specs/$spec/

Context:
- Requirements: [requirements.md content]
- Design: [design.md content]
- Interview: [interview responses]

Create tasks.md with POC-first phases:
- Phase 1: Make It Work (POC)
- Phase 2: Refactoring
- Phase 3: Testing
- Phase 4: Quality Gates

Each task MUST include: Do, Files, Done when, Verify, Commit, Requirements refs, Design refs.
```

## Review Loop

**Skip if --quick flag.** Ask user to review generated tasks. If changes needed, invoke task-planner again with feedback and repeat until approved.

## Update State

Count total tasks, then update `.ralph-state.json`: `{ "phase": "tasks", "totalTasks": <count>, "awaitingApproval": true }`

## Commit Spec (if enabled)

If `commitSpec` is true in state: stage, commit (`spec($spec): add implementation tasks`), push.

## Output

```text
Tasks phase complete for '$spec'.
Output: ./specs/$spec/tasks.md
Total tasks: <count>
Next: Review tasks.md, then run /ralph-specum:implement
```
