---
spec: skills-per-capability
phase: design
created: 2026-01-13
generated: auto
---

# Design: skills-per-capability

## Overview

Replace single spec-workflow skill with 8 capability-specific skills. Each skill gets dedicated directory with focused SKILL.md.

## Architecture

```
plugins/ralph-specum/skills/
├── start-spec/SKILL.md        # Entry points: start, new
├── research-phase/SKILL.md    # Research: research
├── requirements-phase/SKILL.md # Requirements: requirements
├── design-phase/SKILL.md      # Design: design
├── tasks-phase/SKILL.md       # Tasks: tasks
├── execution/SKILL.md         # Execution: implement
├── management/SKILL.md        # Management: status, switch, cancel
└── help/SKILL.md              # Help: help
```

## Components

### start-spec/SKILL.md
**Purpose**: Entry points for creating and resuming specs
**Commands**: start, new
**Triggers**: "start spec", "new feature", "begin", "create"

### research-phase/SKILL.md
**Purpose**: Research and feasibility analysis
**Commands**: research
**Triggers**: "research", "analyze", "investigate", "feasibility"

### requirements-phase/SKILL.md
**Purpose**: Requirements and user stories
**Commands**: requirements
**Triggers**: "requirements", "user stories", "what to build"

### design-phase/SKILL.md
**Purpose**: Technical design and architecture
**Commands**: design
**Triggers**: "design", "architecture", "how to build"

### tasks-phase/SKILL.md
**Purpose**: Task breakdown and planning
**Commands**: tasks
**Triggers**: "tasks", "breakdown", "planning", "work items"

### execution/SKILL.md
**Purpose**: Task execution loop
**Commands**: implement
**Triggers**: "implement", "execute", "run", "build it"

### management/SKILL.md
**Purpose**: Spec lifecycle management
**Commands**: status, switch, cancel
**Triggers**: "status", "switch", "cancel", "stop", "which spec"

### help/SKILL.md
**Purpose**: Plugin guidance and documentation
**Commands**: help
**Triggers**: "help", "how to use", "commands", "guide"

## File Structure

| File | Action | Purpose |
|------|--------|---------|
| plugins/ralph-specum/skills/start-spec/SKILL.md | Create | start, new commands |
| plugins/ralph-specum/skills/research-phase/SKILL.md | Create | research command |
| plugins/ralph-specum/skills/requirements-phase/SKILL.md | Create | requirements command |
| plugins/ralph-specum/skills/design-phase/SKILL.md | Create | design command |
| plugins/ralph-specum/skills/tasks-phase/SKILL.md | Create | tasks command |
| plugins/ralph-specum/skills/execution/SKILL.md | Create | implement command |
| plugins/ralph-specum/skills/management/SKILL.md | Create | status, switch, cancel |
| plugins/ralph-specum/skills/help/SKILL.md | Create | help command |
| plugins/ralph-specum/skills/spec-workflow/SKILL.md | Delete | Original monolithic file |

## SKILL.md Template

Each file follows this structure:

```markdown
---
name: <skill-name>
description: <one-line focused description>
---

# <Skill Title>

## When to Use

Use these commands when:
- <specific trigger scenario 1>
- <specific trigger scenario 2>
- <specific trigger scenario 3>

## Commands

### <Command Name>
- `/ralph-specum:<command> [args]` - <description>

[Additional commands if applicable]
```

## Content Per Skill

### start-spec/SKILL.md

```markdown
---
name: start-spec
description: Create new specs or resume existing ones
---

# Start Spec

## When to Use

Use these commands when:
- Starting a new feature or project
- Resuming work on an existing spec
- Creating a spec from a plan or goal

## Commands

### Starting Work
- `/ralph-specum:start [name] [goal]` - Smart entry: resume or create
- `/ralph-specum:new <name> [goal]` - Create new spec and begin research
```

### research-phase/SKILL.md

```markdown
---
name: research-phase
description: Research and feasibility analysis for specs
---

# Research Phase

## When to Use

Use this command when:
- Analyzing feasibility of a feature
- Investigating best practices
- Exploring codebase for patterns
- Starting discovery for a new spec

## Commands

### Research
- `/ralph-specum:research` - Run research phase for current spec
```

### requirements-phase/SKILL.md

```markdown
---
name: requirements-phase
description: Generate requirements and user stories
---

# Requirements Phase

## When to Use

Use this command when:
- Defining what to build
- Creating user stories
- Documenting acceptance criteria
- Moving from research to planning

## Commands

### Requirements
- `/ralph-specum:requirements` - Generate requirements from research
```

### design-phase/SKILL.md

```markdown
---
name: design-phase
description: Technical design and architecture decisions
---

# Design Phase

## When to Use

Use this command when:
- Planning architecture
- Making technical decisions
- Documenting component structure
- Defining data flow

## Commands

### Design
- `/ralph-specum:design` - Generate technical design
```

### tasks-phase/SKILL.md

```markdown
---
name: tasks-phase
description: Generate implementation tasks from design
---

# Tasks Phase

## When to Use

Use this command when:
- Breaking down work into tasks
- Creating implementation plan
- Preparing for execution
- Moving from design to building

## Commands

### Tasks
- `/ralph-specum:tasks` - Generate implementation tasks
```

### execution/SKILL.md

```markdown
---
name: execution
description: Execute implementation tasks autonomously
---

# Execution

## When to Use

Use this command when:
- Ready to build the feature
- Tasks are defined and approved
- Starting autonomous implementation
- Resuming paused execution

## Commands

### Implementation
- `/ralph-specum:implement` - Start task execution loop
```

### management/SKILL.md

```markdown
---
name: management
description: Manage spec status, switching, and cancellation
---

# Spec Management

## When to Use

Use these commands when:
- Checking progress on specs
- Switching between specs
- Stopping execution
- Viewing all specs

## Commands

### Status and Control
- `/ralph-specum:status` - Show all specs and progress
- `/ralph-specum:switch <name>` - Change active spec
- `/ralph-specum:cancel` - Cancel active execution
```

### help/SKILL.md

```markdown
---
name: help
description: Get help with Ralph Specum commands
---

# Help

## When to Use

Use this command when:
- Learning the plugin
- Forgetting command syntax
- Need workflow guidance
- Troubleshooting issues

## Commands

### Help
- `/ralph-specum:help` - Show plugin help and commands
```

## Existing Patterns to Follow

- Frontmatter format from `plugins/ralph-specum/skills/spec-workflow/SKILL.md`
- Command syntax: `/ralph-specum:<command>` with argument hints
- Directory structure: `skills/<name>/SKILL.md`

## Error Handling

| Error | Handling | User Impact |
|-------|----------|-------------|
| Missing skill directory | Create during task | None |
| Original file still exists | Delete in final task | Duplicate triggers |
