# Mock Quality Checks

Detect mock-only test anti-patterns where tests pass but don't actually test implementation.

## Red Flags

### 1. Mockery Pattern

Test file has more mock setup than real assertions.

**Detection:**
```bash
grep -c "mock\|stub\|spy" test-file
grep -c "expect(" test-file
```

**Red flag:** Mock lines > 3x assertion lines

### 2. Missing Real Imports

Test only imports test libraries, not actual module.

**Detection:** Check if test imports the real implementation:
```javascript
// Good: imports real module
import { authenticate } from '../auth'

// Bad: only imports test libraries
import { describe, it, expect, vi } from 'vitest'
```

**Red flag:** Only imports from jest/vitest/testing-library

### 3. Behavioral-Only Testing

All assertions are mock interactions, no state/value checks.

**Detection:**
```bash
grep "toHaveBeenCalled\|spy.calledWith" test-file
```

**Red flag:** No `toBe`, `toEqual`, `toMatch` assertions on real values

### 4. No Integration Coverage

Every dependency is mocked, no real integration tested.

**Detection:** Check if any tests run without mocks

**Red flag:** 100% mock coverage = 0% real integration tested

### 5. Partial Mocking Issues

Excessive use of `vi.spyOn`/`jest.spyOn`.

**Red flag:** Mixing real and mocked behavior creates unpredictability

### 6. No Mock Cleanup

Mocks persist across tests.

**Detection:**
```bash
grep "afterEach\|mockClear\|mockReset" test-file
```

**Red flag:** Missing cleanup = flaky tests

## Quality Check Report Format

### When Issues Detected

```text
Mock Quality Issues Detected

File: src/auth.test.ts
- Mock declarations: 15
- Real assertions: 3
- Mock ratio: 5.0x (threshold: 3x)
- Real module import: MISSING
- Integration tests: 0

Issues:
1. Missing import of actual auth module
2. All assertions verify mock interactions, none check real behavior
3. No integration test coverage

Suggested fixes:
- Import actual auth module: import { authenticate } from '../auth'
- Add state-based assertions: expect(result).toEqual({...})
- Create integration test with real dependencies
- Reduce mocking to only external services (network, DB)

Status: VERIFICATION_FAIL (test quality issues)
```

### When Tests Are Healthy

```text
Mock Quality Check: PASS

File: src/auth.test.ts
- Mock declarations: 2 (external services only)
- Real assertions: 12
- Real module import: YES
- Integration tests: 3
- Mock cleanup: afterEach present

Tests verify real behavior, not mock behavior.
```

## Reality Check for Test Fixes

For "fix tests" specs, verify BOTH conditions:
1. Tests pass
2. Tests actually test real behavior (not just mocks)

### Before State

```markdown
## Reality Check (BEFORE)

**Tests**: FAILING
**Mock ratio**: N/A (tests failing)
```

### After State (Good)

```markdown
## Reality Check (AFTER)

**Tests**: PASSING
**Mock quality check**:
- Mock declarations: 2
- Real assertions: 15
- Real module import: YES
- Integration tests: 3
- Mock cleanup: afterEach present

**Verdict**: Tests pass AND test real behavior
```

### After State (Bad)

```markdown
## Reality Check (AFTER)

**Tests**: PASSING (warning)
**Mock quality issues**:
- Mock declarations: 20
- Real assertions: 4
- Mock ratio: 5.0x (exceeds 3x threshold)
- Real module import: MISSING
- Integration tests: 0

**Verdict**: Tests pass but only test mocks, not implementation
**Required**: Fix test quality before marking VERIFICATION_PASS
```
