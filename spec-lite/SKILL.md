---
name: spec-lite
description: Draft, refine, and review concise engineering change specs from rough notes, tickets, AGENTS.md guidance, or partial design docs. Use when you need to turn implementation intent into a stable spec contract with clear goal, scope, invariants, implementation steps, verification commands, and manual checks.
---

# Spec Lite

Write short, implementation-ready engineering specs that freeze one chosen change into a clear contract. Keep the document easy to scan, explicit about scope, and strict about what must remain true.

## Workflow

1. Extract the concrete change.
2. Separate product intent, technical contract, and verification.
3. Remove project-local details unless the task explicitly requires them.
4. Fill every required section with concrete content or `None`.
5. End with runnable verification commands and manual checks.

## Define The Change First

State one change per spec. If the input mixes multiple efforts, split them or pick the primary change and mark the rest as non-goals.

Prefer concrete names:

- route names
- table names
- config keys
- structs, interfaces, jobs, topics, or commands

Avoid vague titles such as `Improve backend logic` or `Support new workflow`. Name the actual behavior being added, removed, or constrained.

## Keep The Required Structure

Use this section order unless the user explicitly asks for a different format:

1. `Status`
2. `Context`
3. `Goal`
4. `Non-goals`
5. `Impact Scope`
6. `Data Flow`
7. `Interface And Schema Changes`
8. `Invariants`
9. `Implementation Plan`
10. `Verification`
11. `Manual Checks`

Read [references/spec-template.md](./references/spec-template.md) when you need the exact template and section guidance.
Read [references/bad-request-to-spec-example.md](./references/bad-request-to-spec-example.md) when you need a full example that shows how to turn a vague request into a good spec using this skill's workflow.

## Write Each Section With Discipline

### Status

Mark the current state of the change. Use one concise value such as `Draft`, `Ready for implementation`, `In progress`, `Blocked`, `Ready for review`, or `Done`.

Include the blocker or review owner only when it changes the next action.

### Context

Explain the background that makes this change necessary. Capture the triggering request, observed problem, product decision, operational issue, or architectural constraint.

Keep it factual and brief. Do not duplicate the goal or implementation plan.

### Goal

Write one sentence describing the outcome for users or the system. Describe the problem solved, not the implementation activity.

### Non-goals

Use this section to block scope creep. Be explicit about adjacent work that is not part of the change.

### Impact Scope

List the touched surfaces. Mention modules, APIs, tables, configs, pipelines, jobs, tests, dashboards, or operational docs if they are affected.

### Data Flow

Describe the path in order:

1. input source
2. protocol or interface boundary
3. application or domain processing
4. persistence, queue, storage, or external service
5. output contract

Split by scenario when there is more than one meaningful flow.

### Interface And Schema Changes

This section is mandatory. Write `None` if there are no contract changes.

Cover changes such as:

- HTTP or RPC request and response fields
- database DDL or storage layout
- event payloads
- config keys
- file formats
- generated client or schema artifacts

### Invariants

Capture the rules that must remain true during and after the change. This section prevents regressions better than broad summaries.

Examples:

- authorization scope cannot widen
- compatibility endpoints cannot break
- ownership fields remain immutable after creation
- production schema is not auto-migrated at runtime
- query responses stay read-only and do not embed rendering state

### Implementation Plan

Keep it ordered and executable. Prefer this dependency order:

1. contract or schema
2. core logic
3. tests
4. verification

### Verification

Only list commands that should actually be run. Use exact paths and commands when known.

### Manual Checks

List the things automation cannot fully prove, such as security boundaries, backwards compatibility, UI expectations, migration safety, or data correctness under realistic load.

## Style Rules

- Write in English.
- Optimize for future implementers and reviewers.
- Replace placeholders before finishing.
- Prefer short paragraphs and flat lists.
- Use `None` instead of leaving sections empty.
- Keep examples concrete and minimal.

## Adaptation Rules

When the source material comes from an `AGENTS.md`, issue, or chat transcript:

- preserve stable working rules
- drop repository-specific paths, services, and route conventions unless requested
- convert preferences into reusable guidance
- move detailed templates into `references/` when the body gets too long

When the user provides an existing spec draft:

- keep correct concrete details
- tighten vague language
- separate constraints from implementation notes
- add missing verification and manual checks

## Review Pass

Before finishing, verify:

- the title names one concrete change
- every required section exists
- status identifies the current state of the change
- context explains why the change is needed
- scope and non-goals do not conflict
- invariants are reviewable
- verification commands are runnable or clearly marked as pending
- project-local assumptions are either removed or explicitly called out
