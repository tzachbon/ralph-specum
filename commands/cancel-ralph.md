---
description: Cancel active Ralph Specum loop. Cleans up state files.
argument-hint: [--dir ./spec-dir]
---

# Cancel Ralph Specum

Cancel the active Ralph Specum loop.

## Parse Arguments

From `$ARGUMENTS`, extract:
- **dir**: Spec directory path (default: `./spec`)

## Actions

1. Check if `.ralph-state.json` exists in the spec directory
2. If exists:
   - Read current state to show summary
   - Delete `.ralph-state.json`
   - Delete `.ralph-progress.md` (if exists)
   - Output cancellation summary

3. If not exists:
   - Output: "No active Ralph loop found in <dir>"

## Output Format

```
Ralph Specum Cancelled

Summary:
- Phase: <last phase>
- Tasks completed: <count>
- Iteration: <number>

State files removed. You can restart with /ralph-specum.
```
