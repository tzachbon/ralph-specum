---
spec: qa-verification
phase: research
created: 2026-01-13
---

# Research: qa-verification

## Executive Summary

Adding verification as integrated [VERIFY] tasks within the existing task flow is technically feasible and simpler than a separate phase. Research phase discovers actual quality commands from project config. Spec-executor delegates [VERIFY] tasks to a qa-engineer agent. No new phase enum or stop-handler phase logic needed.

## External Research

### Best Practices

- **Release testing as final checkpoint**: QA verification before deployment validates all features meet requirements, are bug-free, and deliver consistent UX ([BrowserStack Guide](https://www.browserstack.com/guide/qa-best-practices))
- **Multi-dimensional validation**: Effective QA verification covers functional correctness, code quality, and test coverage as distinct criteria ([BrowserStack Guide](https://www.browserstack.com/guide/qa-best-practices))
- **Pass/fail criteria must be explicit**: Performance thresholds, security benchmarks, and compatibility requirements need measurable targets ([BrowserStack Guide](https://www.browserstack.com/guide/qa-best-practices))
- **Human oversight essential**: AI testing agents work best with "human in the loop" validation at critical decision points ([Testomat AI Agent Testing](https://testomat.io/blog/ai-agent-testing/))

### Prior Art

- **Agentic AI testing pattern**: Goal-oriented agents that interpret requirements, generate verification scenarios, and adapt to changes ([Testomat](https://testomat.io/blog/ai-agent-testing/))
- **Hybrid evaluation**: Netflix combines ReAct-based reasoning tests with traditional unit tests for comprehensive validation ([AI Agent Testing](https://testomat.io/blog/ai-agent-testing/))
- **Inline quality gates**: Modern CI/CD embeds verification steps within pipelines rather than separate phases

### Pitfalls to Avoid

- **Vague pass/fail criteria**: "Works correctly" is not testable. Must specify exact commands, expected outputs, and thresholds
- **Over-automation without oversight**: AI agents can hallucinate or misclassify results. Need clear guardrails
- **Missing requirements traceability**: Verification must map back to original requirements and acceptance criteria
- **Generic commands**: Assuming "npm test" or "pnpm lint" exists. Must discover actual project commands

## Codebase Analysis

### Existing Patterns

**Agent Structure** (`/home/tzachb/Projects/ralph-specum-qa-verification/plugins/ralph-specum/agents/*.md`):
- Frontmatter: name, description, model, tools
- Core sections: When Invoked, mandatory constraints, output format
- All agents append learnings to .progress.md
- Pattern: Read context, execute phase, update progress

**Task-Planner Quality Checkpoints** (`task-planner.md`):
- Already inserts "Quality Checkpoint" tasks every 2-3 tasks
- Format: `- [ ] X.Y Quality Checkpoint` with Do/Verify/Done when
- Quality commands listed inline: `pnpm check-types`, `pnpm lint`, `pnpm test`
- Pattern can be extended to [VERIFY] tagged tasks

**Spec-Executor Delegation** (`spec-executor.md`):
- Has Task tool available for subagent delegation
- Executes tasks from tasks.md sequentially
- Outputs TASK_COMPLETE signal for stop-handler

**Completion Signal**:
- `spec-executor` outputs `TASK_COMPLETE`
- `stop-handler.sh` verifies signal in transcript
- Missing signal triggers retry

### Quality Command Discovery Pattern

Projects store quality commands in various locations:

| Source | What to Extract |
|--------|-----------------|
| `package.json` scripts | `lint`, `typecheck`, `type-check`, `check-types`, `test`, `build` |
| `Makefile` | `lint`, `test`, `check` targets |
| `.github/workflows/*.yml` | CI step commands |
| `tsconfig.json` | Presence indicates TypeScript project |
| `eslint.config.*` or `.eslintrc*` | Presence indicates ESLint available |

Discovery priority:
1. package.json scripts (most reliable)
2. Makefile targets
3. CI workflow commands
4. Infer from config file presence

### Dependencies

**Existing deps to leverage**:
- Task tool for subagent delegation (spec-executor already has it)
- `.ralph-state.json` for phase/state management
- `.progress.md` for context sharing
- requirements.md for acceptance criteria reference
- tasks.md for implementation reference

**Tools available**:
- Read, Write, Edit for file operations
- Bash for running verification commands
- Glob, Grep for codebase analysis

### Constraints

1. **Task format is established**: tasks.md has specific structure with Do/Files/Done when/Verify/Commit
2. **spec-executor owns task execution**: Any new task type must work within spec-executor flow
3. **Stop-handler expects TASK_COMPLETE**: Verification tasks must output same signal pattern
4. **Quality checkpoint pattern exists**: Can extend rather than replace

## Related Specs

| Spec | Relevance | Reason | May Need Update |
|------|-----------|--------|-----------------|
| plan-source-feature | Medium | Quick mode flow. May want to include [VERIFY] tasks in quick mode | Possibly |
| add-skills-doc | Low | Skills docs may need update to document [VERIFY] task format | Yes |

## Feasibility Assessment

| Aspect | Assessment | Notes |
|--------|------------|-------|
| Technical Viability | High | Extends existing patterns, no new phase logic needed |
| Effort Estimate | M | qa-engineer agent + task-planner updates + spec-executor delegation |
| Risk Level | Low | Non-breaking, integrates with existing task flow |

## Integration Points

### Required Changes

1. **New agent**: `agents/qa-engineer.md`
   - Tools: Read, Bash, Glob, Grep
   - Receives [VERIFY] task details from spec-executor
   - Runs verification checks
   - Outputs VERIFICATION_PASS or VERIFICATION_FAIL

2. **Update task-planner.md**:
   - Add [VERIFY] task format documentation
   - Place [VERIFY] tasks at quality checkpoints
   - Final [VERIFY] tasks for full CI, AC checklist

3. **Update spec-executor.md**:
   - Detect [VERIFY] tagged tasks
   - Delegate to qa-engineer via Task tool
   - On VERIFICATION_FAIL, keep task unchecked, allow retry

4. **Update research-analyst.md**:
   - Add quality command discovery section
   - Store findings in research.md for task-planner to use

### NOT Required

- No new `/ralph-specum:verify` command (verification is inline)
- No schema phase enum update (no "verification" phase)
- No stop-handler.sh phase logic changes
- Simpler overall architecture

## Verification Task Format

[VERIFY] tasks follow standard task format with specific pattern:

```markdown
- [ ] V1 [VERIFY] Quality check: pnpm lint && pnpm typecheck
  - **Do**: Run quality commands and verify all pass
  - **Verify**: All commands exit 0
  - **Done when**: No lint errors, no type errors
  - **Commit**: `chore(scope): pass quality checkpoint` (if fixes needed)

- [ ] V4 [VERIFY] Full local CI: pnpm lint && pnpm typecheck && pnpm test && pnpm build
  - **Do**: Run complete local CI suite
  - **Verify**: All commands pass
  - **Done when**: Build succeeds, all tests pass
  - **Commit**: `chore(scope): verify local CI` (if fixes needed)

- [ ] V5 [VERIFY] CI pipeline passes
  - **Do**: Push changes, verify GitHub Actions/CI passes
  - **Verify**: `gh pr checks` shows all green
  - **Done when**: CI pipeline passes

- [ ] V6 [VERIFY] AC checklist
  - **Do**: Read requirements.md, verify each AC-* is satisfied
  - **Verify**: Manual review against implementation
  - **Done when**: All acceptance criteria confirmed met
```

## Verification Execution Order

<mandatory>
Final verification tasks MUST follow this order:
1. **V4: Full local CI** - ALWAYS run local checks first (lint, types, tests, build)
2. **V5: CI pipeline** - Only after local passes, push and verify remote CI
3. **V6: AC checklist** - Final requirements traceability check
</mandatory>

Rationale: Local-first catches issues before push, saves CI resources, faster feedback loop.

## Recommendations for Requirements

1. **Integrate verification as [VERIFY] tasks**: No separate phase, simpler architecture
2. **Research phase discovers commands**: Actual project commands, not generic assumptions
3. **spec-executor delegates to qa-engineer**: Clean separation of concerns
4. **Keep existing Quality Checkpoint pattern**: Extend with [VERIFY] tag for explicit verification
5. **Strict local-first order**: Local CI before remote CI, always

## Open Questions

1. **Should quick mode include [VERIFY] tasks?** Recommend yes for V4/V5/V6 at minimum
2. **What happens on VERIFICATION_FAIL?** Task stays unchecked, retry available
3. **Should verification report be generated?** Recommend minimal, just in .progress.md learnings

## Sources

- [BrowserStack QA Best Practices](https://www.browserstack.com/guide/qa-best-practices)
- [Testomat AI Agent Testing](https://testomat.io/blog/ai-agent-testing/)
- [Global App Testing Agile QA](https://www.globalapptesting.com/blog/qa-process)
- `/home/tzachb/Projects/ralph-specum-qa-verification/plugins/ralph-specum/agents/task-planner.md`
- `/home/tzachb/Projects/ralph-specum-qa-verification/plugins/ralph-specum/agents/spec-executor.md`
- `/home/tzachb/Projects/ralph-specum-qa-verification/plugins/ralph-specum/agents/research-analyst.md`
- GitHub Issue #14: https://github.com/tzachbon/smart-ralph/issues/14
