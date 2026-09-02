# Prompt 0022 — Structure specs with contexts

Now that the test suite is still small, refine the RSpec style before more specs accumulate.

## Goal

Refactor the existing specs to prefer a clear `describe` / `context` / `it` structure where it improves readability.

Use `context` to express meaningful states, preconditions, or scenarios.

Use `it` to describe the behavior expected under that scenario.

## LoadMerchants spec

Refactor `load_merchants_spec.rb` in particular.

Prefer grouping examples around scenarios such as:

- when the merchant does not exist,
- when the merchant already exists,
- when the same file is imported more than once,
- when a later CSV row is invalid,
- when the CSV data itself is invalid.

Move shared setup into the nearest relevant `before` block when all examples in that context need it.

Keep scenario data such as `valid_row`, `invalid_row`, and identifiers as `let` values.

Keep action helpers such as `write_csv` as helper methods rather than `let`.

Remove the `import_ignoring_error` helper.

For rollback examples, explicitly assert both:

- that the import raises the expected error,
- that the relevant persisted state remains unchanged after the rollback.

## General RSpec guideline

Add a concise guideline to `AGENTS.md` for future specs:

- prefer `context` for meaningful states or conditions,
- keep `it` focused on observable behavior,
- use `let` for scenario data and objects,
- use `before` for shared setup with side effects when appropriate,
- keep action-oriented helpers as methods,
- avoid unnecessary nesting when a flat spec is clearer.

The goal is readability, not maximizing the number of contexts.

## Scope

Preserve the existing test behavior and coverage.

Do not change application behavior as part of this refactor.
