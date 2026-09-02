# Prompt 0029 — Extract daily merchant disbursement processor

Refactor the current DAILY disbursement processing so orchestration and individual merchant processing have separate responsibilities.

## Goal

`ProcessDailyDisbursements` should be responsible for finding the DAILY merchants that need to be processed for a given date.

The processing of one merchant for that date should belong to a separate class.

This gives merchant processing a clear execution boundary and keeps the orchestration class small.

## ProcessDailyDisbursements

Keep the existing public interface:

    ProcessDailyDisbursements.call(date)

Its responsibility should be limited to:

- finding merchants with `DAILY` disbursement frequency,
- delegating each merchant to the merchant-level processor.

It should not contain the details of:

- selecting the merchant's eligible orders,
- creating or finding its disbursement,
- calculating order fees,
- associating orders with the disbursement,
- managing the transaction for that merchant.

## Merchant-level processor

Extract the processing of a single merchant and date into a dedicated class with a clear interface.

For example:

    ProcessDailyMerchantDisbursement.call(merchant, date)

This class should own the behavior currently implemented by the private merchant-processing methods:

- select the merchant's orders for the requested date,
- return without creating a disbursement when there are no eligible orders,
- find or create the merchant's disbursement for that date,
- generate the deterministic reference,
- calculate and persist the temporary 1% fee,
- associate the orders with the disbursement.

The transaction boundary should live here because one merchant's disbursement is the atomic unit of work.

## Execution boundary

Keep merchant processing independent of the orchestration mechanism.

A merchant and date should be sufficient to execute the complete unit of work.

This boundary is intentional: it keeps the core processing independent and makes it possible for merchant workloads to be distributed across separate workers or processes in the future without changing the merchant-level business logic.

Do not introduce a particular background-processing or concurrency technology; the goal is only to preserve this execution boundary.

## Idempotency

Preserve the existing idempotent behavior.

Processing the same merchant and date repeatedly must resolve to the same logical disbursement and produce the same order associations and fees.

## Tests

Refactor the specs around the new responsibilities.

`ProcessDailyDisbursements` specs should focus on orchestration and delegation to DAILY merchants.

The merchant-level processor specs should contain the detailed behavior currently covered by the end-to-end DAILY processing specs, including:

- selecting the correct orders,
- creating the disbursement,
- associating orders,
- calculating the temporary fee,
- handling a merchant without eligible orders,
- idempotent reprocessing,
- transactional rollback for that merchant.

Keep the tests focused on the responsibility of each class.

## Documentation

Update documentation only where the architectural responsibility has materially changed.

The important design decision is that a merchant/date pair forms an independent processing and transaction boundary, while `ProcessDailyDisbursements` only orchestrates those units.
