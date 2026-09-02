# Prompt 0036 — Unify merchant disbursement processing

Refactor the DAILY and WEEKLY merchant-level processors into a single `ProcessMerchantDisbursement` class.

## Context

`ProcessDailyMerchantDisbursement` and `ProcessWeeklyMerchantDisbursement` now contain almost identical processing logic.

The meaningful difference between them is the eligible order window:

- DAILY processes orders from the processing date.
- WEEKLY processes the seven calendar dates ending on the processing date, inclusive.

The merchant already owns its `disbursement_frequency`, so the shared processor can use that as the source of truth rather than receiving the frequency separately.

## Goal

Replace the two merchant-level processors with a single interface:

    ProcessMerchantDisbursement.call(merchant, date)

The processor should inspect the merchant's `disbursement_frequency` to determine the eligible order window.

## Eligible orders

For a `DAILY` merchant, select orders where:

    ordered_on == processing date

For a `WEEKLY` merchant, select orders from:

    processing date - 6 days

through:

    processing date

inclusive.

Keep the existing comment documenting the WEEKLY assumption close to the weekly date-window logic:

    The challenge does not define the weekly order window. This implementation
    uses the seven calendar dates ending on the processing date, inclusive.

Keep this frequency-dependent behavior simple and explicit.

## Shared processing

Preserve the existing merchant-level behavior:

- one merchant/date pair is an independent transaction,
- no disbursement is created when there are no eligible orders,
- the disbursement is found or created using the merchant and processing date,
- its reference remains deterministic,
- eligible orders are processed in batches without materializing the complete relation,
- the temporary 1% fee is calculated and persisted,
- orders are associated with the disbursement,
- repeated processing remains idempotent,
- a failure rolls back that merchant's unit of work.

## Orchestrators

Update both:

    ProcessDailyDisbursements
    ProcessWeeklyDisbursements

to delegate merchant processing through:

    ProcessMerchantDisbursement.call(merchant, date)

The orchestrators should continue to decide which merchants are scheduled for the requested date.

In particular, WEEKLY weekday eligibility remains the responsibility of `ProcessWeeklyDisbursements`.

`ProcessMerchantDisbursement` is responsible for processing an already selected merchant, not for deciding whether that merchant should run on the requested date.

## Tests

Consolidate the duplicated merchant-level specs around `ProcessMerchantDisbursement`.

Cover both frequency contexts explicitly:

    context "when the merchant is DAILY"
    context "when the merchant is WEEKLY"

Keep frequency-specific order-window behavior in those contexts and common processing behavior at the appropriate shared level.

Update the DAILY and WEEKLY orchestration specs to expect delegation to `ProcessMerchantDisbursement`.

Preserve the existing behavioral coverage while removing tests that only existed because the implementation was duplicated.

## Documentation

Update the README only where necessary to reflect that DAILY and WEEKLY merchants now share the same merchant-level processing unit.

The scheduling flows remain separate, while the actual processing of a selected merchant is unified.
