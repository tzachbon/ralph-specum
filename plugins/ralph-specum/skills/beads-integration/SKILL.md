# Beads Integration

Smart Ralph v3.0 uses [Beads](https://github.com/steveyegge/beads) for dependency-aware task management.

## What is Beads?

Beads is a lightweight git-based issue tracker designed for AI coding agents. It provides:
- **Dependency-aware tasks**: 4 relationship types (blocks, related, parent-child, discovered-from)
- **Ready-work detection**: `bd list --ready` finds unblocked tasks in ~10ms
- **Hash-based IDs**: Prevents collisions during parallel task creation
- **Git-native sync**: JSONL export with auto-commit/push

## Core Commands

| Command | Purpose | When to Use |
|---------|---------|-------------|
| `bd create --title "X" --json` | Create issue, returns ID | task-planner creating tasks |
| `bd create --parent $ID` | Create child issue | tasks under spec |
| `bd create --blocks $ID` | Create with dependency | task depends on another |
| `bd list --ready --json` | Get unblocked tasks | coordinator finding next task |
| `bd show $ID --json` | Get issue details | reading task info |
| `bd update $ID --notes "X"` | Add notes to issue | recording learnings |
| `bd close $ID --reason "X"` | Complete issue | task finished |
| `bd sync` | Export to JSONL + push | end of session |
| `bd prime` | Get workflow context | efficient context loading |
| `bd doctor` | Check for orphaned work | verify completion |

## Issue Structure for Smart Ralph

### Spec (Parent Issue)
```bash
bd create --title "$SPEC_NAME" --type epic --notes "Goal: $GOAL" --json
# Returns: {"id": "bd-abc123", ...}
```

### Task (Child Issue with Dependencies)
```bash
# First task - no blockers
bd create --title "1.1 Setup config" --parent bd-abc123 --json
# Returns: {"id": "bd-def456", ...}

# Second task - blocks on first
bd create --title "1.2 Create endpoints" --parent bd-abc123 --blocks bd-def456 --json

# Parallel tasks - same blockers
bd create --title "1.3 [P] Login UI" --parent bd-abc123 --blocks bd-ghi789 --json
bd create --title "1.4 [P] Logout UI" --parent bd-abc123 --blocks bd-ghi789 --json
```

### [VERIFY] Tasks
```bash
bd create --title "V1 [VERIFY] Quality check" --parent bd-abc123 --blocks bd-prev1,bd-prev2 --json
```

## Workflow Integration

### 1. Research Phase
- Create parent Beads issue for spec
- Store issue ID in `.ralph-state.json` as `beadsSpecId`

### 2. Task Planning Phase
- Create child Beads issues for each task
- Set `--blocks` relationships based on task dependencies
- Store task-to-issue mapping in `tasks.md` frontmatter

### 3. Execution Phase
- Use `bd list --ready --json` to find executable tasks
- Use `bd prime` for efficient context loading
- On task completion: `bd close $ID --reason "completed"`
- Include issue ID in commit: `feat(scope): msg (bd-abc123)`

### 4. Completion
- Run `bd sync` to export issues and push
- Run `bd doctor` to verify no orphaned work
- Delete `.ralph-state.json` (Beads is source of truth)

## Commit Message Convention

Always include Beads issue ID in commits:
```
feat(auth): implement OAuth2 login (bd-abc123)
```

This creates audit trail linking commits to issues.

## Landing the Plane Protocol

End every session with:
```bash
# 1. File remaining work
bd create --title "Follow-up: X" --discovered-from bd-current

# 2. Run quality gates
pnpm lint && pnpm typecheck && pnpm test

# 3. Update issue statuses
bd close bd-completed-task --reason "completed"

# 4. Sync and push
git pull --rebase
bd sync
git push
git status  # Must show "up to date"
```

## State File Changes

`.ralph-state.json` now includes:
```json
{
  "beadsSpecId": "bd-abc123",
  "beadsEnabled": true,
  "taskBeadsMap": {
    "1.1": "bd-def456",
    "1.2": "bd-ghi789"
  }
}
```

## Prerequisites

Beads is **required** for Smart Ralph v3.0. If not installed:
```bash
brew install steveyegge/tap/beads
```

Without Beads, Smart Ralph will not function. This is a hard dependency.
