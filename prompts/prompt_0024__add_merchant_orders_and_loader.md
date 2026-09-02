# Prompt 0024 — Add MerchantOrder persistence and CSV loader

Add persistence and CSV importing for merchant orders.

## Domain model

Do not use the model name `Order`.

Use:

- `MerchantOrder`
- table `merchant_orders`

Add the associations:

- `Merchant has_many :merchant_orders`
- `MerchantOrder belongs_to :merchant`

Use the conventional ActiveRecord internal primary key.

## MerchantOrder data

The source CSV contains:

- `id`
- `merchant_reference`
- `amount`
- `created_at`

Persist:

- source `id` as `external_id`,
- the resolved merchant as `merchant_id`,
- `amount` as integer cents in `amount_cents`,
- the source creation timestamp.

`external_id` must be unique.

Do not persist `merchant_reference` on `merchant_orders`. Resolve it against `Merchant.reference` during import and store the association through `merchant_id`.

Use the existing `Money` value object to convert source euro amounts:

    Money.from_euros(value).cents

Do not duplicate money parsing logic in the loader and do not use Float.

## Loader

Add:

    LoadMerchantOrders.call(path)

Place it alongside the existing merchant CSV loader.

Use Ruby's standard CSV library and accept the CSV path explicitly.

For every row:

1. resolve `merchant_reference` against `Merchant.reference`,
2. find or initialize the `MerchantOrder` by `external_id`,
3. assign the imported source values,
4. save it.

The import must be idempotent:

- importing the same CSV twice must not create duplicate orders,
- changed source data for an existing `external_id` should update the existing order.

If a referenced merchant does not exist, fail rather than silently skipping the order.

## Atomicity and failures

Import the entire CSV in a single database transaction.

If any row fails:

- stop the import,
- roll back all creates and updates performed by that import,
- report the failing CSV line and row to STDERR,
- propagate the original exception.

Follow the same error-reporting approach already used by `LoadMerchants`.

## Tests

Cover at least:

- importing an order and mapping its values,
- associating it with the correct merchant,
- converting the amount to cents,
- idempotent re-import,
- updating an existing order,
- failure when the merchant reference cannot be resolved,
- rollback of earlier creates when a later row fails,
- rollback of earlier updates when a later row fails,
- failure reporting including the CSV line and row.

Structure the specs using the established `context`-based RSpec style.

## CLI and Makefile

Provide a thin executable entry point for loading merchant orders from a CSV path.

Expose it through the Makefile if that matches the existing merchant-loader workflow.

Keep application logic in `LoadMerchantOrders`, not in the CLI.
