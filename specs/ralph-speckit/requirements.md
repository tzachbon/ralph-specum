---
spec: ralph-speckit
phase: requirements
created: 2026-01-14T00:00:00Z
---

# Requirements: ralph-speckit

## Goal

Create a Claude Code plugin called `ralph-speckit` that implements spec-driven development following GitHub's spec-kit methodology, enabling constitution-first governance, clear separation of intent (WHAT/WHY) from implementation (HOW), and autonomous task-by-task execution with fresh context per task.

## User Stories

### US-1: Initialize Project Governance

**As a** developer starting a new project or feature workflow
**I want to** define project-level governing principles (constitution)
**So that** all features and implementations follow consistent standards and constraints

**Acceptance Criteria:**
- [ ] AC-1.1: Constitution file is created at `.speckit/memory/constitution.md` when running `/speckit:constitution`
- [ ] AC-1.2: Constitution persists across all features (project-level, not feature-level)
- [ ] AC-1.3: Constitution includes sections for: Core Principles, Code Quality Standards, Technical Constraints, UX Guidelines, Performance Requirements, Decision Framework
- [ ] AC-1.4: If constitution already exists, user is offered options to update or append
- [ ] AC-1.5: Spec-writer and tech-planner agents reference constitution when generating artifacts

### US-2: Define Feature Specification

**As a** developer with a feature idea
**I want to** specify WHAT I want to build and WHY it matters
**So that** the implementation is guided by clear intent without premature technical decisions

**Acceptance Criteria:**
- [ ] AC-2.1: Running `/speckit:specify [description]` creates `spec.md` in `.speckit/specs/<id>-<name>/`
- [ ] AC-2.2: Feature ID is auto-incremented numerically (001, 002, 003)
- [ ] AC-2.3: Spec.md contains: Goal, User Stories with ACs, Functional Requirements, Non-Functional Requirements, Out of Scope, Dependencies
- [ ] AC-2.4: Spec.md contains NO implementation details, technology choices, or architecture
- [ ] AC-2.5: Each user story has testable acceptance criteria linked to requirements
- [ ] AC-2.6: Command warns if constitution does not exist before proceeding

### US-3: Create Technical Implementation Plan

**As a** developer with an approved specification
**I want to** create a technical implementation plan with chosen tech stack
**So that** I have a clear blueprint for how to build the feature

**Acceptance Criteria:**
- [ ] AC-3.1: Running `/speckit:plan [tech-stack]` validates that spec.md exists first
- [ ] AC-3.2: Plan phase produces both `research.md` and `plan.md` in the feature directory
- [ ] AC-3.3: Research.md includes: technology research, codebase analysis, existing patterns, quality commands
- [ ] AC-3.4: Plan.md includes: architecture, components, data model, API design, file structure, technical decisions, test strategy
- [ ] AC-3.5: Tech-planner agent performs web search for best practices on chosen stack
- [ ] AC-3.6: Plan references constitution principles and aligns with them

### US-4: Generate Actionable Task Breakdown

**As a** developer with an approved implementation plan
**I want to** generate a detailed task breakdown organized by user story
**So that** I have atomic, executable tasks with clear success criteria

**Acceptance Criteria:**
- [ ] AC-4.1: Running `/speckit:tasks` validates that spec.md and plan.md exist
- [ ] AC-4.2: Tasks are organized by user story (US-1, US-2, etc.)
- [ ] AC-4.3: Each task includes: Do (steps), Files, Done when, Verify (command), Commit message
- [ ] AC-4.4: Tasks trace back to spec requirements (Spec: FR-X, AC-X.X) and plan components (Plan: Component X)
- [ ] AC-4.5: Quality checkpoint tasks (marked `[VERIFY]`) appear every 2-3 implementation tasks
- [ ] AC-4.6: Parallel-executable tasks are marked with `[P]`
- [ ] AC-4.7: Final tasks include: full quality check, PR creation, AC verification checklist

### US-5: Execute Tasks Autonomously

**As a** developer with a generated task list
**I want to** execute tasks one-by-one with fresh context per task
**So that** each task gets full attention and state is preserved across sessions

**Acceptance Criteria:**
- [ ] AC-5.1: Running `/speckit:implement` commits spec files before starting any implementation
- [ ] AC-5.2: Stop-handler reads `.speckit-state.json` and advances taskIndex on `TASK_COMPLETE` signal
- [ ] AC-5.3: Spec-executor marks completed tasks with `[x]` in tasks.md
- [ ] AC-5.4: Spec-executor updates `.progress.md` with completed task and learnings
- [ ] AC-5.5: Each task is committed separately with the specified commit message
- [ ] AC-5.6: `[VERIFY]` tasks are delegated to qa-engineer agent
- [ ] AC-5.7: If TASK_COMPLETE not found, stop-handler retries up to maxTaskIterations (default 5)
- [ ] AC-5.8: On final task completion, state file and current-feature pointer are cleaned up

### US-6: Start New Feature Workflow

**As a** developer beginning a new feature
**I want to** use a smart entry point that handles branching and guides me through the workflow
**So that** I follow the correct process without remembering all commands

**Acceptance Criteria:**
- [ ] AC-6.1: Running `/speckit:start [name] [goal]` on main/master creates feature branch `<id>-<name>`
- [ ] AC-6.2: Feature directory is created at `.speckit/specs/<id>-<name>/`
- [ ] AC-6.3: If feature already exists without `--fresh` flag, user is asked to Resume or Fresh
- [ ] AC-6.4: State file `.speckit-state.json` is initialized with phase "specify"
- [ ] AC-6.5: Current feature pointer `.speckit/.current-feature` is updated
- [ ] AC-6.6: User is guided: "Run /speckit:constitution first if you haven't set up project principles"

### US-7: Track Feature Progress

**As a** developer working on a feature over multiple sessions
**I want to** view current status and resume where I left off
**So that** I maintain continuity across work sessions

**Acceptance Criteria:**
- [ ] AC-7.1: Running `/speckit:status` shows current feature, phase, task progress (X/N)
- [ ] AC-7.2: Status shows list of completed tasks and current/next task
- [ ] AC-7.3: Status shows any blockers or learnings from .progress.md
- [ ] AC-7.4: Running `/speckit:switch <feature-name>` changes the active feature
- [ ] AC-7.5: Running `/speckit:cancel` terminates execution and cleans up state

### US-8: Optional Clarification Phase

**As a** developer with an underspecified requirement
**I want to** run a structured clarification process
**So that** ambiguities are resolved before planning

**Acceptance Criteria:**
- [ ] AC-8.1: Running `/speckit:clarify` reads spec.md and identifies gaps
- [ ] AC-8.2: Clarifier agent asks sequential, coverage-based questions
- [ ] AC-8.3: Answers are recorded in a Clarifications section of spec.md
- [ ] AC-8.4: Process continues until no major ambiguities remain

### US-9: Optional Analysis Phase

**As a** developer before implementing
**I want to** analyze consistency across all artifacts
**So that** I catch gaps or conflicts before execution

**Acceptance Criteria:**
- [ ] AC-9.1: Running `/speckit:analyze` reads constitution, spec, plan, and tasks
- [ ] AC-9.2: Analyzer checks that all requirements are covered by tasks
- [ ] AC-9.3: Analyzer identifies inconsistencies between documents
- [ ] AC-9.4: Analysis report is output in conversation (not saved to file)

## Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-1 | Plugin loads in Claude Code with `/speckit:*` commands accessible | Must | Commands appear in autocomplete; `/speckit:help` returns documentation |
| FR-2 | Constitution persists at `.speckit/memory/constitution.md` project-level | Must | File survives across features; referenced by all agents |
| FR-3 | Feature IDs auto-increment (001, 002, 003) | Must | Creating new feature after 001 produces 002 |
| FR-4 | Spec phase produces spec.md with no implementation details | Must | Manual review confirms no tech choices in spec |
| FR-5 | Plan phase produces both research.md and plan.md | Must | Both files exist after `/speckit:plan` |
| FR-6 | Tasks trace to spec (FR-X, AC-X.X) and plan (Component X) | Must | Every task has _Spec:_ and _Plan:_ annotations |
| FR-7 | Stop-handler advances task on TASK_COMPLETE signal | Must | Transcript verification confirms signal detection |
| FR-8 | Spec files committed before implementation starts | Must | Git history shows spec commit before first task commit |
| FR-9 | Quality checkpoints every 2-3 tasks | Should | tasks.md contains `[VERIFY]` tasks at regular intervals |
| FR-10 | Parallel tasks marked with `[P]` | Should | tasks.md identifies tasks that can run concurrently |
| FR-11 | `/speckit:clarify` records answers in spec.md | Should | Clarifications section appears after running command |
| FR-12 | `/speckit:analyze` outputs consistency report | Should | Report lists coverage gaps and conflicts |
| FR-13 | `/speckit:checklist` generates quality checklist | Could | Checklist based on constitution and spec criteria |
| FR-14 | Help command provides usage documentation | Must | `/speckit:help` lists all commands with descriptions |

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Plugin loads without errors | Load success rate | 100% on Claude Code restart |
| NFR-2 | Stop-handler responds promptly | Response time | < 2 seconds per decision |
| NFR-3 | State file integrity | Data corruption rate | 0% after 100 task cycles |
| NFR-4 | No external dependencies | Dependency count | 0 (pure markdown/bash) |
| NFR-5 | Consistent file structure | Schema compliance | 100% files match templates |
| NFR-6 | Agent prompt quality | Token efficiency | Prompts < 5000 tokens each |
| NFR-7 | Documentation completeness | Command coverage | 100% commands documented in help |

## Glossary

- **Constitution**: Project-level governing document defining principles, standards, and constraints that apply to all features
- **Feature ID**: Auto-incrementing numeric prefix (001, 002) used to identify and order features
- **Specify Phase**: Definition of WHAT and WHY without HOW - user stories, requirements, scope
- **Plan Phase**: Technical implementation design including architecture, tech stack, and file structure
- **Stop-Handler**: Bash script invoked by Claude Code stop hook to manage task loop state machine
- **TASK_COMPLETE**: Magic string that spec-executor outputs to signal successful task completion
- **Quality Checkpoint**: `[VERIFY]` task that runs quality commands (lint, test, type-check)
- **Traceability**: Links from tasks back to requirements (Spec: FR-X) and design (Plan: Component)
- **Fresh Context**: Each task executes in isolation; state preserved in files, not conversation

## Out of Scope

- Full spec-kit CLI integration (plugin operates independently)
- Python/uv dependencies (pure markdown/bash only)
- External database or API (file-based state only)
- Backward compatibility with ralph-specum specs (no migration tool)
- Multiple parallel tech stack planning (single stack per feature)
- Constitution versioning/history (manual git tracking only)
- GUI or web interface (CLI-only via Claude Code)
- Multi-user collaboration features (single-user workflow)

## Dependencies

- Claude Code with plugin support and stop hook capability
- Git for branch management and commits
- Bash shell for stop-handler script execution
- Existing ralph-specum patterns as reference implementation
- No npm, pip, or external package dependencies

## Success Criteria

- [ ] All 14 slash commands load and execute in Claude Code
- [ ] A complete feature can be specified, planned, tasked, and implemented end-to-end
- [ ] Constitution created once persists and is referenced by subsequent features
- [ ] Stop-handler correctly advances through 10+ tasks without manual intervention
- [ ] All spec files (constitution, spec, plan, research, tasks, progress) are committed to git
- [ ] Quality checkpoints execute and block on failures
- [ ] Plugin is usable by developer unfamiliar with internals (self-documenting)

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Stop-handler state corruption | High | Validate JSON before write; backup state file |
| TASK_COMPLETE not detected | Medium | Clear output format in spec-executor; retry logic |
| Constitution drift from practice | Medium | Reference constitution in every agent prompt |
| Spec creep into implementation details | Medium | Template validation; clarifier agent review |
| Branch conflicts with existing work | Low | Start command checks for clean working directory |
| Agent prompt token limits | Medium | Keep prompts focused; use templates for structure |

## Open Questions (Resolved by Research)

1. **Constitution Initialization**: Start command guides user to run `/speckit:constitution` first if none exists (guidance approach, not enforcement)
2. **Feature ID Format**: Simple numeric prefixes (001, 002) without custom prefixes
3. **Quick Mode**: Not in initial scope; can be added later
4. **Branch Naming**: Use `<id>-<name>` pattern directly (e.g., `001-create-taskify`)
5. **Backward Compatibility**: Out of scope for initial release

## Review Checklist

- [x] All user stories have testable acceptance criteria
- [x] Requirements use measurable language (no "fast", "easy", "simple")
- [x] Each requirement has clear priority (Must/Should/Could)
- [x] Out of scope explicitly prevents scope creep
- [x] Glossary defines domain-specific terms
- [x] Success criteria are measurable
- [x] Risks identified with mitigation strategies
