# Prompt 0040 — Backfill disbursements

Add a historical backfill flow that processes disbursements for all orders imported from the provided dataset.

## Context

The challenge requires calculating and storing disbursements for all provided orders while keeping the system ready to process new orders in the future.

The application already exposes the normal daily processing entry point:

    ProcessDisbursements.call(date)

The historical backfill should reuse this existing behavior rather than introduce separate DAILY or WEEKLY processing logic.

## Goal

Introduce:

    BackfillDisbursements.call

Its responsibility is to replay the normal daily disbursement processing across the complete historical date range required by the imported orders.

## Processing range

Determine the historical range from persisted merchant orders:

    first_order_date = MerchantOrder.minimum(:ordered_on)
    last_order_date = MerchantOrder.maximum(:ordered_on)

Start processing on `first_order_date`.

Continue processing through six calendar days after `last_order_date`, inclusive.

The additional six days are intentional. A WEEKLY merchant whose last order occurs on the final order date may have its next eligible processing weekday up to six days later. Extending the processing calendar ensures every imported order has an opportunity to be included in its scheduled disbursement.

Document this reason close to the range calculation because the additional days are not otherwise obvious.

If there are no merchant orders, the backfill should complete without doing anything.

## Delegation

For every calendar date in the processing range, call:

    ProcessDisbursements.call(date)

Keep all DAILY and WEEKLY eligibility and processing behavior in the existing classes.

`BackfillDisbursements` should only determine the historical calendar range and replay the normal application-level daily processing for each date.

## Command-line interface

Add a thin executable under `bin/` for running the historical backfill.

Expose it through:

    make backfill-disbursements

Use the existing Docker-based command conventions.

Add the new user-facing Make target to `make help`.

## Tests

Add focused specs for `BackfillDisbursements`.

Cover at least:

- processing begins on the earliest persisted `ordered_on`,
- processing continues through six days after the latest persisted `ordered_on`,
- every calendar date in that range is delegated to `ProcessDisbursements`,
- an empty orders dataset performs no processing.

Keep DAILY and WEEKLY business behavior in their existing specs rather than duplicating it here.

## Documentation

Update the README reviewer workflow with:

    make backfill-disbursements

Explain that this command processes all imported historical orders by replaying the normal daily processing flow across the dataset's calendar range.

Document why the range extends six days beyond the final order date for WEEKLY merchants.
