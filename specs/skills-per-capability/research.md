---
spec: skills-per-capability
phase: research
created: 2026-01-13
generated: auto
---

# Research: skills-per-capability

## Executive Summary

Refactoring from single SKILL.md to per-capability skill files is straightforward. Current structure has one 39-line file covering 11 commands. Splitting by capability improves discoverability and allows targeted "When to Use" triggers.

## Codebase Analysis

### Existing Patterns

- **Current skill file**: `plugins/ralph-specum/skills/spec-workflow/SKILL.md`
  - YAML frontmatter with name, description
  - "When to Use" section with trigger scenarios
  - Commands section grouped by function

- **Command files**: Each command is already separate in `plugins/ralph-specum/commands/`
  - 11 command files: start.md, new.md, research.md, requirements.md, design.md, tasks.md, implement.md, status.md, switch.md, cancel.md, help.md

- **SKILL.md structure pattern**:
  ```yaml
  ---
  name: <skill-name>
  description: <one-line description>
  ---
  # <Skill Name>
  ## When to Use
  ## Commands
  ```

### Dependencies

- No external dependencies
- Commands reference each other via `/ralph-specum:<command>` syntax
- Skills are loaded by the plugin system from `skills/*/SKILL.md`

### Constraints

- Each skill directory must have a SKILL.md file
- Plugin system expects skills in `skills/<name>/SKILL.md` format
- Command references must remain consistent across skill files

## Feasibility Assessment

| Aspect | Assessment | Notes |
|--------|------------|-------|
| Technical Viability | High | Simple file restructure, no code changes |
| Effort Estimate | S | 8 files to create, mostly content reorganization |
| Risk Level | Low | Backward compatible, can test incrementally |

## Recommendations

1. Create 8 skill directories matching capability groups
2. Each SKILL.md gets focused "When to Use" with specific trigger phrases
3. Keep command syntax identical to preserve user muscle memory
4. Delete original spec-workflow/SKILL.md after verification

## Open Questions

- Should spec-workflow directory be removed or kept empty?
- Order of commands within each skill file (alphabetical vs logical flow)?

## Sources

- `/home/tzachb/Projects/ralph-specum/plugins/ralph-specum/skills/spec-workflow/SKILL.md`
- `/home/tzachb/Projects/ralph-specum/plugins/ralph-specum/commands/*.md`
