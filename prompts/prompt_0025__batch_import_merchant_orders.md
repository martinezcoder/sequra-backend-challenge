# Prompt 0025 — Batch import merchant orders

The current `LoadMerchantOrders` implementation performs row-by-row ActiveRecord lookups and writes.

The challenge orders CSV contains around 1,300,000 rows, so the current implementation is too slow.

## Goal

Refactor `LoadMerchantOrders` to handle the large CSV efficiently while preserving its current behavior and idempotency.

## Merchant lookup

Load only the merchant data required for order resolution:

    Merchant.pluck(:reference, :id).to_h

Use this in-memory `reference -> id` map while processing the import.

Do not instantiate all Merchant records and do not query Merchant once per CSV row.

If a CSV row references an unknown merchant, fail explicitly rather than silently skipping it.

## Batch processing

Keep streaming the CSV instead of loading all 1.3 million rows into memory.

Accumulate orders in reasonably sized batches.

For each row:

- resolve `merchant_id` from the preloaded merchant map,
- convert `amount` using `Money.from_euros(value).cents`,
- preserve the source `created_at`,
- build a plain attribute hash for persistence.

When a batch is full, persist it using:

    MerchantOrder.upsert_all(batch, unique_by: :external_id)

Flush the final partial batch at the end.

Use a reasonable fixed batch size. Since the value is a performance-related magic value, document why that size exists close to its definition without pretending it has been empirically optimized if it has not.

## Idempotency

Use the existing unique constraint on `external_id` as the conflict target.

Re-importing the same CSV must not create duplicate merchant orders.

If source data for an existing `external_id` changes, the existing merchant order must be updated.

## ActiveRecord trade-off

Using `upsert_all` is an intentional performance decision because the source contains approximately 1.3 million orders.

`upsert_all` bypasses normal ActiveRecord model instantiation, validations, and callbacks.

Make this trade-off explicit close to the `upsert_all` call.

The comment should explain why bulk upsert is used and what guarantee the surrounding importer must provide, rather than merely describing what `upsert_all` does.

For example, the code should communicate that imported values must already be resolved, validated, and normalized before reaching the bulk persistence operation.

Do not add callbacks or duplicate validation logic merely to compensate for using `upsert_all`.

## Atomicity

Preserve the current whole-import transaction for now.

Do not redesign the transaction strategy in this prompt.

We will evaluate the cost of keeping approximately 1.3 million orders inside one transaction separately if it becomes a practical problem after batching.

## Error handling

Preserve the existing failure behavior:

- report useful context to STDERR,
- propagate the original exception,
- do not silently skip invalid rows.

Adapt error reporting only as much as necessary for batch processing.

Do not add logging infrastructure, retries, queues, or recovery mechanisms.

## Tests

Adapt the existing specs to the batch implementation.

Cover at least:

- importing merchant orders correctly,
- associating orders with the correct merchant,
- converting amounts to cents,
- idempotent re-import,
- updating an existing order,
- handling an unknown merchant reference,
- flushing a final batch smaller than the configured batch size,
- rollback when an import fails.

Do not create a large test CSV. Keep tests small and deterministic.

## Documentation

Document this optimization at the appropriate levels.

### Close to the code

Document the non-obvious implementation decisions:

- why orders are persisted with `upsert_all`,
- that it intentionally bypasses ActiveRecord validations and callbacks,
- that values therefore need to be resolved and normalized before bulk persistence,
- why the chosen batch-size constant exists.

Do not add comments that simply narrate obvious Ruby or ActiveRecord behavior.

### README

Add a concise explanation that merchant orders are imported in batches because the provided dataset contains approximately 1.3 million orders.

Explain that:

- merchant references are resolved through a small in-memory `reference -> id` map to avoid per-order merchant queries,
- orders are persisted through bulk upserts,
- `external_id` uniqueness provides idempotent imports,
- this approach avoids millions of individual database operations while keeping the importer simple.

Keep this explanation focused on reviewer-relevant technical decisions and trade-offs.

Do not turn the README into implementation documentation.

## Scope

Do not change the MerchantOrder domain model.

Do not implement commissions or disbursements.

Do not introduce Redis, background jobs, queues, caching infrastructure, or additional dependencies.

Keep the solution focused on making the existing CSV import practical for approximately 1.3 million orders.
