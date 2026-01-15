---
description: Run or re-run research phase for current spec
argument-hint: [spec-name]
allowed-tools: [Read, Write, Task, Bash, AskUserQuestion]
---

# Research Phase

You are running the research phase for a specification.

<mandatory>
**YOU ARE A COORDINATOR, NOT A RESEARCHER.**

You MUST delegate ALL research work to the `research-analyst` subagent.
Do NOT perform web searches, codebase analysis, or write research.md yourself.
</mandatory>

## Determine Active Spec

1. If `$ARGUMENTS` contains a spec name, use that
2. Otherwise, read `./specs/.current-spec` to get active spec
3. If no active spec, error: "No active spec. Run /ralph-specum:new <name> first."

## Validate

1. Check `./specs/$spec/` directory exists
2. Read `.ralph-state.json` if it exists

## Interview

<mandatory>
**Skip interview if --quick flag detected in $ARGUMENTS.**

If NOT quick mode, conduct interview using AskUserQuestion before delegating to subagent.
</mandatory>

### Quick Mode Check

Check if `--quick` appears anywhere in `$ARGUMENTS`. If present, skip directly to "Execute Research".

### Research Interview

Use AskUserQuestion to gather technical context:

```
AskUserQuestion:
  questions:
    - question: "What technical approach do you prefer for this feature?"
      options:
        - "Follow existing patterns in codebase (Recommended)"
        - "Introduce new patterns/frameworks"
        - "Hybrid - keep existing where possible"
        - "Other"
    - question: "Are there any known constraints or limitations?"
      options:
        - "No known constraints"
        - "Must work with existing API"
        - "Performance critical"
        - "Other"
```

### Adaptive Depth

If user selects "Other" for any question:
1. Ask a follow-up question to clarify using AskUserQuestion
2. Continue until clarity reached or 5 follow-up rounds complete
3. Each follow-up should probe deeper into the "Other" response

### Interview Context Format

After interview, format responses as:

```
Interview Context:
- Technical approach: [Answer]
- Known constraints: [Answer]
- Follow-up details: [Any additional clarifications]
```

Store this context to include in the Task delegation prompt.

## Execute Research

<mandatory>
Use the Task tool with `subagent_type: research-analyst` to run the research phase.
</mandatory>

Invoke research-analyst agent with prompt:

```
You are researching for spec: $spec
Spec path: ./specs/$spec/

Goal from user conversation or existing progress file.

[If interview was conducted, include:]
Interview Context:
$interview_context

Your task:
1. Search web for best practices, prior art, and patterns
2. Explore the codebase for existing related implementations
3. Scan ./specs/ for existing specs that relate to this goal
4. Document related specs in the "Related Specs" section
5. Assess technical feasibility
6. Create ./specs/$spec/research.md with your findings
7. Include interview responses in a "User Context" section of research.md

Use the research.md template structure:
- Executive Summary
- User Context (interview responses and user-provided constraints)
- External Research (best practices, prior art, pitfalls)
- Codebase Analysis (patterns, dependencies, constraints)
- Related Specs (table with relevance, relationship, mayNeedUpdate)
- Feasibility Assessment (table)
- Recommendations for Requirements
- Open Questions
- Sources

Remember: Never guess, always verify. Cite all sources.
Store user interview responses in the "User Context" section of research.md.
```

## Update State

After research completes:

1. Parse "Related Specs" table from research.md
2. Update `.ralph-state.json`:
   ```json
   {
     "phase": "research",
     "awaitingApproval": true,
     "relatedSpecs": [
       {"name": "...", "relevance": "high", "reason": "...", "mayNeedUpdate": true}
     ]
   }
   ```
3. Update `.progress.md` with research completion

## Output

```
Research phase complete for '$spec'.

Output: ./specs/$spec/research.md

Related specs found:
  - <name> (<RELEVANCE>) - may need update
  - <name> (<RELEVANCE>)

Next: Review research.md, then run /ralph-specum:requirements
```

## Stop

<mandatory>
**STOP HERE. DO NOT PROCEED TO REQUIREMENTS.**

(This does not apply in `--quick` mode, which auto-generates all artifacts without stopping.)

After displaying the output above, you MUST:
1. End your response immediately
2. Wait for the user to review research.md
3. Only proceed to requirements when user explicitly runs `/ralph-specum:requirements`

DO NOT automatically invoke the product-manager or run the requirements phase.
The user needs time to review research findings before proceeding.
</mandatory>
