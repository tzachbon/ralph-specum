---
spec: skills-per-capability
phase: tasks
total_tasks: 12
created: 2026-01-13
generated: auto
---

# Tasks: skills-per-capability

## Phase 1: Make It Work (POC)

Focus: Create all skill files. Verify they load correctly.

- [x] 1.1 Create start-spec skill
  - **Do**: Create directory and SKILL.md with start, new commands
  - **Files**: `plugins/ralph-specum/skills/start-spec/SKILL.md`
  - **Done when**: File exists with proper frontmatter and commands
  - **Verify**: `cat plugins/ralph-specum/skills/start-spec/SKILL.md`
  - **Commit**: `feat(skills): add start-spec skill`
  - _Requirements: FR-5_
  - _Design: start-spec/SKILL.md_

- [x] 1.2 Create research-phase skill
  - **Do**: Create directory and SKILL.md with research command
  - **Files**: `plugins/ralph-specum/skills/research-phase/SKILL.md`
  - **Done when**: File exists with focused triggers
  - **Verify**: `cat plugins/ralph-specum/skills/research-phase/SKILL.md`
  - **Commit**: `feat(skills): add research-phase skill`
  - _Requirements: FR-6_
  - _Design: research-phase/SKILL.md_

- [x] 1.3 Create requirements-phase skill
  - **Do**: Create directory and SKILL.md with requirements command
  - **Files**: `plugins/ralph-specum/skills/requirements-phase/SKILL.md`
  - **Done when**: File exists with requirements triggers
  - **Verify**: `cat plugins/ralph-specum/skills/requirements-phase/SKILL.md`
  - **Commit**: `feat(skills): add requirements-phase skill`
  - _Requirements: FR-7_
  - _Design: requirements-phase/SKILL.md_

- [x] 1.4 Create design-phase skill
  - **Do**: Create directory and SKILL.md with design command
  - **Files**: `plugins/ralph-specum/skills/design-phase/SKILL.md`
  - **Done when**: File exists with architecture triggers
  - **Verify**: `cat plugins/ralph-specum/skills/design-phase/SKILL.md`
  - **Commit**: `feat(skills): add design-phase skill`
  - _Requirements: FR-8_
  - _Design: design-phase/SKILL.md_

- [x] 1.5 Create tasks-phase skill
  - **Do**: Create directory and SKILL.md with tasks command
  - **Files**: `plugins/ralph-specum/skills/tasks-phase/SKILL.md`
  - **Done when**: File exists with planning triggers
  - **Verify**: `cat plugins/ralph-specum/skills/tasks-phase/SKILL.md`
  - **Commit**: `feat(skills): add tasks-phase skill`
  - _Requirements: FR-9_
  - _Design: tasks-phase/SKILL.md_

- [x] 1.6 Create execution skill
  - **Do**: Create directory and SKILL.md with implement command
  - **Files**: `plugins/ralph-specum/skills/execution/SKILL.md`
  - **Done when**: File exists with execution triggers
  - **Verify**: `cat plugins/ralph-specum/skills/execution/SKILL.md`
  - **Commit**: `feat(skills): add execution skill`
  - _Requirements: FR-10_
  - _Design: execution/SKILL.md_

- [x] 1.7 Create management skill
  - **Do**: Create directory and SKILL.md with status, switch, cancel
  - **Files**: `plugins/ralph-specum/skills/management/SKILL.md`
  - **Done when**: File exists with management triggers
  - **Verify**: `cat plugins/ralph-specum/skills/management/SKILL.md`
  - **Commit**: `feat(skills): add management skill`
  - _Requirements: FR-11_
  - _Design: management/SKILL.md_

- [x] 1.8 Create help skill
  - **Do**: Create directory and SKILL.md with help command
  - **Files**: `plugins/ralph-specum/skills/help/SKILL.md`
  - **Done when**: File exists with help triggers
  - **Verify**: `cat plugins/ralph-specum/skills/help/SKILL.md`
  - **Commit**: `feat(skills): add help skill`
  - _Requirements: FR-12_
  - _Design: help/SKILL.md_

- [x] 1.9 POC Checkpoint
  - **Do**: Verify all 8 skill files exist and have correct structure
  - **Done when**: `ls plugins/ralph-specum/skills/*/SKILL.md` shows 9 files (8 new + 1 old)
  - **Verify**: `ls -la plugins/ralph-specum/skills/*/SKILL.md | wc -l`
  - **Commit**: `feat(skills): complete per-capability skills POC`

## Phase 2: Refactoring

- [x] 2.1 Remove original spec-workflow skill
  - **Do**: Delete the original monolithic SKILL.md
  - **Files**: `plugins/ralph-specum/skills/spec-workflow/SKILL.md`
  - **Done when**: File and directory removed
  - **Verify**: `ls plugins/ralph-specum/skills/` shows 8 directories, no spec-workflow
  - **Commit**: `refactor(skills): remove monolithic spec-workflow skill`
  - _Requirements: FR-13_
  - _Design: File Structure_

## Phase 3: Testing

- [x] 3.1 Verify skill loading
  - **Do**: Test that skills load properly by checking each file is valid markdown with frontmatter
  - **Files**: All 8 SKILL.md files
  - **Done when**: All files parse correctly
  - **Verify**: `head -5 plugins/ralph-specum/skills/*/SKILL.md` shows valid frontmatter
  - **Commit**: `test(skills): verify skill file structure`

## Phase 4: Quality Gates

- [x] 4.1 Final verification
  - **Do**: Confirm 8 skill directories, each with SKILL.md, no orphans
  - **Verify**: `find plugins/ralph-specum/skills -name "SKILL.md" | wc -l` equals 8
  - **Done when**: Count matches expected
  - **Commit**: No commit needed if no changes

## Notes

- **POC shortcuts taken**: Created files without testing plugin system integration
- **Production TODOs**: Test with actual plugin loading if needed
