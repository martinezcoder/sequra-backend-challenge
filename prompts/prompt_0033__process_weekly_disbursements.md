# Prompt 0033 — Process weekly disbursements

Implement WEEKLY disbursement processing as a separate flow.

## Context

The challenge states:

    Weekly disbursements: Process disbursements on the same weekday as the
    merchant's live_on date.

The challenge defines the processing weekday, but it does not define the exact weekly order window.

For this implementation, use the following explicit assumption:

- a WEEKLY merchant is processed when the processing date falls on the same weekday as `live_on`,
- the disbursement contains the seven calendar dates ending on the processing date,
- therefore, for a Thursday processing date, the eligible window is the previous Friday through that Thursday, inclusive.

Document this assumption close to the weekly-window logic because it resolves an ambiguity in the challenge.

## Goal

Given a processing date, process the WEEKLY merchants whose `live_on` weekday matches that date.

Keep the same architectural boundary already established for DAILY processing:

- one class orchestrates eligible WEEKLY merchants,
- another class processes one merchant and date as an independent unit of work.

Do not refactor shared DAILY/WEEKLY behavior in this step. Implement the WEEKLY flow first so the common behavior can be evaluated afterwards with concrete code.

## Weekly orchestration

Introduce a public interface such as:

    ProcessWeeklyDisbursements.call(date)

Its responsibility is to:

- find merchants with `disbursement_frequency` equal to `WEEKLY`,
- select only merchants whose `live_on` falls on the same weekday as the processing date,
- delegate each eligible merchant to the merchant-level WEEKLY processor.

Keep merchant processing independent so each merchant/date pair remains its own execution boundary.

## Merchant-level processing

Introduce a dedicated class with an interface such as:

    ProcessWeeklyMerchantDisbursement.call(merchant, date)

This class should own the complete processing of one WEEKLY merchant for that date.

Its transaction boundary should remain at merchant level.

## Eligible orders

For a processing date, select orders whose `ordered_on` belongs to the seven-day window ending on that date.

For example, when processing:

    2026-09-03

the eligible range is:

    2026-08-28 through 2026-09-03

inclusive.

Express this using date semantics rather than timestamp boundaries.

Do not materialize all eligible orders into memory at once. Preserve the batching approach used by the DAILY merchant processor.

A merchant with no eligible orders should not produce an empty disbursement.

## Disbursement

Find or create the merchant's single disbursement for the processing date using the existing `merchant_id + disbursed_on` uniqueness guarantee.

Generate its deterministic unique alphanumerical reference consistently with the existing DAILY implementation.

Repeated processing of the same merchant and date must resolve to the same logical disbursement.

## Order processing

For now, preserve the same temporary commission behavior implemented for DAILY disbursements:

- calculate a fixed 1% commission per order,
- round upward according to the existing integer-cents implementation,
- persist the fee in `fee_cents`,
- associate the order with the disbursement.

The final amount-dependent commission rules remain outside this step.

## Idempotency and consistency

Preserve the same guarantees as DAILY processing:

- repeated execution does not create duplicate disbursements,
- the same logical orders remain associated with the same disbursement,
- fees do not accumulate across retries,
- failure while processing one merchant rolls back that merchant's unit of work.

## Tests

Add focused coverage for both orchestration and merchant-level behavior.

Cover at least:

- a WEEKLY merchant whose `live_on` weekday matches the processing date is processed,
- a WEEKLY merchant with a different `live_on` weekday is not processed,
- a DAILY merchant is not processed by the WEEKLY orchestrator,
- the seven-day order window is inclusive of both its first and last dates,
- an order before the weekly window is excluded,
- an order after the processing date is excluded,
- a merchant with no eligible orders does not create a disbursement,
- the correct orders are associated with the disbursement,
- the temporary 1% fee is persisted,
- reprocessing the same merchant and date remains idempotent,
- merchant-level failure rolls back that merchant's processing.

Follow the established context-based RSpec style.

## Documentation

Update the README to document WEEKLY processing and the explicit interpretation of the challenge ambiguity.

State clearly that the challenge defines the processing weekday but not the exact weekly order window, and that this implementation uses the seven calendar days ending on the processing date.

Keep the documentation factual and do not describe a future unified DAILY/WEEKLY orchestration flow as already implemented.
