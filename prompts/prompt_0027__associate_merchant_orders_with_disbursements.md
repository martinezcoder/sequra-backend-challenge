# Prompt 0027 — Associate MerchantOrders with Disbursements

Extend `MerchantOrder` with the persistence needed to represent its participation in a disbursement.

## Goal

A merchant order must be able to record:

- the disbursement it belongs to,
- the commission fee calculated for that order.

At import time, both values are unknown and will be assigned later by the disbursement processing.

## MerchantOrder

Add:

- nullable `disbursement_id`, referencing `disbursements`,
- nullable integer `fee_cents`.

Add the association:

    MerchantOrder belongs_to :disbursement, optional: true

and:

    Disbursement has_many :merchant_orders

The nullable state represents an order that has been imported but has not yet been processed into a disbursement.

## Commission fee

Persist the commission fee as integer cents, consistently with the existing monetary representation.

The fee belongs to the individual merchant order because commissions are calculated per order and must remain identifiable for reporting.

Commission calculation itself will be implemented separately.

## Tests

Add focused persistence specs covering:

- a newly created merchant order can exist without a disbursement,
- a merchant order can be associated with a disbursement,
- the association is available from both sides,
- `fee_cents` can be persisted for an order.

Follow the established RSpec structure.

## Import behavior

Once an order has been processed, re-importing it from the source CSV must not alter its disbursement state.

Add a loader spec verifying that when an existing `MerchantOrder` already has a `fee_cents` and `disbursement_id`, importing the same order again:

- updates the source-owned attributes as usual,
- preserves `fee_cents`,
- preserves `disbursement_id`.

The CSV importer owns only the attributes supplied by the source. Disbursement state is internal application data and must not be reset or overwritten by an import.

## Documentation

Update the README only as needed to describe the new persisted relationship and the purpose of `fee_cents`.

Keep this step limited to persistence and associations.
