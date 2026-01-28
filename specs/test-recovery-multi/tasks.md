---
spec: test-recovery-multi
phase: tasks
total_tasks: 1
created: 2026-01-28T23:00:00Z
generated: test
---

# Tasks: Test Recovery Multi-Failure

## Overview

Test spec that validates multi-failure recovery. Task 1.1 fails twice before succeeding using a counter file.

## Completion Criteria

- Counter file reaches 3, task passes
- Fix tasks 1.1.1 and 1.1.2 created automatically
- Original task 1.1 eventually passes

## Phase 1: Test Tasks

- [ ] 1.1 Counter-based failing task
  - **Do**: Read counter from ./specs/test-recovery-multi/.counter. If not exists or < 3, increment and fail. If >= 3, succeed.
  - **Files**: `specs/test-recovery-multi/.counter`
  - **Done when**: Counter file contains 3 and task reports success
  - **Verify**: `test "$(cat ./specs/test-recovery-multi/.counter 2>/dev/null)" = "3"`
  - **Commit**: `test(recovery): counter reached target`

## Test Mechanics

This task uses a counter file to track attempts:
1. First run: counter = 1, FAIL (triggers fix task 1.1.1)
2. After 1.1.1 fix: counter = 2, FAIL (triggers fix task 1.1.2)
3. After 1.1.2 fix: counter = 3, PASS

The spec-executor should:
1. Read .counter file (default 0 if missing)
2. Increment counter and write back
3. If counter < 3: output failure format
4. If counter >= 3: output success

Expected fix tasks generated:
- 1.1.1 [FIX 1.1] Fix: counter increment issue
- 1.1.2 [FIX 1.1] Fix: counter still not at target

## Usage

```bash
# Run with recovery mode enabled
/ralph-specum:implement --recovery-mode

# Or manually set recoveryMode in state
```
