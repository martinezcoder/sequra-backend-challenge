# Prompt 0018 — Add merchant CSV loader

Implement the first data-loading process for the challenge: importing merchants from a CSV file into PostgreSQL.

## Goal

Add a `LoadMerchants` class that:

- receives a CSV file path,
- creates merchants that do not exist,
- updates merchants that already exist,
- is idempotent,
- imports the complete file atomically,
- reports useful information when a row fails.

## Location and interface

Place the loader at:

`lib/loaders/load_merchants.rb`

Expose a simple interface:

`LoadMerchants.call(path)`

Use Ruby's standard `CSV` library.

The path must be provided by the caller; do not hardcode the challenge dataset location.

## CSV mapping

The source contains:

- `id`
- `reference`
- `email`
- `live_on`
- `disbursement_frequency`
- `minimum_monthly_fee`

Map `id` to `Merchant#external_id`.

Use the existing `Money` value object to convert `minimum_monthly_fee` from its CSV euro representation into integer cents:

`Money.from_euros(value).cents`

Persist the result into `minimum_monthly_fee_cents`.

Do not duplicate monetary conversion logic inside the loader.

## Idempotency

Use `external_id` as the identity of an imported merchant.

For each row:

- find the Merchant by `external_id`, or initialize it,
- assign the current CSV values,
- save it.

Running the same import repeatedly must not create duplicate merchants.

If merchant information changes in a later CSV import, update the existing Merchant.

This create-or-update strategy is intentional: the loader represents synchronization of merchant data from the supplied external source rather than an append-only import.

## Atomic import

Process the complete CSV inside a single database transaction.

If any row fails:

- stop processing,
- roll back every create or update performed during that import,
- report the failure,
- propagate the failure so the caller can detect that the import did not complete.

We prefer atomicity over partial imports because merchants are foundational reference data and a partially synchronized merchant dataset would be misleading.

Do not implement row-by-row commits or partial-success recovery.

## Error reporting

When a row fails, report to STDERR:

- the CSV line number,
- a safe representation of the failing row,
- the underlying error/cause.

Printing the failing row must be defensive: error-reporting code must not raise another exception and hide the original failure.

No logging framework or sophisticated error-recovery mechanism is needed. For the current challenge, aborting the atomic import with enough information to diagnose the failing row is sufficient.

## Concurrency

Do not introduce explicit table locking.

The transaction and existing database constraints are sufficient for the concurrency requirements currently known.

There is currently no requirement for concurrent merchant imports, so table locks or distributed/advisory locking would unnecessarily complicate the solution.

## Command-line entry point

Add a small executable entry point that allows:

`bundle exec ruby bin/load_merchants path/to/merchants.csv`

The executable should only deal with command-line concerns such as receiving the path, invoking `LoadMerchants`, and returning an unsuccessful exit status when the import fails.

Keep CSV parsing and persistence behavior inside `LoadMerchants`.

Also expose the loader through the Makefile if appropriate, keeping the Makefile as the simple reviewer-facing interface.

## Tests

Add focused tests covering:

- importing valid merchants,
- mapping source `id` to `external_id`,
- converting `minimum_monthly_fee` through `Money` and persisting cents,
- running the same import twice without duplicates,
- updating an existing merchant when source data changes,
- rolling back earlier creates when a later row fails,
- rolling back earlier updates when a later row fails,
- reporting the failing CSV line,
- failing rather than silently skipping invalid data.

Use small deterministic test fixtures or temporary CSV files rather than the complete challenge dataset.

## Documentation

Document the important decisions in the loader itself where useful, focusing on why rather than narrating the implementation.

Update the README to explain concisely:

- how to run a merchant import,
- why imports use create-or-update semantics based on `external_id`,
- why the whole import is atomic,
- why partial-success/error-recovery infrastructure and explicit locking have intentionally not been introduced,
- that monetary CSV values are converted through the existing `Money` value object and persisted as integer cents.
