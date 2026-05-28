# Bad Request To Good Spec Example

Use this example when you need a concrete demonstration of how `spec-lite` should transform a vague request into a stable engineering spec.

## Invocation

Example prompt:

```text
Use $spec-lite to turn this rough request into a concise engineering spec.

Request:
The run list page is too slow and confusing. Make it faster. Users also want better filters and maybe caching. Do not break existing links. We should probably clean up some backend fields too.
```

## Step 1: Extract The Concrete Change

The request mixes several ideas:

- page performance
- filter UX
- caching
- backend cleanup
- backwards compatibility

`spec-lite` should not preserve that ambiguity. It should choose one concrete change or split the work.

Chosen change for this spec:

- add server-side filtering and cursor pagination for the run list API that powers the page

Moved to non-goals:

- frontend redesign
- generic caching work
- unrelated backend field cleanup

## Step 2: Separate Intent, Contract, And Verification

Intent:

- make the run list faster for large projects
- make filtering predictable

Contract:

- one API gets explicit filter fields and cursor pagination
- response shape remains link-compatible for existing run detail pages

Verification:

- targeted API tests
- pagination and filter behavior checks

## Step 3: Remove Project-Local Noise

The original request does not justify repository-specific conventions, UI experiments, or cleanup tasks. Keep only details required to implement and review the chosen change.

## Step 4: Produce The Spec

```md
# Add Cursor-Paginated Run List Filtering

## Goal
Allow large run lists to load predictably by adding explicit server-side filtering and cursor pagination to the run list query contract.

## Non-goals
- Does not redesign the run list page UI.
- Does not introduce result caching.
- Does not rename or remove existing run detail URLs.
- Does not perform unrelated backend field cleanup.

## Impact Scope
- Run list HTTP or RPC query endpoint.
- Query-layer request parsing and validation.
- Run list application service or query handler.
- Persistence query builder for run search.
- API contract tests for filtering and pagination.

## Data Flow
1. The client sends a run list request with optional filter fields and an optional cursor.
2. The query boundary validates filter values and pagination arguments.
3. The application layer translates the request into a run search query with stable sort order.
4. The persistence layer fetches one page of runs and computes the next cursor from the final row.
5. The API returns runs plus pagination metadata without changing existing run detail links.

## Interface And Schema Changes
- Add optional request fields for run state, creator, created-after, and created-before filters.
- Add optional `page_size` and `page_cursor` request fields.
- Add response field `next_page_cursor`.
- None for persistent schema changes.

## Invariants
- Existing run detail URLs remain unchanged.
- Filtering stays scoped to the caller's existing authorization boundary.
- Pagination order is stable so repeated requests with the same cursor do not skip or duplicate rows within one unchanged dataset.
- The API continues to return only run-list data and does not embed presentation-specific UI state.

## Implementation Plan
1. Update the run list query contract with filter and cursor fields.
2. Implement validation, stable sorting, and cursor translation in the query path.
3. Add contract and query-layer tests for empty filters, combined filters, first-page fetches, and next-page fetches.
4. Run the run list verification commands.

## Verification
- Run the query-layer test suite covering run list filtering.
- Run the API contract tests covering pagination cursors.

## Manual Checks
- Confirm existing bookmarked run detail links still open unchanged.
- Confirm combined filters match product expectations for date boundaries and creator matching.
- Confirm page transitions do not duplicate or skip rows during normal browsing.
```

## Why This Is Better

The output is better than the original request because it:

- chooses one change instead of mixing four efforts
- converts fuzzy wishes into explicit contract changes
- preserves important compatibility constraints
- gives implementers a concrete execution order
- ends with reviewable verification and manual checks
