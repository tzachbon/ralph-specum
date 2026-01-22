# Goal Detection Patterns

Regex patterns and heuristics for classifying user goals as Fix or Add type.

## Detection Heuristics

| Pattern | Type | Regex |
|---------|------|-------|
| fix, repair, resolve, debug, patch | Fix | `\b(fix\|repair\|resolve\|debug\|patch)\b` |
| broken, failing, error, bug, issue | Fix | `\b(broken\|failing\|error\|bug\|issue)\b` |
| "not working", "doesn't work" | Fix | `not\s+working\|doesn't\s+work` |
| crash, crashing | Fix | `\b(crash\|crashing)\b` |
| add, create, build, implement, new | Add | `\b(add\|create\|build\|implement\|new)\b` |
| enable, introduce, support | Add | `\b(enable\|introduce\|support)\b` |

## Classification Algorithm

```text
1. Scan goal text for Fix indicators (higher priority)
2. If Fix indicators found -> classify as Fix
3. Else scan for Add indicators
4. If Add indicators found -> classify as Add
5. If both present -> classify as Fix (fixing enables the feature)
6. If neither -> default to Add
```

## Examples

| Goal | Classification | Reason |
|------|---------------|--------|
| "Fix login bug" | Fix | Contains "fix" and "bug" |
| "Add dark mode" | Add | Contains "add" |
| "Create auth endpoint" | Add | Contains "create" |
| "Resolve failing tests" | Fix | Contains "resolve" and "failing" |
| "Build new API and fix errors" | Fix | Both present, Fix takes priority |
| "Implement user registration" | Add | Contains "implement" |
| "Debug performance issue" | Fix | Contains "debug" and "issue" |

## Command Mapping

Map goal keywords to reproduction commands:

| Goal Keywords | Reproduction Command |
|---------------|---------------------|
| CI, pipeline, actions | `gh run view --log-failed` |
| test, tests, spec | project test command (package.json scripts.test) |
| type, types, typescript | `pnpm check-types` or `tsc --noEmit` |
| lint, linting | `pnpm lint` or `eslint .` |
| build, compile | `pnpm build` or `npm run build` |
| deploy, deployment | `gh api` or MCP fetch to check status |
| E2E, UI, browser, visual | MCP playwright to screenshot or run E2E suite |
| endpoint, API, response | MCP fetch with expected status/response validation |
| site, page, live | MCP fetch/playwright to verify live behavior |

## Fallback

If no keyword match:
1. Ask user for reproduction steps
2. Or skip diagnosis if goal is clearly Add type
