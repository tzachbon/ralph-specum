---
spec: skills-per-capability
phase: requirements
created: 2026-01-13
generated: auto
---

# Requirements: skills-per-capability

## Summary

Split monolithic SKILL.md into 8 capability-focused skill files with specific triggers per capability.

## User Stories

### US-1: Find relevant skill by intent

As a developer, I want skill files organized by capability so that the AI loads only relevant context for my current task.

**Acceptance Criteria**:
- AC-1.1: Each capability has dedicated SKILL.md
- AC-1.2: "When to Use" section matches specific intents
- AC-1.3: Only relevant commands listed per skill

### US-2: Start new spec work

As a developer, I want a start-spec skill when I say "start a new spec" or "create a feature" so the AI knows to use start/new commands.

**Acceptance Criteria**:
- AC-2.1: start-spec/SKILL.md exists
- AC-2.2: Contains start and new commands
- AC-2.3: Triggers on "start", "begin", "create spec", "new feature"

### US-3: Run research phase

As a developer, I want research-phase skill triggered when discussing research or analysis.

**Acceptance Criteria**:
- AC-3.1: research-phase/SKILL.md exists
- AC-3.2: Contains research command only
- AC-3.3: Triggers on "research", "analyze", "investigate", "feasibility"

### US-4: Run requirements phase

As a developer, I want requirements-phase skill for defining what to build.

**Acceptance Criteria**:
- AC-4.1: requirements-phase/SKILL.md exists
- AC-4.2: Contains requirements command
- AC-4.3: Triggers on "requirements", "user stories", "what to build"

### US-5: Run design phase

As a developer, I want design-phase skill for architecture decisions.

**Acceptance Criteria**:
- AC-5.1: design-phase/SKILL.md exists
- AC-5.2: Contains design command
- AC-5.3: Triggers on "design", "architecture", "how to build"

### US-6: Run tasks phase

As a developer, I want tasks-phase skill for work breakdown.

**Acceptance Criteria**:
- AC-6.1: tasks-phase/SKILL.md exists
- AC-6.2: Contains tasks command
- AC-6.3: Triggers on "tasks", "breakdown", "planning", "implementation plan"

### US-7: Execute implementation

As a developer, I want execution skill for running tasks.

**Acceptance Criteria**:
- AC-7.1: execution/SKILL.md exists
- AC-7.2: Contains implement command
- AC-7.3: Triggers on "implement", "execute", "run tasks", "build it"

### US-8: Manage specs

As a developer, I want management skill for status, switching, and canceling.

**Acceptance Criteria**:
- AC-8.1: management/SKILL.md exists
- AC-8.2: Contains status, switch, cancel commands
- AC-8.3: Triggers on "status", "switch", "cancel", "which spec", "stop"

### US-9: Get help

As a developer, I want help skill when asking for guidance.

**Acceptance Criteria**:
- AC-9.1: help/SKILL.md exists
- AC-9.2: Contains help command
- AC-9.3: Triggers on "help", "how to use", "commands", "what can you do"

## Functional Requirements

| ID | Requirement | Priority | Source |
|----|-------------|----------|--------|
| FR-1 | Create 8 skill directories under plugins/ralph-specum/skills/ | Must | US-1 |
| FR-2 | Each SKILL.md has frontmatter with name and description | Must | US-1 |
| FR-3 | Each SKILL.md has focused "When to Use" section | Must | US-1 |
| FR-4 | Each SKILL.md lists only its relevant commands | Must | US-1 |
| FR-5 | start-spec skill covers start, new commands | Must | US-2 |
| FR-6 | research-phase skill covers research command | Must | US-3 |
| FR-7 | requirements-phase skill covers requirements command | Must | US-4 |
| FR-8 | design-phase skill covers design command | Must | US-5 |
| FR-9 | tasks-phase skill covers tasks command | Must | US-6 |
| FR-10 | execution skill covers implement command | Must | US-7 |
| FR-11 | management skill covers status, switch, cancel | Must | US-8 |
| FR-12 | help skill covers help command | Must | US-9 |
| FR-13 | Remove original spec-workflow/SKILL.md | Should | All |

## Non-Functional Requirements

| ID | Requirement | Category |
|----|-------------|----------|
| NFR-1 | Each SKILL.md under 50 lines for fast loading | Performance |
| NFR-2 | Consistent formatting across all skill files | Maintainability |

## Out of Scope

- Command file modifications
- Plugin system changes
- New commands

## Dependencies

- Existing command files remain unchanged
- Plugin system skill loading works with new directory structure
