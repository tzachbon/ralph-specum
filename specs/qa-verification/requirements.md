---
spec: qa-verification
phase: requirements
created: 2026-01-13
---

# Requirements: QA Verification via [VERIFY] Tasks

## Goal

Add verification capability through [VERIFY] tagged tasks that are delegated to a qa-engineer agent. Verification is integrated into the task flow rather than a separate phase.

## User Stories

### US-1: Integrated Verification Tasks

**As a** developer using ralph-specum
**I want to** have verification tasks integrated into my task list
**So that** quality checks happen at natural checkpoints throughout development

**Acceptance Criteria:**
- AC-1.1: Tasks with [VERIFY] tag are recognized as verification tasks
- AC-1.2: [VERIFY] tasks are placed at quality checkpoints (every 2-3 tasks) and at spec end
- AC-1.3: Task-planner generates [VERIFY] tasks using commands discovered during research
- AC-1.4: [VERIFY] tasks follow standard task format (Do/Verify/Done when/Commit)

### US-2: Verification Task Delegation

**As a** developer
**I want to** have [VERIFY] tasks handled by a specialized agent
**So that** verification follows consistent, thorough methodology

**Acceptance Criteria:**
- AC-2.1: spec-executor detects [VERIFY] tag in task description
- AC-2.2: spec-executor delegates [VERIFY] tasks to qa-engineer agent via Task tool
- AC-2.3: qa-engineer runs specified verification commands
- AC-2.4: qa-engineer outputs VERIFICATION_PASS or VERIFICATION_FAIL
- AC-2.5: On VERIFICATION_FAIL, task remains unchecked for retry

### US-3: Quality Command Discovery

**As a** developer
**I want to** have quality commands auto-discovered from my project
**So that** verification uses actual commands, not assumptions

**Acceptance Criteria:**
- AC-3.1: Research phase scans package.json scripts for lint/typecheck/test/build commands
- AC-3.2: Research phase checks Makefile for relevant targets if present
- AC-3.3: Research phase scans CI config files (.github/workflows/*.yml) for commands
- AC-3.4: Discovered commands are documented in research.md
- AC-3.5: Task-planner uses discovered commands when generating [VERIFY] tasks

### US-4: Final Verification Sequence

**As a** developer
**I want to** have a consistent final verification sequence
**So that** specs complete with thorough validation

**Acceptance Criteria:**
- AC-4.1: V4 task runs full local CI (lint, types, tests, build) - LOCAL FIRST, always
- AC-4.2: V5 task verifies CI pipeline passes after push
- AC-4.3: V6 task checks each AC from requirements.md against implementation
- AC-4.4: Order is enforced: local CI, then remote CI, then AC checklist

### US-5: AC Traceability

**As a** developer
**I want to** see which acceptance criteria are verified
**So that** I know the implementation matches requirements

**Acceptance Criteria:**
- AC-5.1: qa-engineer reads requirements.md for AC checklist verification
- AC-5.2: Each AC-* entry is checked against implementation
- AC-5.3: AC verification results are recorded in .progress.md Learnings
- AC-5.4: Any unverified AC causes VERIFICATION_FAIL

### US-6: Verification Retry

**As a** developer
**I want to** be able to fix issues and retry verification
**So that** I can resolve failures without restarting

**Acceptance Criteria:**
- AC-6.1: On VERIFICATION_FAIL, task stays unchecked in tasks.md
- AC-6.2: spec-executor can retry the same [VERIFY] task after fixes
- AC-6.3: Failure details are logged in .progress.md for context

## Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|-------------|----------|---------------------|
| FR-1 | Create qa-engineer.md agent file | P0 | Agent exists with correct frontmatter (tools: Read, Bash, Glob, Grep) |
| FR-2 | Update spec-executor.md to detect [VERIFY] tasks | P0 | [VERIFY] tag detection works, delegates to qa-engineer |
| FR-3 | Update task-planner.md to generate [VERIFY] tasks | P0 | [VERIFY] tasks generated at checkpoints with correct format |
| FR-4 | Update research-analyst.md to discover quality commands | P0 | Scans package.json, Makefile, CI configs |
| FR-5 | qa-engineer runs verification commands | P0 | Executes commands, parses output for pass/fail |
| FR-6 | qa-engineer verifies AC checklist | P0 | Reads requirements.md, checks each AC-* |
| FR-7 | qa-engineer outputs completion signal | P0 | VERIFICATION_PASS or VERIFICATION_FAIL output |
| FR-8 | Verification results logged in .progress.md | P1 | Learnings updated with verification outcomes |

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Verification task execution time | Per task | Under 2 minutes for typical quality checks |
| NFR-2 | Error handling | Graceful degradation | Missing commands reported, task continues |
| NFR-3 | Backward compatibility | Existing specs | Specs without [VERIFY] tasks still work |

## Glossary

- **[VERIFY] task**: Task with [VERIFY] tag in description, delegated to qa-engineer
- **Quality Checkpoint**: Existing task-planner concept, extended with [VERIFY] tag
- **qa-engineer agent**: Sub-agent that runs verification checks
- **VERIFICATION_PASS**: Signal output when all checks pass
- **VERIFICATION_FAIL**: Signal output when any check fails
- **V1-V6**: Verification task numbering (V4/V5/V6 are final sequence)

## Out of Scope

- Separate verification phase (replaced by integrated [VERIFY] tasks)
- /ralph-specum:verify command (not needed with integrated approach)
- verification.md report file (results go in .progress.md)
- Schema phase enum update (no new phase)
- Stop-handler phase logic changes (uses existing task loop)
- Performance benchmarking or load testing
- Security vulnerability scanning
- Visual regression testing
- Cross-browser compatibility testing
- Test generation (tests must already exist)

## Dependencies

- Existing spec-executor task loop mechanism
- Task tool for subagent delegation
- .progress.md for result logging
- requirements.md for AC extraction
- Project quality commands must exist for verification to run them

## Success Criteria

- [VERIFY] tasks appear at quality checkpoints in generated tasks.md
- spec-executor correctly delegates [VERIFY] tasks to qa-engineer
- Quality commands discovered during research used in [VERIFY] tasks
- Final verification sequence (V4/V5/V6) runs local-first
- AC checklist verification traces back to requirements.md
- VERIFICATION_FAIL keeps task unchecked for retry
- No regression in existing workflow

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| Projects without quality commands | Medium | Skip checks, report as SKIP in learnings |
| AC verification requires interpretation | High | qa-agent uses best-effort, flags uncertain results |
| Long-running tests slow [VERIFY] tasks | Medium | Document timeout expectations |
| Task format parsing edge cases | Low | Well-defined [VERIFY] tag format |
