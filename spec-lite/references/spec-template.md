# Engineering Spec Template

Use this template when drafting a new spec.

```md
# Change Name

## Goal
One sentence that states the user or system problem this change solves.

## Non-goals
State clearly what this change does not cover.

## Impact Scope
List affected modules, APIs, tables, configs, jobs, and tests.

## Data Flow
Describe where input comes from, which layers process it, and where output goes.

## Interface And Schema Changes
List API, SQL, JSON schema, protobuf, event, file format, or storage contract changes.

## Invariants
List architecture constraints, business constraints, and compatibility constraints that must remain true.

## Implementation Plan
1. Modify interfaces or schema.
2. Modify core logic.
3. Add or update tests.
4. Run verification commands.

## Verification
List the commands that must pass.

## Manual Checks
List data flow, compatibility, and security boundaries that require human judgment.
```

## Section Notes

### Goal

Keep it short and specific. Describe the outcome, not the coding task.

### Non-goals

Use explicit exclusions to prevent scope drift.

### Impact Scope

Name real surfaces whenever possible:

- packages or modules
- routes or RPC methods
- tables or migrations
- queue topics or events
- configs
- test suites

### Data Flow

Describe the path in order. If there are multiple paths, split them by scenario.

### Interface And Schema Changes

Always include this section. Write `None` when unchanged.

### Invariants

Prefer rules that are testable or at least easy to review.

### Verification

Only list commands that belong in the target repository or environment.

### Manual Checks

Focus on correctness boundaries that are hard to automate.

## Review Checklist

- the title is concrete
- every required section exists
- no placeholder text remains
- non-goals are strong enough to block adjacent work
- invariants are specific enough to catch regressions
- verification commands are realistic
