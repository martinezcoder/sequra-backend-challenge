# SeQura Coding Challenge

This repository imports the challenge merchant and order datasets into PostgreSQL, calculates DAILY and WEEKLY disbursements, evaluates monthly minimum fees, and produces the required annual report. It is a plain Ruby application built with ActiveRecord and designed to be run through Docker Compose.

## Final results

Running the complete import, disbursement backfill, monthly fee backfill, and reporting flow against the provided dataset produces:

| Year | Number of disbursements | Amount disbursed to merchants | Amount of order fees | Number of monthly fees charged | Amount of monthly fees charged |
| --- | --- | --- | --- | --- | --- |
| 2022 | 1547 | 37512710.86 | 339985.85 | 92 | 2055.29 |
| 2023 | 10363 | 187974724.48 | 1709436.72 | 120 | 2007.17 |

## Run and verify the solution

Docker with Docker Compose is the only significant local requirement. The complete workflow for a fresh checkout is:

```sh
make setup
make load-merchants FILE=input_data/merchants.csv
make load-merchant-orders FILE=input_data/orders.csv
make backfill-disbursements
make backfill-monthly-fees
make report
```

`make setup` builds the application image and creates and migrates the database. Importing and processing are separate stages: the loaders first persist the external data, then the backfills operate exclusively on that application data. The disbursement backfill processes approximately 1.3 million orders and takes several tens of minutes in the local development environment (see [Performance and Scalability considerations](#performance-and-scalability-considerations)).

Run the quality checks with:

```sh
make test
make lint
```

For incremental operation, `make process-disbursements DATE=2026-09-03` processes one business date. Database lifecycle commands (`make db-drop`, `make db-migrate`, and `make db-rollback`) and interactive commands (`make shell` and `make console`) are also available. `make run` verifies that the application can connect to PostgreSQL. Run `make` to see every command and its description.

## Design

### Persistence and domain model

I chose PostgreSQL because the challenge requires durable, identifiable orders, commissions, and disbursements. Docker removes most of the setup advantage an embedded database would otherwise provide. ActiveRecord is used directly without Rails, providing migrations, associations, transactions, constraints, and querying without a custom repository layer.

Merchants use conventional internal database identifiers. The source merchant `id` is stored separately as the unique `external_id`, and `reference` is retained because the order dataset uses it to identify merchants. Orders store the resolved merchant association rather than duplicating that reference. The source order `created_at` contains only a calendar date, so it is represented as the non-null date `MerchantOrder#ordered_on` instead of a timestamp with unsupported precision.

Disbursements have a unique reference and business date. A database constraint allows at most one disbursement per merchant and date. Monthly fee evaluations similarly allow one record per merchant and calendar-month `period`.

### CSV import

`LoadMerchants` synchronizes merchants by `external_id`: missing records are created and existing source data is updated. The complete merchant import is one transaction, so a bad row rolls back the whole synchronization rather than leaving partial reference data.

`LoadMerchantOrders` streams the much larger orders CSV. It builds a small in-memory merchant-reference-to-ID map to avoid a lookup per row, then writes batches with `upsert_all`. The unique order `external_id` makes re-imports idempotent, while bulk upsert avoids millions of individual writes. Because it bypasses model callbacks and validations, the loader resolves and normalizes every value before persistence. The import remains one transaction, and re-importing source attributes does not overwrite internal `disbursement_id` or `fee_cents` state.

Both loaders use Ruby's standard CSV library, report the failing line and row, and propagate errors.

### Money and commissions

All persisted and calculated monetary values use integer cents. The small project-owned `Money` value object converts CSV euro strings exactly and formats cents for presentation; no floating-point or decimal value is exposed for arithmetic.

Commissions are calculated per order using the challenge tiers: 1.00% below €50, 0.95% from €50 up to but excluding €300, and 0.85% from €300 onward. Each result is rounded upward to the next cent. `Commissions::Rules` owns rule lookup, while `Commissions::Calculator` applies the selected rate with integer arithmetic. The resulting `MerchantOrder#fee_cents` is persisted as the historical commission value.

### Disbursement processing

`Disbursements::Process.call(date)` is the application entry point for a business date. It runs the DAILY and WEEKLY scheduling flows sequentially. Both delegate selected merchants to `Disbursements::ProcessMerchant`, making one merchant/date pair an independent transaction and unit of work.

DAILY merchants include orders placed on the processing date. WEEKLY merchants run when the processing date has the same weekday as `Merchant#live_on`. The challenge defines that weekday but not the exact order window, so I use the seven calendar days ending on the processing date, inclusive.

Eligible orders are read in ActiveRecord batches, so memory use does not depend on a merchant's order volume. A merchant without eligible orders does not receive an empty disbursement. Deterministic references and the merchant/date database constraint make retries idempotent. `MerchantOrder` also rejects reassignment from an existing disbursement, explicitly enforcing that an order is disbursed at most once rather than relying on scheduling windows not to overlap.

### Historical backfills

`Disbursements::Backfill` replays the normal date processor from the earliest order date through six days after the latest. Those extra days allow a final WEEKLY order to reach its merchant's next eligible weekday. Processing the complete range gives every imported order its scheduled opportunity to be assigned, while the order invariant prevents a second assignment. The backfill contains no separate disbursement business logic.

`MonthlyFees::Backfill` derives its range from the first and last `Disbursement#disbursed_on` dates and delegates every intervening calendar month to the normal monthly processor. Months without disbursements are deliberately included because merchants may still owe their configured minimum when they generated no commissions.

### Monthly minimum fees

`MonthlyFee#period` represents an evaluated calendar month and is stored as its first day. `MonthlyFees::Process` persists the difference between a merchant's configured minimum and the commissions applied during that month, never less than zero.

Monthly commissions are attributed by `Disbursement#disbursed_on`, not `MerchantOrder#ordered_on`. Consequently, every commission in a WEEKLY disbursement spanning two months belongs to the month in which that disbursement completes. The processor consumes persisted `MerchantOrder#fee_cents` values and never recalculates or changes them: applying current commission rules retroactively could alter historical results.

A `MonthlyFee` is persisted even when its amount is zero. This distinguishes a merchant/month that was evaluated and required no additional fee from one that has not been processed. The record stores only the result; commission totals and configured minimums remain in their existing sources of truth.

### Annual reporting

`Reports::Annual` aggregates persisted data by calendar year and `make report` renders it as a deterministic Markdown table. Report years come from the data rather than a hardcoded list.

Disbursement counts, merchant amounts, and order fees are attributed by `Disbursement#disbursed_on`. The merchant amount is gross order value minus persisted order commissions. Monthly minimum fees are not subtracted because charging them is outside the challenge scope; they are reported separately by `MonthlyFee#period`. Only positive monthly fees count as charged, while zero-value records still represent completed evaluations. Historical reporting always consumes persisted commissions rather than recalculating them with potentially newer rules.

## Development approach

I developed the solution in small, testable increments, adding persistence, batching, processing boundaries, and reporting only when the requirements justified them. Ruby 3.4.10 is pinned for reproducibility.

The process used two complementary AI-assisted tools. I used ChatGPT to discuss alternatives and define each step, then stored focused Codex instructions sequentially in [`prompts/`](prompts/). I reviewed each resulting change with Git before committing it; the prompts remain in the repository as a transparent instruction history.

## Performance and scalability considerations

Parsing and transforming the approximately 1.3 million order rows took under one minute during local profiling, while PostgreSQL persistence took around eight minutes across the batch and transaction configurations tested. This indicated that persistence, rather than CSV parsing or the chosen batch size, was the dominant import cost. I kept the single atomic import because this dataset is an initial load and future orders are expected to arrive incrementally.

The historical disbursement backfill takes several tens of minutes locally. The implementation deliberately favors simple, explicit, transactional processing over concurrency infrastructure. Each merchant disbursement is already isolated in `Disbursements::ProcessMerchant`, so the execution strategy can evolve without changing its business logic.

In production, merchant/date units could become Sidekiq jobs backed by Redis. Worker concurrency would need to be tuned together with the ActiveRecord connection pool and PostgreSQL CPU, memory, and I/O capacity; increasing workers alone could move the bottleneck to the database or reduce throughput. Independently, order updates could be persisted in batches to reduce database round-trips. I left both optimizations out because they add operational and implementation complexity that the challenge does not require.
