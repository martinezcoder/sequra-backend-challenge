# Prompt 0028 — Process daily disbursements

Implement the first end-to-end disbursement processing flow, limited to merchants with `DAILY` disbursement frequency.

## Goal

Given a processing date, create the corresponding disbursements for DAILY merchants and associate that day's merchant orders with them.

This first iteration intentionally uses a fixed 1% commission for every order. The complete commission rules will be introduced separately.

## Processing interface

Introduce a clear application service with an interface such as:

    ProcessDailyDisbursements.call(date)

The date represents the business date being processed.

## Eligible merchants

Process merchants whose `disbursement_frequency` is `DAILY`.

Process each merchant independently.

Keep the processing boundary at merchant level so individual merchants can be processed independently and the workload could be distributed across separate workers or processes in the future without changing the core disbursement logic.

Do not implement concurrent or background processing in this step.

A merchant with no orders for the requested date should not produce an empty disbursement.

## Eligible orders

For each merchant, select the orders whose source `created_at` belongs to the requested date.

The selection is based on merchant and business date, not on whether `disbursement_id` is currently null.

This is important for idempotency: reprocessing the same date must operate on the same logical set of orders.

## Disbursement

For each merchant with eligible orders, find or create the single `Disbursement` identified by:

    merchant + disbursed_on

Generate its required unique alphanumerical `reference` deterministically from stable merchant identity and the processing date.

Keep the reference generation simple and readable.

The same merchant and processing date must always resolve to the same logical disbursement.

## Order processing

For each eligible order:

- calculate a temporary fixed commission of 1% of the order amount,
- round the monetary result up to two decimal places as required by the challenge,
- persist the result in `fee_cents`,
- associate the order with the disbursement.

Keep all monetary calculations precise and compatible with the existing integer-cents representation.

The fixed 1% rule is intentionally temporary. Do not introduce the final commission-rule abstraction in this step.

## Idempotency

Processing the same date more than once must produce the same persisted result.

In particular:

- do not create duplicate disbursements,
- do not create duplicate order associations,
- the same orders remain associated with the same disbursement,
- recalculating the temporary fee must not accumulate or compound previous values.

The existing database uniqueness guarantees should participate in enforcing this behavior rather than relying only on application checks.

## Consistency

Processing one merchant should not leave that merchant's disbursement partially applied if an error occurs while processing its orders.

Use an appropriate transaction boundary around the processing of each merchant/disbursement.

## Tests

Cover the DAILY flow with focused scenarios, including:

- processing orders for a DAILY merchant on a given date,
- creating one disbursement for that merchant and date,
- associating the correct orders with it,
- persisting the temporary 1% fee on each order,
- excluding orders from another date,
- excluding orders belonging to another merchant,
- not creating a disbursement when the merchant has no orders for that date,
- reprocessing the same date without creating another disbursement or changing the logical result,
- rolling back a merchant's partial processing if that merchant's processing fails.

Use the established context-based RSpec style.

## Documentation

Document that DAILY disbursement processing is the first implemented scheduling mode.

Make it clear that the fixed 1% commission is an intentional intermediate implementation and that the amount-dependent commission rules from the challenge are not yet implemented.
