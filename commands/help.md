---
description: Show help for Ralph Specum plugin commands and workflow.
---

# Ralph Specum Help

## Overview

Ralph Specum combines the Ralph Wiggum agentic loop with spec-driven development. It generates specifications from a goal description and executes tasks autonomously with smart compaction between phases.

## Commands

| Command | Description |
|---------|-------------|
| `/ralph-specum "goal" [options]` | Start the spec-driven loop |
| `/ralph-specum:approve` | Approve current phase (interactive mode) |
| `/ralph-specum:cancel` | Cancel active loop and cleanup |
| `/ralph-specum:help` | Show this help |

## Usage

### Interactive Mode (default)
```
/ralph-specum "Add user authentication with JWT tokens" --mode interactive --dir ./auth-spec
```

Pauses after each phase for your approval:
1. Requirements → approve → compact
2. Design → approve → compact
3. Tasks → approve → compact
4. Execution (runs all tasks, compacts after each)

### Autonomous Mode
```
/ralph-specum "Refactor database layer" --mode auto --dir ./db-refactor
```

Runs through all phases without pausing. Compacts automatically.

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--mode` | `interactive` | `interactive` or `auto` |
| `--dir` | `./spec` | Directory for spec files |

## Files Created

In your spec directory:
- `requirements.md` - User stories, acceptance criteria
- `design.md` - Architecture, patterns, file matrix
- `tasks.md` - Phased task breakdown
- `.ralph-state.json` - Loop state (deleted on completion)
- `.ralph-progress.md` - Progress and learnings (deleted on completion)

## Smart Compaction

Context is compacted at phase boundaries with phase-specific preservation:
- **Requirements**: Preserves user stories, AC, FR/NFR, glossary
- **Design**: Preserves architecture, patterns, file paths
- **Tasks**: Preserves task list, dependencies
- **Per-task**: Preserves current task context only

The `.ralph-progress.md` file carries learnings and state across compactions.

## Troubleshooting

**Loop not continuing?**
- Check if in interactive mode and waiting for `/ralph-specum:approve`
- Verify `.ralph-state.json` exists in spec directory

**Lost context after compaction?**
- Check `.ralph-progress.md` for preserved state
- Learnings should persist across compactions

**Cancel and restart?**
- Run `/ralph-specum:cancel --dir ./your-spec`
- Then restart with `/ralph-specum`
