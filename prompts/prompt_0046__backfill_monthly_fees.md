# Prompt 0046 — Backfill monthly minimum fees

Add a historical backfill flow for monthly minimum fees across the dataset provided with the challenge.

## Goal

Introduce:

    MonthlyFees::Backfill.call

The backfill should determine the calendar months that need to be evaluated and delegate each one to the existing:

    MonthlyFees::Process.call(period)

Keep all monthly minimum fee business logic inside `MonthlyFees::Process`. The backfill is only responsible for determining and iterating the historical periods.

## Processing range

Determine the historical range from the disbursements that have actually been completed.

Monthly commissions are attributed by `Disbursement#disbursed_on`, so the backfill range must follow the same source of truth rather than `MerchantOrder#ordered_on`.

Use the earliest and latest persisted `Disbursement#disbursed_on` values to determine the first and last calendar months to process.

For example, if disbursements exist from:

    2022-01-04
    ...
    2023-03-02

the backfill should evaluate:

    2022-01-01
    2022-02-01
    ...
    2023-03-01

Pass the first day of each month to `MonthlyFees::Process`, respecting its existing period contract.

If there are no disbursements, the backfill should complete without processing any period.

## Delegation

For every calendar month in the range, call:

    MonthlyFees::Process.call(period)

Do not duplicate merchant iteration, commission aggregation, minimum fee calculation, or persistence behavior in the backfill.

The backfill should simply replay the normal monthly processing flow over the historical periods.

## Command-line interface

Add a thin executable under `bin/` for running the historical monthly fee backfill.

Expose it through:

    make backfill-monthly-fees

Follow the existing conventions used by the disbursement backfill command.

Add the new user-facing Make target to `make help`.

## Tests

Add focused specs for `MonthlyFees::Backfill` covering at least:

- processing starts with the calendar month containing the earliest disbursement,
- processing ends with the calendar month containing the latest disbursement,
- every calendar month between those boundaries is processed, including months without disbursements,
- each period is represented by the first day of its month,
- an empty disbursement dataset performs no monthly fee processing.

Keep monthly fee calculation behavior in the existing `MonthlyFees::Process` specs rather than duplicating it here.

## Documentation

Update the README with the historical monthly fee workflow.

Document the relevant design decision that the backfill range is derived from `Disbursement#disbursed_on`, consistently with the monthly commission attribution rule established by the application.

Explain that months between the first and last disbursement are evaluated even when a particular month contains no disbursements. A merchant with no commissions from completed disbursements during such a month may still owe its configured minimum monthly fee, so skipping empty months would produce incorrect historical results.

Also document the reviewer-facing command:

    make backfill-monthly-fees

Keep the documentation focused on the historical processing semantics and the decisions not explicitly prescribed by the challenge.

## Verification

Run the full test suite and RuboCop.
