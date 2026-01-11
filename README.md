# Ralph Specum

Spec-driven development with smart compaction. A Claude Code plugin that combines the Ralph Wiggum agentic loop with structured specification workflow.

## Features

- **Spec-Driven Workflow**: Automatically generates requirements, design, and tasks from a goal description
- **Smart Compaction**: Strategic context management between phases and tasks
- **Persistent Progress**: Learnings and state survive compaction via progress file
- **Two Modes**: Interactive (pause per phase) or fully autonomous

## Installation

### From Marketplace

```
/plugin install ralph-specum@<marketplace>
```

### Local Installation

```
/plugin install /path/to/ralph-specum
```

## Quick Start

### Interactive Mode (Recommended)

```
/ralph-specum "Add user authentication with JWT tokens" --mode interactive --dir ./auth-spec
```

This will:
1. Generate `requirements.md` and pause for approval
2. After `/ralph-specum:approve`, generate `design.md` and pause
3. After approval, generate `tasks.md` and pause
4. After approval, execute all tasks (compacting after each)

### Autonomous Mode

```
/ralph-specum "Refactor database layer" --mode auto --dir ./db-refactor
```

Runs through all phases without pausing. Compacts automatically between phases and tasks.

## Commands

| Command | Description |
|---------|-------------|
| `/ralph-specum "goal" [options]` | Start the spec-driven loop |
| `/ralph-specum:approve` | Approve current phase (interactive mode) |
| `/ralph-specum:cancel` | Cancel active loop and cleanup |
| `/ralph-specum:help` | Show help |

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `--mode` | `interactive` | `interactive` or `auto` |
| `--dir` | `./spec` | Directory for spec files |

## How It Works

### Phase Workflow

```
Goal → Requirements → Design → Tasks → Execution
         ↓              ↓        ↓         ↓
      compact        compact  compact   compact (per task)
```

### Smart Compaction

Each phase transition uses targeted compaction:

| Phase | Preserves |
|-------|-----------|
| Requirements | User stories, acceptance criteria, FR/NFR, glossary |
| Design | Architecture, patterns, file paths |
| Tasks | Task list, dependencies, quality gates |
| Per-task | Current task context only |

### Progress File

The `.ralph-progress.md` file carries state across compactions:

```markdown
# Ralph Progress

## Current Goal
**Phase**: execution
**Task**: 3/7 - Implement auth flow
**Objective**: Create login/logout endpoints

## Completed
- [x] Task 1: Setup scaffolding
- [x] Task 2: Database schema
- [ ] Task 3: Auth flow (IN PROGRESS)

## Learnings
- Project uses Zod for validation
- Rate limiting exists in middleware/

## Next Steps
1. Complete JWT generation
2. Add refresh tokens
```

## Files Generated

In your spec directory:

| File | Purpose |
|------|---------|
| `requirements.md` | User stories, acceptance criteria |
| `design.md` | Architecture, patterns, file matrix |
| `tasks.md` | Phased task breakdown |
| `.ralph-state.json` | Loop state (deleted on completion) |
| `.ralph-progress.md` | Progress and learnings (deleted on completion) |

## Configuration

### Max Iterations

Default: 50 iterations. The loop stops if this limit is reached to prevent infinite loops.

### Templates

Templates in `templates/` can be customized for your project's needs.

## Troubleshooting

### Loop not continuing?

1. Check if in interactive mode waiting for `/ralph-specum:approve`
2. Verify `.ralph-state.json` exists in spec directory
3. Check iteration count hasn't exceeded max

### Lost context after compaction?

1. Check `.ralph-progress.md` for preserved state
2. Learnings should persist across compactions
3. The skill always reads progress file first

### Cancel and restart?

```
/ralph-specum:cancel --dir ./your-spec
/ralph-specum "your goal" --dir ./your-spec
```

## Development

### Plugin Structure

```
ralph-specum/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── commands/
│   ├── ralph-loop.md
│   ├── cancel-ralph.md
│   ├── approve.md
│   └── help.md
├── skills/
│   └── spec-workflow/
│       └── SKILL.md
├── hooks/
│   ├── hooks.json
│   └── scripts/
│       └── stop-handler.sh
├── templates/
│   ├── requirements.md
│   ├── design.md
│   ├── tasks.md
│   └── progress.md
└── README.md
```

## Credits

- Inspired by the [Ralph Wiggum](https://ghuntley.com/ralph/) agentic loop pattern
- Built for [Claude Code](https://claude.ai/code)

## License

MIT
