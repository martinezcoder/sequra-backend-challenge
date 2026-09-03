# Prompt 0041 — Document performance and scalability considerations

Add a new section near the end of the README named:

## Performance and scalability considerations

Use the following content:

The historical backfill processes approximately 1.3 million orders. In the local development environment, this operation takes several tens of minutes. The current implementation deliberately favors simple, explicit, and transactional processing over premature concurrency or infrastructure.

Each merchant disbursement is already modeled as an independent unit of work through `ProcessMerchantDisbursement`. This boundary would allow the processing strategy to evolve without changing the underlying business logic.

A production-oriented implementation could enqueue merchant/date processing units as Sidekiq jobs backed by Redis, allowing multiple merchant disbursements to be processed concurrently. The Sidekiq concurrency level would need to be tuned together with the ActiveRecord connection pool and PostgreSQL capacity. Increasing worker concurrency without considering database connections, CPU, memory, and I/O could simply move the bottleneck to PostgreSQL or even reduce throughput.

An additional and independent optimization would be to reduce database round-trips by persisting order updates in batches instead of issuing one `UPDATE` per order.

These optimizations were intentionally left out of the challenge implementation because they introduce additional operational complexity. The current design keeps the business logic isolated so that asynchronous execution, parallelism, and bulk persistence can be introduced later without redesigning the domain processing flow.

Place the section where it fits naturally near the end of the README, after the implemented solution and its main technical decisions have already been explained.
