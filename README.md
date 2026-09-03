# SeQura Coding Challenge

This repository contains a solution developed incrementally for the SeQura coding challenge. This document summarizes the current development approach and technical direction for reviewers; it will evolve as the implementation does.

## Development workflow

Development uses two complementary AI-assisted tools. ChatGPT is a collaborative space where the developer discusses the problem, explores and challenges alternatives, and decides how to proceed. Once a concrete task is defined, ChatGPT helps formulate a focused prompt for Codex CLI. These prompts are stored sequentially in [`prompts/`](prompts/), and Codex CLI is instructed to execute a specific numbered prompt. The developer remains responsible for all decisions and reviews every resulting change with Git before committing it.

## Development strategy

The implementation follows a baby-steps approach: start with the simplest useful representation of the problem and add complexity only when requirements justify it. Each step should be small, understandable, testable, and easy to evolve. Infrastructure and abstractions common in a mature production system may therefore be deliberately absent from early iterations.

## Development environment

A minimal Docker-based environment isolates the Ruby runtime and project dependencies, so reviewers only need Docker with Docker Compose rather than a local Ruby installation.

Run `make` to list the available commands.

The following commands provide the complete current reviewer workflow:

```sh
make setup
make db-drop
make db-migrate
make db-rollback
make test
make lint
make load-merchants FILE=input_data/merchants.csv
make load-merchant-orders FILE=input_data/orders.csv
make process-disbursements DATE=2026-09-03
make backfill-disbursements
make backfill-monthly-fees
make shell
make console
make run
```

`make setup` builds the development image and prepares the databases. `make db-drop` drops the development and test databases, `make db-migrate` applies pending development migrations, `make db-rollback` reverts the latest development migration, `make test` runs the complete RSpec suite, and `make lint` checks Ruby and RSpec style with RuboCop. `make load-merchants FILE=path/to/merchants.csv` imports merchants, while `make load-merchant-orders FILE=path/to/orders.csv` imports their orders. `make process-disbursements DATE=YYYY-MM-DD` processes DAILY and eligible WEEKLY disbursements for that business date. `make backfill-disbursements` processes all imported historical orders by replaying that normal daily flow from the earliest order date through six days after the latest. The six extra days allow a final WEEKLY order to reach its merchant's next eligible weekday. `make backfill-monthly-fees` evaluates monthly fees from the first through the last completed disbursement month. `make shell` opens a shell in the application container, `make console` opens an interactive Ruby console with the application environment loaded, and `make run` executes the example Ruby program.

### Ruby version

Ruby 3.4.10 is pinned exactly for a reproducible, modern environment. Ruby 4 was considered and is not being avoided as unstable or unsuitable; the developer has not yet used it enough to justify adding a new major runtime version as another variable in a time-bounded challenge. Ruby 3.4.10 provides a current environment while keeping that variable out of scope.

## Architecture

The current direction favors low coupling and high cohesion. Dependency injection will be used where it keeps components independent, testable, and replaceable, but neither injection nor abstractions will be introduced solely for architectural purity.

After evaluating the challenge requirements, persistence is needed from the first domain iteration. PostgreSQL was selected instead of a lighter option such as SQLite because Docker removes most of SQLite's setup-cost advantage for reviewers. ActiveRecord is used directly without Rails, providing conventional migrations, associations, transactions, constraints, and querying without custom repository infrastructure. Schema changes are managed through ActiveRecord migrations.

Merchants are persisted before their orders so orders can later reference a merchant instead of duplicating merchant information. A merchant uses the conventional ActiveRecord/PostgreSQL internal identifier; there is currently no requirement that justifies an internal UUID. The source merchant `id` is retained separately as the unique `external_id`, while its unique `reference` is retained because that is how the orders dataset identifies merchants. Disbursement frequency is stored as supplied by the source data; its behavior will be implemented separately.

Disbursements belong to merchants and have a unique reference and an explicit business date. A database constraint permits at most one disbursement per merchant and date. An order can be assigned to at most one disbursement: retries against the same logical disbursement remain idempotent, while model persistence rejects attempts to move an already-disbursed order elsewhere. DAILY is the first implemented scheduling mode: processing a date delegates each DAILY merchant/date pair as an independent transactional unit, groups its orders into one disbursement, and stores the per-order commission as integer `fee_cents`. Eligible orders are iterated in ActiveRecord batches so memory usage does not depend on a merchant's daily order volume. This keeps orchestration separate from merchant-level processing without introducing a background-processing technology. Commissions are calculated per order at 1.00% below €50, 0.95% from €50 up to but excluding €300, and 0.85% from €300 onward, with each fee rounded upward to cents. Rule lookup is isolated from integer fee calculation so the current in-code rules can move to another configuration source without changing disbursement processing.

WEEKLY processing runs a merchant when the processing date has the same weekday as its `live_on`` date. The challenge defines that weekday but not the exact order window; this implementation uses the seven calendar dates ending on the processing date, inclusive. Each merchant/date pair remains an independent transaction. Eligible orders are fetched using ActiveRecord batch iteration, while each order is currently persisted individually.

A monthly fee records the resulting amount from evaluating one merchant's minimum fee for a calendar month. Its `period` is normalized to the first day of that month. A record is persisted even when `amount_cents` is zero, distinguishing a month that was evaluated and required no additional fee from one that has not been processed. Commission totals and configured minimum fees are not duplicated on the record because their existing sources of truth can provide them when needed.

Monthly commissions are attributed by `Disbursement#disbursed_on`, not by `MerchantOrder#ordered_on`. All commissions in a WEEKLY disbursement spanning two calendar months therefore belong to the month in which that disbursement is completed. Persisted `MerchantOrder#fee_cents` values are the historical source of truth for commissions already applied. Monthly fee processing deliberately does not recalculate them because commission rules may change and current rules must not be applied retroactively. The processor only consumes completed disbursement data and never creates commissions or changes merchant orders. A zero-value monthly fee is still persisted so an evaluated merchant/month remains distinguishable from one that has not been processed.

`Disbursements::Process.call(date)` is the application-level entry point for a business date and is exposed through `make process-disbursements DATE=YYYY-MM-DD`. It runs the separate DAILY and WEEKLY scheduling flows sequentially; both delegate selected merchants to the same merchant/date processing unit, which retains its own transaction and idempotency guarantees.

For the historical dataset included in the challenge, `Disbursements::Backfill.call` replays this same daily processing flow across the required calendar range and is exposed through make backfill-disbursements. The backfill does not introduce separate business logic; it only orchestrates the existing date-based processor over historical dates.

`MonthlyFees::Backfill.call`, exposed through `make backfill-monthly-fees`, derives its historical range from the first and last `Disbursement#disbursed_on` dates, consistently with monthly commission attribution. It evaluates every calendar month between those boundaries, including months without disbursements. Skipping an empty intervening month would be incorrect because a merchant with no completed-disbursement commissions in that month may still owe its configured minimum fee.

Merchant imports synchronize records by `external_id`, creating missing merchants and updating existing ones. Each complete CSV is imported atomically because partially synchronized reference data would be misleading. A failure aborts the import and reports its row rather than introducing partial-success recovery infrastructure. Explicit locking is also omitted because concurrent imports are not currently required. Monetary CSV values are converted through `Money` and persisted as integer cents.

Merchant orders resolve their merchant by the source reference and persist only the resulting association. The source CSV's `created_at` value is a calendar date, so it is represented internally as the non-null date `ordered_on` rather than as a timestamp with unsupported precision. Because the provided dataset contains approximately 1.3 million orders, the importer builds a small in-memory `reference` to merchant ID map and persists streamed batches through bulk upserts. This avoids per-order merchant lookups and millions of individual writes, while the unique `external_id` constraint keeps re-imports idempotent. The import remains one transaction and converts amounts to integer cents through `Money`.

The bulk import was profiled during implementation. Different batch sizes, transaction boundaries, and both `insert_all` and `upsert_all` were tested. Parsing and transforming the approximately 1.3 million CSV rows took under one minute, while persisting the complete dataset took around eight minutes across the tested approaches. This indicates that PostgreSQL persistence is the dominant cost rather than CSV processing or batch configuration. Since this dataset represents an initial bulk import and future orders are expected to arrive incrementally, further optimization was deliberately avoided in favor of keeping the importer simple and idempotent.

Boundaries should not unnecessarily prevent future concurrent execution or distribution across processes. Operations that could later run as background jobs should be idempotent when appropriate, so retries do not create duplicate effects or irreversible inconsistencies. Concurrency, distributed execution, and background processing are not currently implemented.

## Monetary values

Monetary values are represented by a small project-owned `Money` value object. Ruby has no `Money` class in its standard library, and an external money dependency is not justified at this stage.

`Money` and persisted monetary values use integer cents as their only numeric representation. Monetary calculations, including commissions, remain in cents rather than exposing floating-point or decimal values, while `Money#to_s` provides a euro-denominated string solely for presentation.

This keeps money explicit in the domain while introducing only the behavior needed at each step.

## Performance and scalability considerations

The historical backfill processes approximately 1.3 million orders. In the local development environment, this operation takes several tens of minutes. The current implementation deliberately favors simple, explicit, and transactional processing over premature concurrency or infrastructure.

Each merchant disbursement is already modeled as an independent unit of work through `Disbursements::ProcessMerchant`. This boundary would allow the processing strategy to evolve without changing the underlying business logic.

A production-oriented implementation could enqueue merchant/date processing units as Sidekiq jobs backed by Redis, allowing multiple merchant disbursements to be processed concurrently. The Sidekiq concurrency level would need to be tuned together with the ActiveRecord connection pool and PostgreSQL capacity. Increasing worker concurrency without considering database connections, CPU, memory, and I/O could simply move the bottleneck to PostgreSQL or even reduce throughput.

An additional and independent optimization would be to reduce database round-trips by persisting order updates in batches instead of issuing one `UPDATE` per order.

These optimizations were intentionally left out of the challenge implementation because they introduce additional operational complexity. The current design keeps the business logic isolated so that asynchronous execution, parallelism, and bulk persistence can be introduced later without redesigning the domain processing flow.

## Decisions and evolution

This README records the developer's current decisions and will evolve with the solution. Relevant technical decisions will be documented when they arise, while keeping this document concise and focused on reviewer needs. No web framework, background processor, or concurrency strategy has been selected yet.
