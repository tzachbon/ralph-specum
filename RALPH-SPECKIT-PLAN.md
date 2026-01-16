# Ralph-SpecKit Plugin Implementation Plan

## Overview

Create a new Claude Code plugin called `ralph-speckit` that follows the patterns of `ralph-specum` but uses GitHub's [spec-kit](https://github.com/github/spec-kit) methodology as its foundation.

## Key Differences: Ralph-Specum vs Spec-Kit

| Aspect | Ralph-Specum | Spec-Kit |
|--------|--------------|----------|
| **Starting Point** | Directly start with research | Constitution (governing principles) first |
| **Phases** | research → requirements → design → tasks → implement | constitution → specify → plan → tasks → implement |
| **Research** | Dedicated research phase | Research embedded in planning phase |
| **Focus** | POC-first, 4-phase methodology | What/Why first, then How |
| **Branching** | feat/<spec-name> | numeric prefix: 001-feature-name |
| **Optional Steps** | None | clarify, analyze, checklist |
| **State Directory** | `./specs/<name>/` | `.specify/specs/<feature>/` |
| **Memory** | In .progress.md only | `.specify/memory/constitution.md` |

## Plugin Architecture

### Directory Structure

```
plugins/ralph-speckit/
├── .claude-plugin/
│   └── plugin.json                 # Plugin manifest
├── agents/                         # Sub-agent definitions
│   ├── constitution-writer.md      # Create/update project principles
│   ├── spec-writer.md              # Define what to build (specify)
│   ├── tech-planner.md             # Create technical implementation plan
│   ├── task-generator.md           # Generate actionable task breakdown
│   ├── spec-executor.md            # Autonomous task execution
│   ├── clarifier.md                # Clarify underspecified areas
│   ├── analyzer.md                 # Cross-artifact consistency analysis
│   └── qa-engineer.md              # Verification task execution
├── commands/                       # Slash command definitions
│   ├── start.md                    # Smart entry point
│   ├── constitution.md             # Create/update governing principles
│   ├── specify.md                  # Define requirements & user stories
│   ├── plan.md                     # Create technical implementation plan
│   ├── tasks.md                    # Generate task breakdown
│   ├── implement.md                # Execute all tasks
│   ├── clarify.md                  # (Optional) Clarify requirements
│   ├── analyze.md                  # (Optional) Consistency analysis
│   ├── checklist.md                # (Optional) Generate quality checklist
│   ├── status.md                   # Show feature status
│   ├── switch.md                   # Switch active feature
│   ├── cancel.md                   # Cancel execution
│   ├── help.md                     # Help documentation
│   └── _delegation-principle.md    # Core principle doc
├── hooks/
│   ├── hooks.json                  # Hook configuration
│   └── scripts/
│       └── stop-handler.sh         # Task loop state machine
├── schemas/
│   └── speckit.schema.json         # JSON schema for specs & state
└── templates/                      # Artifact templates
    ├── constitution.md             # Constitution template
    ├── spec.md                     # Specification template
    ├── plan.md                     # Implementation plan template
    ├── research.md                 # Research findings template
    ├── tasks.md                    # Tasks template
    └── progress.md                 # Progress tracking template
```

---

## Phase 1: Core Infrastructure

### 1.1 Plugin Manifest

**File**: `.claude-plugin/plugin.json`

```json
{
  "name": "ralph-speckit",
  "version": "1.0.0",
  "description": "Spec-driven development using GitHub's spec-kit methodology with task-by-task execution",
  "author": { "name": "tzachbon" },
  "license": "MIT",
  "keywords": ["ralph", "speckit", "spec-driven", "constitution", "specify", "plan", "tasks", "autonomous"]
}
```

### 1.2 State File Structure

**Directory**: `.speckit/` (root level) + `.speckit/specs/<feature>/`

#### `.speckit/memory/constitution.md` - Project Principles (Persistent)
```markdown
---
project: {{PROJECT_NAME}}
created: {{TIMESTAMP}}
updated: {{TIMESTAMP}}
---

# Project Constitution

## Core Principles
[Governing guidelines for all development]

## Code Quality Standards
[Linting, formatting, testing requirements]

## Technical Constraints
[Required stack, forbidden patterns, etc.]

## User Experience Guidelines
[UX consistency rules]

## Performance Requirements
[Performance targets and metrics]

## Decision Framework
[How to make technical decisions]
```

#### `.speckit/.current-feature` - Active Feature Pointer
```
001-create-taskify
```

#### `.speckit/specs/<feature>/.speckit-state.json` - Execution State
```json
{
  "source": "workflow|quick",
  "name": "create-taskify",
  "featureId": "001",
  "basePath": "./.speckit/specs/001-create-taskify",
  "phase": "constitution|specify|plan|tasks|execution",
  "taskIndex": 0,
  "totalTasks": 15,
  "taskIteration": 1,
  "maxTaskIterations": 5,
  "globalIteration": 1,
  "maxGlobalIterations": 100,
  "awaitingApproval": false
}
```

---

## Phase 2: Agent Definitions

### 2.1 constitution-writer.md

**Purpose**: Create or update project governing principles

**Tools**: `Read, Write, Edit, Glob, Grep`

**Methodology**:
1. Analyze existing codebase for patterns (if any)
2. Parse user's requirements for principles
3. Create/update `.speckit/memory/constitution.md`
4. Focus areas:
   - Code quality & testing standards
   - UX consistency guidelines
   - Performance requirements
   - Technical constraints
   - Decision-making framework

**Output**: `.speckit/memory/constitution.md`

### 2.2 spec-writer.md

**Purpose**: Transform user goal into functional specification (WHAT + WHY, not HOW)

**Tools**: `Read, Write, Edit, Glob, Grep, WebSearch`

**Methodology**:
1. Read constitution for guiding principles
2. Understand user's goal (what they want to build)
3. Create comprehensive user stories with acceptance criteria
4. Define functional and non-functional requirements
5. Explicitly state what's out of scope
6. **DO NOT** specify tech stack or implementation details

**Output**: `.speckit/specs/<feature>/spec.md`

**Template Structure**:
```markdown
---
feature: {{FEATURE_NAME}}
featureId: {{FEATURE_ID}}
phase: specify
created: {{TIMESTAMP}}
---

# Specification: {{FEATURE_NAME}}

## Goal
[1-2 sentence description of WHAT and WHY]

## User Stories
- US-1: Story title
  - As a {{user type}}
  - I want {{action}}
  - So that {{benefit}}
  - **Acceptance Criteria:**
    - AC-1.1: {{testable criterion}}

## Functional Requirements
| ID | Requirement | Priority | Acceptance Criteria |

## Non-Functional Requirements
| ID | Requirement | Metric | Target |

## Out of Scope
[Explicit exclusions]

## Dependencies
[Prerequisites]

## Review & Acceptance Checklist
- [ ] All user stories have acceptance criteria
- [ ] Requirements are testable
- [ ] Out of scope is clear
- [ ] No implementation details in requirements
```

### 2.3 clarifier.md (Optional Agent)

**Purpose**: Structured clarification of underspecified areas

**Tools**: `Read, Write, Edit`

**Methodology**:
1. Read spec.md thoroughly
2. Identify ambiguous or underspecified areas
3. Ask sequential, coverage-based questions
4. Record answers in Clarifications section of spec.md
5. Continue until no major gaps remain

**Output**: Updated `spec.md` with Clarifications section

### 2.4 tech-planner.md

**Purpose**: Create technical implementation plan based on spec and user's tech stack preferences

**Tools**: `Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch`

**Methodology**:
1. Read constitution and spec.md
2. Accept tech stack preferences from user
3. Research best practices for chosen stack (brief, targeted)
4. Analyze existing codebase for patterns
5. Design architecture with components
6. Define data models and API contracts
7. Create file structure plan
8. Document technical decisions with trade-offs
9. Write research.md with findings
10. Write plan.md with implementation details

**Outputs**:
- `.speckit/specs/<feature>/research.md` - Research findings
- `.speckit/specs/<feature>/plan.md` - Implementation plan
- `.speckit/specs/<feature>/contracts/` (optional) - API specs, schemas

### 2.5 task-generator.md

**Purpose**: Generate actionable task breakdown from implementation plan

**Tools**: `Read, Write, Edit, Glob, Grep`

**Methodology**:
1. Read spec.md, plan.md, research.md
2. Create task breakdown organized by user story
3. Respect dependencies between components
4. Mark parallel-executable tasks with `[P]`
5. Include quality checkpoints every 2-3 tasks
6. Insert `[VERIFY]` checkpoints for validation
7. Each task must have: Do, Files, Done when, Verify, Commit

**Output**: `.speckit/specs/<feature>/tasks.md`

**Task Format**:
```markdown
- [ ] 1.1 [P] Task name
  - **Do**: Exact implementation steps
  - **Files**: [paths to create/modify]
  - **Done when**: Explicit success criteria
  - **Verify**: Command to verify completion
  - **Commit**: `feat(scope): description`
  - _Spec: US-1, AC-1.1_
  - _Plan: Component A_
```

### 2.6 analyzer.md (Optional Agent)

**Purpose**: Cross-artifact consistency and coverage analysis

**Tools**: `Read, Write, Edit, Glob`

**Methodology**:
1. Read all artifacts (constitution, spec, plan, tasks)
2. Check for consistency between documents
3. Verify all requirements are covered by tasks
4. Identify gaps or conflicts
5. Generate analysis report

**Output**: Analysis report in conversation (not file)

### 2.7 spec-executor.md

**Purpose**: Autonomously execute ONE task from tasks.md

**Tools**: Inherits from model (full access)

**Methodology**:
1. Read .progress.md for context
2. Read constitution for guiding principles
3. Parse current task from tasks.md
4. If `[VERIFY]` task: delegate to qa-engineer
5. Execute task steps exactly
6. Run verification command
7. On success:
   - Mark task `[x]` in tasks.md
   - Update .progress.md
   - Commit spec files + implementation files
   - Output `TASK_COMPLETE`

**Critical Rules**:
- ALWAYS commit spec files with every task
- NEVER output TASK_COMPLETE unless verification passes
- Follow constitution principles throughout

### 2.8 qa-engineer.md

**Purpose**: Execute `[VERIFY]` checkpoint tasks

**Tools**: `Read, Write, Edit, Bash, Glob, Grep`

**Verification Types**:
1. Command verification - Run specified commands
2. AC checklist verification - Verify acceptance criteria

**Output Signals**:
- `VERIFICATION_PASS` - All checks passed
- `VERIFICATION_FAIL` - Any check failed

---

## Phase 3: Command Definitions

### 3.1 Core Commands

| Command | Description |
|---------|-------------|
| `/speckit:start [name] [goal]` | Smart entry point with branch management |
| `/speckit:constitution [principles]` | Create/update governing principles |
| `/speckit:specify [description]` | Define what to build (requirements) |
| `/speckit:plan [tech-stack]` | Create technical implementation plan |
| `/speckit:tasks` | Generate task breakdown |
| `/speckit:implement` | Execute all tasks |

### 3.2 Optional Commands

| Command | Description |
|---------|-------------|
| `/speckit:clarify` | Clarify underspecified areas (before plan) |
| `/speckit:analyze` | Cross-artifact consistency analysis (before implement) |
| `/speckit:checklist` | Generate quality checklist |

### 3.3 Utility Commands

| Command | Description |
|---------|-------------|
| `/speckit:status` | Show feature status |
| `/speckit:switch <name>` | Switch active feature |
| `/speckit:cancel` | Cancel execution |
| `/speckit:help` | Help documentation |

### Command Details

#### start.md
```
/speckit:start [name] [goal] [--fresh] [--quick]
```

**Functionality**:
1. Branch management:
   - If on main/master: create feature branch `<featureId>-<name>`
   - Feature ID is auto-incremented (001, 002, etc.)
   - Use existing pattern from spec-kit
2. Detection logic:
   - If feature exists + no --fresh: ask Resume or Fresh
   - If new: guide through workflow
3. New flow:
   - Create feature directory
   - Initialize state
   - Guide user: "Run /speckit:constitution first if you haven't set up project principles"

#### constitution.md
```
/speckit:constitution [principles-description]
```

**Functionality**:
1. Check if `.speckit/memory/constitution.md` exists
2. If exists: offer to update or append
3. Delegate to constitution-writer agent
4. Constitution is PROJECT-LEVEL, not feature-level
5. **STOP** after completion for review

#### specify.md
```
/speckit:specify [what-to-build]
```

**Functionality**:
1. Validate constitution exists (warn if not)
2. Create feature directory if needed
3. Auto-generate feature ID
4. Delegate to spec-writer agent
5. **STOP** after completion for review

#### plan.md
```
/speckit:plan [tech-stack-description]
```

**Functionality**:
1. Validate spec.md exists
2. Accept tech stack preferences
3. Delegate to tech-planner agent
4. Creates both research.md and plan.md
5. **STOP** after completion for review

#### tasks.md
```
/speckit:tasks
```

**Functionality**:
1. Validate spec.md and plan.md exist
2. Delegate to task-generator agent
3. Count tasks and update state
4. **STOP** after completion for review

#### implement.md
```
/speckit:implement [--max-task-iterations 5]
```

**Functionality**:
1. **COMMIT SPECS FIRST** before any implementation
2. Count total tasks
3. Initialize execution state
4. Delegate to spec-executor for current task
5. Stop-handler manages task loop

---

## Phase 4: Hook System

### 4.1 hooks.json

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/stop-handler.sh\""
          }
        ]
      }
    ]
  }
}
```

### 4.2 stop-handler.sh

**Adapted from ralph-specum with these changes**:
- State file location: `.speckit/specs/<feature>/.speckit-state.json`
- Current feature pointer: `.speckit/.current-feature`
- Task completion signal: `TASK_COMPLETE` (same)
- Support for feature ID in prompts

---

## Phase 5: Templates

### 5.1 constitution.md (Project Level)

```markdown
---
project: {{PROJECT_NAME}}
created: {{TIMESTAMP}}
updated: {{TIMESTAMP}}
---

# Project Constitution

## Core Principles
[Foundational guidelines that govern all development decisions]

## Code Quality Standards
- Linting: [requirements]
- Formatting: [requirements]
- Testing: [coverage requirements, testing approach]
- Documentation: [inline comments, README requirements]

## Technical Constraints
- Required technologies: [list]
- Forbidden patterns: [list]
- Security requirements: [list]

## User Experience Guidelines
[UX consistency rules and patterns]

## Performance Requirements
| Metric | Target | Measurement |
|--------|--------|-------------|

## Decision Framework
[How to evaluate and make technical decisions]

## Quality Gates
[Checkpoints that must pass before merge]
```

### 5.2 spec.md (Feature Level)

```markdown
---
feature: {{FEATURE_NAME}}
featureId: {{FEATURE_ID}}
phase: specify
created: {{TIMESTAMP}}
---

# Specification: {{FEATURE_NAME}}

## Goal
[1-2 sentence description of WHAT you're building and WHY]

## User Stories

### US-1: [Story Title]
- **As a** [user type]
- **I want** [action/capability]
- **So that** [benefit/value]
- **Acceptance Criteria:**
  - AC-1.1: [Testable criterion]
  - AC-1.2: [Testable criterion]

## Functional Requirements

| ID | Requirement | Priority | Related AC |
|----|-------------|----------|------------|
| FR-1 | [Requirement] | Must | AC-1.1 |

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | [Requirement] | [Metric] | [Target] |

## Out of Scope
- [Explicit exclusion 1]
- [Explicit exclusion 2]

## Dependencies
- [Prerequisite 1]
- [Prerequisite 2]

## Clarifications
[Added by /speckit:clarify if used]

## Review & Acceptance Checklist
- [ ] All user stories have testable acceptance criteria
- [ ] Requirements are unambiguous
- [ ] Out of scope is explicitly defined
- [ ] No implementation details in requirements
- [ ] Dependencies are identified
```

### 5.3 plan.md (Feature Level)

```markdown
---
feature: {{FEATURE_NAME}}
featureId: {{FEATURE_ID}}
phase: plan
tech_stack: {{TECH_STACK_SUMMARY}}
created: {{TIMESTAMP}}
---

# Implementation Plan: {{FEATURE_NAME}}

## Overview
[2-3 sentence technical approach summary]

## Technology Stack
| Component | Choice | Rationale |
|-----------|--------|-----------|

## Architecture

### System Diagram
```mermaid
[Architecture diagram]
```

### Components

#### Component A
- **Purpose**: [What it does]
- **Responsibilities**: [List]
- **Interfaces**: [APIs, methods]

## Data Model
[Schema definitions, relationships]

## API Design
[Endpoints, contracts]

## File Structure
```
[Directory tree of files to create/modify]
```

## Technical Decisions

| Decision | Options Considered | Choice | Rationale |
|----------|-------------------|--------|-----------|

## Error Handling
[Error scenarios and strategies]

## Test Strategy
- **Unit Tests**: [Approach]
- **Integration Tests**: [Approach]
- **E2E Tests**: [Approach if applicable]

## Implementation Sequence
[Recommended order based on dependencies]

## Existing Patterns to Follow
[From codebase analysis]
```

### 5.4 research.md (Feature Level)

```markdown
---
feature: {{FEATURE_NAME}}
featureId: {{FEATURE_ID}}
phase: plan
created: {{TIMESTAMP}}
---

# Research: {{FEATURE_NAME}}

## Executive Summary
[2-3 sentence overview of findings]

## Technology Research

### [Technology 1]
- **Best Practices**: [Findings]
- **Pitfalls to Avoid**: [Findings]
- **Version Notes**: [Specific version considerations]

## Codebase Analysis

### Existing Patterns
| Pattern | Location | Notes |
|---------|----------|-------|

### Dependencies
[Existing dependencies relevant to feature]

### Constraints
[Technical constraints discovered]

## Quality Commands
| Purpose | Command |
|---------|---------|
| Lint | [command] |
| Test | [command] |
| Type Check | [command] |
| Build | [command] |

## Sources
- [Source 1]
- [Source 2]
```

### 5.5 tasks.md (Feature Level)

```markdown
---
feature: {{FEATURE_NAME}}
featureId: {{FEATURE_ID}}
phase: tasks
total_tasks: {{N}}
created: {{TIMESTAMP}}
---

# Tasks: {{FEATURE_NAME}}

## Implementation by User Story

### US-1: [Story Title]

#### Setup
- [ ] 1.1 [P] Task name
  - **Do**: Exact implementation steps
  - **Files**: [paths]
  - **Done when**: Success criteria
  - **Verify**: `command`
  - **Commit**: `feat(scope): description`
  - _Spec: FR-1, AC-1.1_
  - _Plan: Component A_

- [ ] 1.2 Task name
  - **Do**: Steps
  - **Files**: [paths]
  - **Done when**: Criteria
  - **Verify**: `command`
  - **Commit**: `feat(scope): description`
  - _Spec: FR-2_
  - _Plan: Component A_

- [ ] 1.X [VERIFY] Quality checkpoint
  - **Do**: Run quality commands from research.md
  - **Verify**: All commands exit 0
  - **Done when**: No errors
  - **Commit**: `chore: pass quality checkpoint`

### US-2: [Story Title]
[Similar structure]

## Final Quality Gates

- [ ] N.1 [VERIFY] Full quality check
  - **Do**: Run all lint, test, type, build commands
  - **Verify**: All pass
  - **Done when**: CI-ready

- [ ] N.2 Create PR
  - **Do**: Create pull request with summary
  - **Verify**: PR created successfully
  - **Done when**: PR URL available
  - **Commit**: N/A (PR creation)

- [ ] N.3 [VERIFY] AC Checklist
  - **Do**: Verify all acceptance criteria from spec.md
  - **Verify**: All AC pass
  - **Done when**: All checkboxes checked

## Notes
- **Parallel tasks**: Marked with [P]
- **Dependencies**: Task order reflects dependencies
```

### 5.6 progress.md (Feature Level)

```markdown
---
feature: {{FEATURE_NAME}}
featureId: {{FEATURE_ID}}
phase: execution
task: 0/{{TOTAL}}
updated: {{TIMESTAMP}}
---

# Progress: {{FEATURE_NAME}}

## Original Goal
[From spec.md Goal section]

## Constitution Reference
[Key principles from constitution.md relevant to this feature]

## Completed Tasks
[Updated as tasks complete]
- [x] 1.1 Task name - commit_hash
- [x] 1.2 Task name - commit_hash

## Current Task
[Current task being executed]

## Learnings
[Discoveries, patterns, gotchas]

## Blockers
[Any blocking issues]

## Next Steps
[Upcoming tasks]
```

---

## Phase 6: Implementation Tasks

### Task Breakdown

#### 6.1 Infrastructure (Priority 1)
- [ ] Create plugin directory structure
- [ ] Create plugin.json manifest
- [ ] Create hooks.json configuration
- [ ] Adapt stop-handler.sh for speckit paths/state

#### 6.2 Templates (Priority 2)
- [ ] Create constitution.md template
- [ ] Create spec.md template
- [ ] Create plan.md template
- [ ] Create research.md template
- [ ] Create tasks.md template
- [ ] Create progress.md template

#### 6.3 Agents (Priority 3)
- [ ] Create constitution-writer.md agent
- [ ] Create spec-writer.md agent
- [ ] Create tech-planner.md agent
- [ ] Create task-generator.md agent
- [ ] Create spec-executor.md agent (adapt from ralph-specum)
- [ ] Create qa-engineer.md agent (adapt from ralph-specum)
- [ ] Create clarifier.md agent (optional)
- [ ] Create analyzer.md agent (optional)

#### 6.4 Core Commands (Priority 4)
- [ ] Create start.md command
- [ ] Create constitution.md command
- [ ] Create specify.md command
- [ ] Create plan.md command
- [ ] Create tasks.md command
- [ ] Create implement.md command

#### 6.5 Optional Commands (Priority 5)
- [ ] Create clarify.md command
- [ ] Create analyze.md command
- [ ] Create checklist.md command

#### 6.6 Utility Commands (Priority 6)
- [ ] Create status.md command
- [ ] Create switch.md command
- [ ] Create cancel.md command
- [ ] Create help.md command
- [ ] Create _delegation-principle.md document

#### 6.7 Schema & Documentation (Priority 7)
- [ ] Create speckit.schema.json
- [ ] Update CLAUDE.md with speckit documentation

---

## Key Principles to Maintain

1. **Delegation is absolute** - Commands coordinate, agents implement
2. **Fresh context per task** - Stop-handler manages task loop
3. **Constitution-first** - Project principles guide all decisions
4. **What/Why before How** - Spec defines intent, plan defines implementation
5. **Quality checkpoints** - Every 2-3 tasks throughout execution
6. **Commit spec files** - Always commit spec files with every task
7. **TASK_COMPLETE protocol** - Required for task advancement

---

## Migration Path from Ralph-Specum

Users familiar with ralph-specum can understand speckit through this mapping:

| Ralph-Specum | Ralph-SpecKit | Notes |
|--------------|---------------|-------|
| /ralph-specum:research | Part of /speckit:plan | Research embedded in planning |
| /ralph-specum:requirements | /speckit:specify | Focus on what/why |
| /ralph-specum:design | /speckit:plan | Includes tech stack |
| /ralph-specum:tasks | /speckit:tasks | Same concept |
| /ralph-specum:implement | /speckit:implement | Same concept |
| N/A | /speckit:constitution | New: project principles |
| N/A | /speckit:clarify | New: optional clarification |
| N/A | /speckit:analyze | New: optional analysis |

---

## Success Criteria

1. Plugin loads correctly in Claude Code
2. All commands accessible via `/speckit:*`
3. Constitution persists across features
4. Task-by-task execution works via stop-handler
5. Spec files committed with each task
6. Progress tracking works across sessions
7. Quality checkpoints execute correctly
8. [VERIFY] tasks delegate to qa-engineer
