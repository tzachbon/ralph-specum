---
description: Generate technical design from requirements
argument-hint: [spec-name]
allowed-tools: [Read, Write, Task, Bash, AskUserQuestion]
---

# Design Phase

Generate technical design for a specification. Running this command implicitly approves the requirements phase.

<mandatory>
**YOU ARE A COORDINATOR, NOT AN ARCHITECT.**
Delegate ALL design work to the `architect-reviewer` subagent via Task tool.
</mandatory>

## Determine Active Spec

1. If `$ARGUMENTS` contains a spec name, use that
2. Otherwise, read `./specs/.current-spec` to get active spec
3. If no active spec, error: "No active spec. Run /ralph-specum:new <name> first."

## Validate

1. Check `./specs/$spec/` directory exists
2. Check `./specs/$spec/requirements.md` exists. If not, error: "Requirements not found. Run /ralph-specum:requirements first."
3. Read `.ralph-state.json` and clear approval flag: `awaitingApproval: false`

## Gather Context

Read: `./specs/$spec/requirements.md`, `./specs/$spec/research.md` (if exists), `./specs/$spec/.progress.md`

## Interview

<skill-reference>
**Apply skill**: `skills/interview-framework/SKILL.md`
Use interview framework for single-question loop, parameter chain, and completion signals.
</skill-reference>

**Skip if --quick flag in $ARGUMENTS.**

### Design Interview Question Pool

| # | Question | Required | Key | Options |
|---|----------|----------|-----|---------|
| 1 | What architecture style fits this feature for {goal}? | Required | `architectureStyle` | Extend existing / Create isolated module / Major refactor / Other |
| 2 | Any technology constraints for {goal}? | Required | `techConstraints` | No constraints / Must use specific library / Must avoid dependencies / Other |
| 3 | How should this integrate with existing systems? | Required | `integrationApproach` | Use existing APIs / Create new layer / Minimal integration / Other |
| 4 | Any other design context? (or 'done') | Optional | `additionalDesignContext` | No, proceed / Yes, more details / Other |

Store responses in `.progress.md` under `### Design Interview (from design.md)`

## Execute Design

Use Task tool with `subagent_type: architect-reviewer`:

```text
You are creating technical design for spec: $spec
Spec path: ./specs/$spec/

Context:
- Requirements: [requirements.md content]
- Research: [research.md if exists]
- Interview: [interview responses]

Create design.md with: architecture diagram, data flow, decisions table, file structure, interfaces, error handling, test strategy.
```

## Review Loop

**Skip if --quick flag.** Ask user to review generated design. If changes needed, invoke architect-reviewer again with feedback and repeat until approved.

## Update State

Update `.ralph-state.json`: `{ "phase": "design", "awaitingApproval": true }`

## Commit Spec (if enabled)

If `commitSpec` is true in state: stage, commit (`spec($spec): add technical design`), push.

## Output

```text
Design phase complete for '$spec'.
Output: ./specs/$spec/design.md
Next: Review design.md, then run /ralph-specum:tasks
```
