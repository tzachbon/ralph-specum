# State File Schema

Ralph plugins use `.ralph-state.json` to track execution state.

## Location

```
./specs/<spec-name>/.ralph-state.json
```

## Schema

```json
{
  "phase": "research|requirements|design|tasks|execution",
  "taskIndex": 0,
  "totalTasks": 0,
  "taskIteration": 1,
  "maxTaskIterations": 5,
  "awaitingApproval": false
}
```

## Field Definitions

| Field | Type | Description |
|-------|------|-------------|
| `phase` | string | Current workflow phase |
| `taskIndex` | number | 0-based index of current task |
| `totalTasks` | number | Total tasks in tasks.md |
| `taskIteration` | number | Current retry attempt (1-based) |
| `maxTaskIterations` | number | Max retries before blocking |
| `awaitingApproval` | boolean | Waiting for user to proceed |

## Phase Values

| Phase | Description |
|-------|-------------|
| `research` | Research phase active |
| `requirements` | Requirements gathering |
| `design` | Technical design |
| `tasks` | Task planning |
| `execution` | Task execution loop |

## State Transitions

```
research -> requirements -> design -> tasks -> execution
```

Each phase sets `awaitingApproval: true` after completion (except quick mode).

## Corruption Handling

If state file missing or invalid JSON:
1. Output error with state file path
2. Suggest re-running the implement command
3. Do NOT continue execution

## Validation

Coordinator validates state against tasks.md checkmarks. If `taskIndex` doesn't match checked task count, state is reset.
